//
//  PresentationViewController.h
//  Presentation Framework
//
//

#import <Foundation/Foundation.h>
#import "SlideViewController.h"
#import "PresentationModel.h"
#import "PresentationNotifications.h"
#import "FoundationMovieView.h"

typedef struct {
	NSInteger	iCurrentSlide;
	NSInteger	iPreviousSlide;
	NSInteger	iNextSlide;
} PresentationSlideCursor;

@class PresentationAnimationSequence;

@interface PresentationViewController : SlideViewController <SlideViewControllerDelegate, FoundationMovieViewDelegate> {
	PresentationModel			*_presentationModel;
	PresentationSlideCursor		_slideCursor;
	BOOL						_ignoreNextCursor;
	
	// support for fullscreen movies
    FoundationMovieView			*_movieView;
	BOOL						_forceLandscapeMovie;
	BOOL						_loopMovie;
	CGAffineTransform			_originalTopTransform;
	
	// primary slide flow
	UIView						*_presentationView;
	SlideViewController			*_activeSlide;
	NSMutableArray				*_concurrentSlides;
	NSMutableArray				*_animations;
    
    BOOL                        _isTransitioning;
}

@property (nonatomic) PresentationModel *presentationModel;
@property (nonatomic, assign) BOOL ignoreNextCursor;
@property (nonatomic, strong) IBOutlet UIView *presentationView;
@property (readonly) SlideViewController *activeSlide;
@property (nonatomic, assign) BOOL isTransitioning;


- (id)initWithPresentationModel:(PresentationModel*)presentationModel;

- (void)gotoSlide:(SlideModel*)slide;
- (void)gotoSlideWithName:(NSString*)name;
- (void)gotoSlideWithName:(NSString *)name andOverrideTransition:(PresentationTransitionFlags)transition;
- (void)gotoSlideAtIndex:(NSUInteger)index;
- (void)gotoNextSlide;
- (void)gotoPreviousSlide;
- (void)gotoFirstSlide;
- (void)gotoLastSlide;

- (void)transitionComplete;

- (BOOL)dismissConcurrentSlideWithName:(NSString*)name;
- (void)dismissAllConcurrentSlides;

- (void)presentFullscreenMovieWithName:(NSString*)name landscapeOnly:(BOOL)landscape loopMovie:(BOOL)loop;
- (void)dismissFullscreenMovie;

/**
 * Runs the animation sequence when transitioning between slides. This method should not be called directly.
 * When overriding in a subclass, the superclass implementation should be called.
 *
 * @param animSequence The sequence of animations to be run
 */
- (void)processAnimationSequence:(PresentationAnimationSequence*)animSequence;

@end

#pragma mark PresentationAnimationSequence

@interface PresentationAnimationSequence : NSObject {
	SlideViewController			*_slideA;
	SlideViewController			*_slideB;
	PresentationAnimationStage	_animationStage;
}

@property (nonatomic, strong) SlideViewController *slideA;
@property (nonatomic, strong) SlideViewController *slideB;
@property (nonatomic, assign) PresentationAnimationStage animationStage;
@end
