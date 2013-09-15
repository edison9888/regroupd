//
//  SlideViewController.m
//  Presentation Framework
//
//

#import "SlideViewController.h"
#import "PresentationNotifications.h"
#import "HitPassView.h"
#import "UIView+Helper.h"

@implementation SlideViewController
@synthesize slideModel = _slideModel;
@synthesize isAnimating = _isAnimating;
@synthesize delegate = _delegate;
@synthesize componentViews = _componentViews;
@synthesize sectionViews = _sectionViews;
@synthesize breadCrumb = _breadCrumb;
@synthesize isMirror = _isMirror;


- (void)dealloc
{
    for (int i = 0; i < _componentViews.count; i++) {
		PopOverComponent *componentView = [_componentViews objectAtIndex:i];
        componentView.delegate = nil;
    }
    
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.componentViews = [UIView sortViewArrayByIndex:_componentViews];
	
	// set up components
	NSDictionary *componentDefaults = [_slideModel.components objectForKey:@"defaults"];
	NSDictionary *componentOverrides = [_slideModel.components objectForKey:@"overrides"];
    for (int i = 0; i < _componentViews.count; i++) {
		PopOverComponent *componentView = [_componentViews objectAtIndex:i];
		NSArray *instances = [_slideModel.components objectForKey:@"instances"];
        NSMutableDictionary *componentData = [NSMutableDictionary dictionaryWithDictionary:[[instances objectAtIndex:i] objectForKey:@"params"]];
		componentView.isMirror = self.isMirror;
		componentView.breadCrumb = [_breadCrumb stringByAppendingFormat:@".componentView%d", i];
        componentView.delegate = self;
		
		// set defaults if param empty
		for (NSString *key in [componentDefaults allKeys]) {
			if (![componentData objectForKey:key]) {
				NSObject *object = [componentDefaults objectForKey:key];
				[componentData setObject:object forKey:key];
			}
		}
		// set overrides
		for (NSString *key in [componentOverrides allKeys]) {
			if ([componentData objectForKey:key]) {
				NSObject *object = [componentOverrides objectForKey:key];
				[componentData setObject:object forKey:key];
			}
		}
		
		componentView.componentData = componentData;
	}
    
    // setup sections
    self.sectionViews = [UIView sortViewArrayByTag:_sectionViews];
    
    if (_sectionViews.count) {
        for (int i = 0; i < _sectionViews.count; i++) {
//        for (UIView *view in _sectionViews) {
            UIView *view = [_sectionViews objectAtIndex:i];
            [self.view addSubview:view];
            if (i < _slideModel.sections.count) {
                NSDictionary *section = [_slideModel.sections objectAtIndex:i];
                CGFloat positionX = [[section objectForKey:@"positionX"] floatValue];
                CGFloat positionY = [[section objectForKey:@"positionY"] floatValue];
                CGRect frame = view.frame;
                frame.origin = CGPointMake(positionX, positionY);
                view.frame = frame;
            }
            view.hidden = YES;
        }
        // display section
        _iSection = 0;
        if (_slideModel.url.length) {
            NSArray *comps = [_slideModel.url componentsSeparatedByString:@"/"];
            id compValue = [comps objectAtIndex:0];
            if ([compValue isKindOfClass:[NSNumber class]]) {
                _iSection = [compValue intValue];
            }
            else if ([compValue isKindOfClass:[NSString class]]) {
                for (int i = 0; i < _slideModel.sections.count; i++) {
                    NSDictionary *section = [_slideModel.sections objectAtIndex:i];
                    NSString *sectionName = [section objectForKey:@"name"];
                    if ([sectionName isEqualToString:compValue]) {
                        _iSection = i;
                        break;
                    }
                }
            }
        }
        
        UIView *view = [_sectionViews objectAtIndex:_iSection];
        view.hidden = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];

    for (int i = 0; i < _componentViews.count; i++) {
		PopOverComponent *componentView = [_componentViews objectAtIndex:i];
		NSArray *componentInstances = [_slideModel.components objectForKey:@"instances"];
		NSDictionary *componentData = [componentInstances objectAtIndex:i];
		NSNumber *autoStart = [componentData objectForKey:@"autoStart"];
		if (!autoStart || [autoStart boolValue]) {
			[componentView startComponent];
		}
	}	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:YES];
	
    for (int i = 0; i < _componentViews.count; i++) {
		PopOverComponent *componentView = [_componentViews objectAtIndex:i];
        [componentView stopComponent];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Animation stubs

- (NSArray*)enterAnimationsForStage:(PresentationAnimationStage)stage fromSlide:(SlideModel*)fromSlide
{
	return nil;
}

- (NSArray*)transitionAnimationsForStage:(PresentationAnimationStage)stage fromSlide:(SlideModel*)fromSlide
{
	return nil;
}

- (NSArray*)exitAnimationsForStage:(PresentationAnimationStage)stage toSlide:(SlideModel*)toSlide
{
	return nil;
}

- (NSArray*)sectionAnimationsToSection:(NSInteger)iNextSection
{
	return nil;
	
}

#pragma mark - Section support
- (NSArray*)componentViewsForSection:(NSInteger)iSection
{
    if (iSection >= _sectionViews.count) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in _componentViews) {
        UIView *sectionView = view.superview;
        while (![sectionView.superview isKindOfClass:[HitPassView class]]) {
            sectionView = sectionView.superview;
        }
        if (sectionView == [_sectionViews objectAtIndex:iSection]) {
            [array addObject:view];
        }
    }
    
    return array;
}

- (NSInteger)indexOfSectionNamed:(NSString*)name
{
    for (int i = 0; i < _slideModel.sections.count; i++) {
        NSDictionary *section = [_slideModel.sections objectAtIndex:i];
        NSString *sectionName = [section objectForKey:@"name"];
        if ([sectionName isEqualToString:name]) {
            return i;
        }
    }
	return NSNotFound;
}

- (void)sectionChangedTo:(NSUInteger)iSection {
    
}

- (void)switchToSection:(NSInteger)iSection duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion
{
    if (iSection == _iSection || iSection >= _sectionViews.count) {
        return;
    }
    
    [self sectionChangedTo:iSection];
    
    UIView *lastSection = [_sectionViews objectAtIndex:_iSection];
    UIView *newSection = [_sectionViews objectAtIndex:iSection];
    NSLog(@"lastSection: %@, newSection: %@", [lastSection description], [newSection description]);
    if (options) {
        [UIView transitionFromView:lastSection toView:newSection duration:duration 
                           options:options | UIViewAnimationOptionShowHideTransitionViews completion:completion];
    }
    else if (duration >= 0) {
        newSection.hidden = NO;
        newSection.alpha = 0.0;
        [UIView animateWithDuration:duration delay:0.0 options:0 
                         animations:^{
                             lastSection.alpha = 0.0;
                             newSection.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             lastSection.hidden = YES;
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        newSection.hidden = NO;
        lastSection.hidden = YES;
    }
    _iSection = iSection;
}

#pragma mark - Procedural Mirroring

- (void)setIsMirror:(BOOL)isMirror 
{
	if (isMirror == _isMirror) {
		return;
	}
	
	NSString *notificationName = [kPresentationMirrorNotificationPrefix stringByAppendingString:_breadCrumb];
	if (isMirror) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMirrorNotification:) name:notificationName object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
	}
}

- (void)sendMirrorNotification:(NSInvocation *)invocation
{
	NSString *notificationName = [kPresentationMirrorNotificationPrefix stringByAppendingString:_breadCrumb];
    if ([[TVOutManager sharedInstance] projectorConnected] && !_isMirror) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:invocation, @"invocation", _breadCrumb, @"breadCrumb", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
    }
}

- (void)handleMirrorNotification:(NSNotification *)note
{
    NSDictionary *noteDict = [note userInfo];
//	if ([_breadCrumb isEqual:[noteDict objectForKey:@"breadCrumb"]]) {
		NSInvocation *invocation = [noteDict objectForKey:@"invocation"];
		[invocation invokeWithTarget:self];
//	}
}


#pragma mark - Class messages

+ (SlideViewController*)slideViewControllerWithSlide:(SlideModel*)slide
{
    NSString *controllerName = slide.controllerName;
    if (!controllerName.length) {
        controllerName = [slide.name stringByAppendingString:@"ViewController"];
    }
    NSLog(@"SlideViewController: trying to instantiate with %@", controllerName);
    Class VCClass = NSClassFromString(controllerName);
    if (!VCClass) {
        VCClass = [SlideViewController class];
    }
	
	NSString *nibName = slide.nibName.length ? slide.nibName : slide.controllerName;
	SlideViewController *viewController = [[VCClass alloc] initWithNibName:nibName bundle:nil];
    viewController.slideModel = slide;
    
	return viewController;
}

- (void)willGotoNextSlide {}
- (void)willgotoPrevSlide {}

@end
