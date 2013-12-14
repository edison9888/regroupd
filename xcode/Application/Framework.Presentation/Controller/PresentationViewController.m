//
//  PresentationViewController.m
//  Presentation Framework
//
//

#import "PresentationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HitPassView.h"



@implementation PresentationAnimationSequence
@synthesize slideA = _slideA;
@synthesize slideB = _slideB;
@synthesize animationStage = _animationStage;

@end


#pragma mark PresentationViewController private category

@interface PresentationViewController (Private)
- (void)processAnimationSequence:(PresentationAnimationSequence*)animSequence;
- (NSTimeInterval)runSlideAnimations:(NSArray*)animations minHoldTime:(NSTimeInterval)minHold;
- (NSTimeInterval)runSlideTransition:(PresentationAnimationSequence*)animSequence;
- (void)dismissConcurrentSlide:(SlideViewController*)slideVC;

@end


#pragma mark PresentationViewController implementation

@implementation PresentationViewController
@synthesize presentationModel = _presentationModel;
@synthesize ignoreNextCursor = _ignoreNextCursor;
@synthesize presentationView = _presentationView;
@synthesize activeSlide = _activeSlide;
@synthesize isTransitioning = _isTransitioning;

- (void)initialize
{
    if (!_concurrentSlides) {
        _concurrentSlides = [[NSMutableArray alloc] initWithCapacity:4];
        _animations = [[NSMutableArray alloc] initWithCapacity:4];
    }
}

- (void)awakeFromNib
{
    [self initialize];
}

- (id)init
{
	if ((self = [super init])) {
        [self initialize];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithPresentationModel:(PresentationModel*)presentationModel
{
	if ((self = [self init])) {
        // Don't call -initialize (already called in [self init])
		self.presentationModel = presentationModel;
	}
	
	return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)setPresentationModel:(PresentationModel *)presentationModel
{
	_presentationModel = presentationModel;
	self.breadCrumb = _presentationModel.name;
	_animations = [[NSMutableArray alloc] initWithCapacity:5];
}

#pragma mark View lifecyle

- (void)viewDidLoad
{
    _pathArray = [[NSMutableArray alloc] initWithCapacity:3];
	if (self.view.window != [[UIApplication sharedApplication] keyWindow]) {
		self.isMirror = YES;
	}
	if (!_presentationView) {
        _presentationView = [[HitPassView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_presentationView];
    }
	
    // Setup basic gestures
	UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gesture setCancelsTouchesInView:NO];
	[self.view addGestureRecognizer:gesture];
    
    gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gesture];
}

- (void)viewDidUnload
{
	// cancel any outstanding animation sequence processing
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_presentationView.layer removeAllAnimations];
    _presentationView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[_activeSlide viewWillAppear:animated];
	for (SlideViewController *slideVC in _concurrentSlides) {
		[slideVC viewWillAppear:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!_activeSlide) {
		[self gotoSlideWithName:_presentationModel.firstSlideName];
	} else {
		[_activeSlide viewDidAppear:animated];
		for (SlideViewController *slideVC in _concurrentSlides) {
			[slideVC viewDidAppear:animated];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_activeSlide viewWillDisappear:animated];
	for (SlideViewController *slideVC in _concurrentSlides) {
		[slideVC viewWillDisappear:animated];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[_activeSlide viewDidDisappear:animated];
	for (SlideViewController *slideVC in _concurrentSlides) {
		[slideVC viewDidDisappear:animated];
	}
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark Gesture handlers

- (void)swipeLeft:(UIGestureRecognizer*)gesture
{
    if ([gesture state] == UIGestureRecognizerStateEnded && _activeSlide.slideModel.allowRightSlide) {
        
        [self gotoNextSlide];
        [_activeSlide willGotoNextSlide];
    }
}

- (void)swipeRight:(UIGestureRecognizer*)gesture
{
    if ([gesture state] == UIGestureRecognizerStateEnded && _activeSlide.slideModel.allowLeftSlide) {
        
        [self gotoPreviousSlide];
        [_activeSlide willgotoPrevSlide];
    }
}


#pragma mark Primary (modal) slide flow

- (void)gotoSlide:(SlideModel*)slide
{
    NSLog(@"gotoSlide %@", slide.name);
    if (!slide) {
        return;
    }
    // No idea what this does yet.
    //	if (!slide.isConcurrent && _activeSlide &&
    //				   (_activeSlide.isAnimating || slide.slideIndex == _activeSlide.slideModel.slideIndex)) {
    //		return;
    //	}
	
	SlideViewController *slideVC = [SlideViewController slideViewControllerWithSlide:slide];
    
	if (slideVC) {
		// create the main animation sequence to add the new VC
		PresentationAnimationSequence *animSequence = [[PresentationAnimationSequence alloc] init];
		[_animations addObject:animSequence];
		animSequence.slideB = slideVC;
		
		if (slideVC.slideModel.isConcurrent) {
			if (slide.isExclusive) {
				[self dismissAllConcurrentSlides];
			}
			[_concurrentSlides addObject:slideVC];
		} else {
			animSequence.slideA = _activeSlide;
			_activeSlide = slideVC;
		}
		
		// details of adding and messaging the new VC are handled in animation stages
		[self processAnimationSequence:animSequence];
	}
}

- (void)gotoSlideWithName:(NSString*)name
{
    NSLog(@"gotoSlideWithName %@", name);
	[self gotoSlide:[_presentationModel slideWithName:name]];
}

- (void)gotoSlideWithName:(NSString*)name returnPath:(NSString *)backPath {
    
    //    if (_returnPath.length > 0) {
    //        _returnPath = [NSString stringWithFormat:@"%@/%@", _returnPath, backPath];
    //    } else {
    //        _returnPath = backPath;
    //    }
    [_pathArray addObject:backPath];
    _returnPath = [_pathArray componentsJoinedByString:@"/"];
    
    NSLog(@"Setting back path to %@", _returnPath);
    
	[self gotoSlide:[_presentationModel slideWithName:name]];
    
}
- (void)gotoSlideWithName:(NSString *)name andOverrideTransition:(PresentationTransitionFlags)transition
{
    SlideModel *slideModel = [_presentationModel slideWithName:name];
    slideModel.transitionFlags = transition;
    
    [self gotoSlide:slideModel];
}

- (void)gotoSlideAtIndex:(NSUInteger)index
{
	if (index >= _presentationModel.slides.count) {
        return;
    }
    
    SlideModel *slideModel = [[_presentationModel.slides objectAtIndex:index] copy];
    [self gotoSlide:slideModel];
}

- (void)gotoNextSlide
{
	[self gotoSlideAtIndex:_activeSlide.slideModel.nextSlideIndex];
}

- (void)gotoPreviousSlide
{
	[self gotoSlideAtIndex:_activeSlide.slideModel.previousSlideIndex];
}

- (void)gotoFirstSlide
{
	[self gotoSlideWithName:_presentationModel.firstSlideName];
}

- (void)gotoLastSlide
{
	[self gotoSlideWithName:_presentationModel.lastSlideName];
}

- (void)goBack
{
    NSString *target = nil;
    if (_pathArray.count > 0) {
        target = (NSString *)[_pathArray lastObject];
        [_pathArray removeLastObject];
        NSLog(@"goBack to %@", target);
        [self gotoSlideWithName:target];
    }
}
- (void)setBackPath:(NSString *)_path {
    NSLog(@"returnPath set to %@", _path);
    _pathArray = [_path componentsSeparatedByString:@"/"].mutableCopy;
    
    _returnPath = _path;
}

#pragma mark Concurrent slide flow

- (void)dismissConcurrentSlide:(SlideViewController*)slideVC
{
	if (slideVC.isAnimating) {
		return;
	}
    
	PresentationAnimationSequence *animSequence = [[PresentationAnimationSequence alloc] init];
	[_animations addObject:animSequence];
	animSequence.slideA = slideVC;
	slideVC.isAnimating = YES;
	
	[self processAnimationSequence:animSequence];
}

- (BOOL)dismissConcurrentSlideWithName:(NSString*)name
{
	for (SlideViewController *slideVC in _concurrentSlides) {
		if ([slideVC.slideModel.name isEqual:name]) {
			[self dismissConcurrentSlide:slideVC];
			[_concurrentSlides removeObject:slideVC];
			return YES;
		}
	}
	
	return NO;
}

- (void)dismissAllConcurrentSlides
{
	for (SlideViewController *slideVC in _concurrentSlides) {
		[self dismissConcurrentSlide:slideVC];
	}
	[_concurrentSlides removeAllObjects];
}


#pragma mark Animations handling

- (void)processAnimationSequence:(PresentationAnimationSequence*)animSequence
{
    
	SlideViewController *slideA = animSequence.slideA;
	SlideViewController *slideB = animSequence.slideB;
    //    NSLog(@"Setting back slide to %@", slideA.slideModel.name);
    //
    //    _presentationModel.backSlideName = slideA.slideModel.name;
    
    //exit animation for current vc
	if (animSequence.animationStage == kPresentationAnimationStageIdle) {
		animSequence.animationStage = kPresentationAnimationStageStart;
		slideA.isAnimating = slideB.isAnimating = YES;
		
		// insert new slide according to its type
		if (slideB.slideModel.isConcurrent)
			[_presentationView addSubview:slideB.view];
		else if (slideA)
			[_presentationView insertSubview:slideB.view atIndex:1];
		else
			[_presentationView insertSubview:slideB.view atIndex:0];
		
		// align new slide view
		slideB.view.frame = [self calculateFrameForView:slideB.view withGravity:slideB.slideModel.gravityFlags];
		slideB.delegate = self;
		slideB.breadCrumb = [_breadCrumb stringByAppendingFormat:@".%@", slideB.slideModel.name];
		NSLog(@"breadcrumb: %@", slideB.breadCrumb);
        
		// send child VC messages
        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
            [slideA viewWillDisappear:YES];
            [slideB viewWillAppear:YES];
        }
		
		// start / exit animation
		NSArray *animations = [slideA exitAnimationsForStage:animSequence.animationStage toSlide:slideB.slideModel];
		NSTimeInterval holdTime = [self runSlideAnimations:animations minHoldTime:0.0];
        
		if (holdTime > 0.0) {
			[self performSelector:@selector(processAnimationSequence:) withObject:animSequence afterDelay:holdTime];
		} else {
			// no start animation? proceed without yielding run loop
			[self processAnimationSequence:animSequence];
		}
	}
	else if (animSequence.animationStage == kPresentationAnimationStageStart) {
		animSequence.animationStage = kPresentationAnimationStageTransition;
        
		// invoke global transition
		NSTimeInterval holdTime = [self runSlideTransition:animSequence];
		// transition / exit animation
		NSArray *animations = [slideA exitAnimationsForStage:animSequence.animationStage toSlide:slideB.slideModel];
		holdTime = [self runSlideAnimations:animations minHoldTime:holdTime];
		
		// transition / enter animation
		animations = [slideB enterAnimationsForStage:animSequence.animationStage fromSlide:slideA.slideModel];
		holdTime = [self runSlideAnimations:animations minHoldTime:holdTime];
		[self performSelector:@selector(processAnimationSequence:) withObject:animSequence afterDelay:holdTime];
	}
	else if (animSequence.animationStage == kPresentationAnimationStageTransition) {
		animSequence.animationStage = kPresentationAnimationStageFinish;
		
		// finish / enter animation
		NSArray *animations = [slideB enterAnimationsForStage:animSequence.animationStage fromSlide:slideA.slideModel];
		NSTimeInterval holdTime = [self runSlideAnimations:animations minHoldTime:0.0];
		[self performSelector:@selector(processAnimationSequence:) withObject:animSequence afterDelay:holdTime];
	}
	else /* animation is complete */ {
		slideA.isAnimating = slideB.isAnimating = NO;
		
		// update VC states and views
        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
            [slideB viewDidAppear:YES];
            [slideA viewDidDisappear:YES];
        }
		slideB.view.userInteractionEnabled = YES;
		[slideA.view removeFromSuperview];
		
		// update cursor
		if (!_ignoreNextCursor) {
			_slideCursor.iCurrentSlide = slideB.slideModel.slideIndex;
			_slideCursor.iPreviousSlide = slideB.slideModel.previousSlideIndex;
			_slideCursor.iNextSlide = slideB.slideModel.nextSlideIndex;
		} else {
			_ignoreNextCursor = NO;
		}
		
		// releasing animation also releases any previous slide
		[_animations removeObject:animSequence];
		animSequence.animationStage = kPresentationAnimationStageIdle;
	}
}

- (NSTimeInterval)runSlideAnimations:(NSArray*)animations minHoldTime:(NSTimeInterval)minHold
{
	NSTimeInterval holdTime = minHold;
	for (AnimationModel *animation in animations) {
		if (animation.hold >= 0) {
			holdTime = MAX(holdTime, MIN(animation.delay + animation.duration, animation.hold));
		} else {
			holdTime = MAX(holdTime, animation.delay + animation.duration);
		}
		UIViewAnimationOptions options = (animation.options | UIViewAnimationOptionOverrideInheritedDuration |
										  UIViewAnimationOptionOverrideInheritedCurve);
		
		[UIView	animateWithDuration:animation.duration delay:animation.delay options:options
						 animations:animation.execute completion:animation.complete];
	}
	
	return holdTime;
}

- (NSTimeInterval)runSlideTransition:(PresentationAnimationSequence*)animSequence
{
	SlideViewController *slideA = animSequence.slideA;
	SlideViewController *slideB = animSequence.slideB;
	SlideViewController *slidePrimary = slideB ? slideB : slideA;
	
	// determine transition flags - global flags may be overridden per slide
	PresentationTransitionFlags	transitionFlags = _presentationModel.transitionFlags;
	if (slidePrimary.slideModel.transitionFlags != kPresentationTransitionEmpty) {
		if ([slidePrimary.slideModel.transitionSlideNames indexOfObject:slidePrimary.slideModel.name] != NSNotFound) {
			transitionFlags = slidePrimary.slideModel.transitionFlags;
		}
	}
	
	if (transitionFlags & kPresentationTransitionAuto) {
		transitionFlags = [self calculateAutoTransitionFlags:transitionFlags slideA:slideA slideB:slideB];
	}
    
	// mask out transition type and execute
	PresentationTransitionFlags transitionType = transitionFlags & kPresentationTransitionTypeMask;
	switch (transitionType) {
			
		case kPresentationTransitionFade:{
            self.isTransitioning = YES;
			slideB.view.alpha = 0;
			[UIView animateWithDuration:_presentationModel.transitionDuration
							 animations:^(void) {
								 slideB.view.alpha = 1.0;
								 slideA.view.alpha = 0.0;
							 }
							 completion:^(BOOL finised){
                                 [self transitionComplete];
                             }];
			break;
        }
		case kPresentationTransitionPush: {
            self.isTransitioning = YES;
			{
				CGRect frameA = slideA.view.frame;
				CGRect frameB = slideB.view.frame;
				CGPoint originB = frameB.origin;
				
				// determine start/end rects for B; end rect for A
				if (transitionFlags & kPresentationTransitionLeft) {
					frameA.origin.x = -frameA.size.width;
					frameB.origin.x = _presentationView.bounds.size.width;
				}
				else if (transitionFlags & kPresentationTransitionRight) {
					frameA.origin.x = _presentationView.bounds.size.width;
					frameB.origin.x = -frameB.size.width;
				}
				else if (transitionFlags & kPresentationTransitionUp) {
					frameA.origin.y = -frameA.size.height;
					frameB.origin.y = _presentationView.bounds.size.height;
				}
				else /* transition down */ {
					frameA.origin.y = _presentationView.bounds.size.height;
					frameB.origin.y = -frameB.size.height;
				}
                
				slideB.view.frame = frameB;
				frameB.origin = originB;
				
				[UIView animateWithDuration:_presentationModel.transitionDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut
								 animations:^{
									 slideA.view.frame = frameA;
									 slideB.view.frame = frameB;
								 }
								 completion:^(BOOL finised){
                                     [self transitionComplete];
                                 }];
			}
			break;
        }
        case kPresentationTransitionFadeInFadeOut:{
            self.isTransitioning = YES;
            {
                slideB.view.alpha = 0.0;
                slideB.view.hidden = YES;
                [UIView animateWithDuration:.33
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     slideA.view.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     slideB.view.alpha = 0.0;
                                     slideB.view.hidden = NO;
                                     [UIView animateWithDuration:.33
                                                           delay:0.0
                                                         options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^{
                                                          slideB.view.alpha = 1.0;
                                                      }
                                                      completion:^(BOOL finised){
                                                          [self transitionComplete];
                                                      }];
                                 }
                 ];
            }
            return .66;
            break;
        }
		case kPresentationTransitionModal:{
            self.isTransitioning = YES;
			{
				CGRect frameB = slideB.view.frame;
				slideB.view.frame = CGRectMake(CGRectGetMidX(slideB.view.frame), CGRectGetMidY(slideB.view.frame), 0, 0);
				slideB.view.alpha = 0.0;
				
				[UIView animateWithDuration:0.25
								 animations:^{
									 slideB.view.frame = frameB;
									 slideB.view.alpha = 1.0;
								 }
								 completion:^(BOOL finised){
                                     [self transitionComplete];
                                 }];
			}
			
			break;
        }
		case kPresentationTransitionEmpty:{
            
        }
		case kPresentationTransitionCut:{
            
        }
		default:{
			return 0.0;
        }
	}
    
	return _presentationModel.transitionDuration;
}

- (void)transitionComplete {
    self.isTransitioning = NO;
}

- (PresentationTransitionFlags)calculateAutoTransitionFlags:(PresentationTransitionFlags)transitionFlags slideA:(SlideViewController*)slideA slideB:(SlideViewController*)slideB
{
	SlideViewController *slidePrimary = slideB ? slideB : slideA;
	BOOL horz = (transitionFlags & (kPresentationTransitionUp | kPresentationTransitionDown)) == 0;
	transitionFlags &= ~(kPresentationTransitionLeft | kPresentationTransitionRight |
						 kPresentationTransitionUp | kPresentationTransitionDown);
	if (slidePrimary.slideModel.isConcurrent) {
		if (horz) {
			if (!slideA)
				transitionFlags |= (slidePrimary.slideModel.gravityFlags & kPresentationGravityLeft) ? kPresentationTransitionRight : kPresentationTransitionLeft;
			else
				transitionFlags |= (slidePrimary.slideModel.gravityFlags & kPresentationGravityLeft) ? kPresentationTransitionLeft : kPresentationTransitionRight;
		} else {
			if (!slideA)
				transitionFlags |= (slidePrimary.slideModel.gravityFlags & kPresentationGravityTop) ? kPresentationTransitionDown : kPresentationTransitionUp;
			else
				transitionFlags |= (slidePrimary.slideModel.gravityFlags & kPresentationGravityTop) ? kPresentationTransitionUp : kPresentationTransitionDown;
		}
	} else {
		if (slideB.slideModel.slideIndex > slideA.slideModel.slideIndex)
			transitionFlags |= kPresentationTransitionLeft;
		else
			transitionFlags |= kPresentationTransitionRight;
	}
	return transitionFlags;
}

- (CGRect)calculateFrameForView:(UIView*)view withGravity:(PresentationGravityFlags)gravityFlags
{
	CGRect frame = view.frame;
	
	switch (gravityFlags & kPresentationTransitionHorizontalMask) {
		case kPresentationGravityCenter:
			frame.origin.x = floorf((_presentationView.bounds.size.width - frame.size.width) / 2);
			break;
		case kPresentationGravityRight:
			frame.origin.x = (_presentationView.bounds.size.width - frame.size.width);
			break;
	}
	switch (gravityFlags & kPresentationTransitionVerticalMask) {
		case kPresentationGravityMiddle:
			frame.origin.y = floorf((_presentationView.bounds.size.height - frame.size.height) / 2);
			break;
		case kPresentationGravityBottom:
			frame.origin.y = (_presentationView.bounds.size.height - frame.size.height);
			break;
	}
	
	return frame;
}


@end
