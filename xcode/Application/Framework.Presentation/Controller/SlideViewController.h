//
//  SlideViewController.h
//  Presentation Framework
//
//

#import <UIKit/UIKit.h>
#import "TVOutManager.h"
#import "SlideModel.h"
#import "AnimationModel.h"
#import "PopOverComponent.h"


typedef enum {
	kPresentationAnimationStageIdle,
	kPresentationAnimationStageStart,
	kPresentationAnimationStageTransition,
	kPresentationAnimationStageFinish,
} PresentationAnimationStage;

@class SlideViewController;

@protocol SlideViewControllerDelegate <NSObject>
@required
- (void)gotoSlide:(SlideModel*)slide;
- (void)gotoSlideWithName:(NSString*)name;
- (void)gotoSlideWithName:(NSString *)name andOverrideTransition:(PresentationTransitionFlags)transition;
- (void)gotoSlideAtIndex:(NSUInteger)index;
- (void)gotoNextSlide;
- (void)gotoPreviousSlide;
- (void)gotoFirstSlide;
- (void)gotoLastSlide;

- (void)dismissConcurrentSlideWithName:(NSString*)name;
- (void)dismissAllConcurrentSlides;

- (void)presentFullscreenMovieWithName:(NSString*)name landscapeOnly:(BOOL)landscape loopMovie:(BOOL)loop;
- (void)dismissFullscreenMovie;

@property (readonly, assign) SlideViewController *activeSlide;

@end


@interface SlideViewController : UIViewController <BaseComponentViewDelegate> {
	SlideModel				*_slideModel;
	BOOL					_isAnimating;
	NSArray					*_componentViews;
	NSArray					*_sectionViews;
    NSInteger               _iSection;
	
	id<SlideViewControllerDelegate> __weak _delegate;

    // Programmatic display mirroring
	NSString				*_breadCrumb;
    BOOL                    _isMirror;
}

@property (nonatomic, strong) SlideModel *slideModel;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, weak) id<SlideViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *breadCrumb;
@property (nonatomic, assign) BOOL isMirror;
@property (nonatomic, strong) IBOutletCollection(BaseComponentView) NSArray *componentViews;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *sectionViews;

// programmatic section support
- (void)switchToSection:(NSInteger)iSection duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion;
- (NSInteger)indexOfSectionNamed:(NSString*)sectionName;

// typically used internally by subclasses
- (NSArray*)componentViewsForSection:(NSInteger)iSection;

// display mirroring support
- (void)sendMirrorNotification:(NSInvocation *)invocation;
- (void)handleMirrorNotification:(NSNotification *)note;

// transition animation supports
- (NSArray*)enterAnimationsForStage:(PresentationAnimationStage)stage fromSlide:(SlideModel*)fromSlide;
- (NSArray*)transitionAnimationsForStage:(PresentationAnimationStage)stage fromSlide:(SlideModel*)fromSlide;
- (NSArray*)exitAnimationsForStage:(PresentationAnimationStage)stage toSlide:(SlideModel*)toSlide;
- (NSArray*)sectionAnimationsToSection:(NSInteger)iNextSection;

+ (SlideViewController*)slideViewControllerWithSlide:(SlideModel*)slide;


- (void)willGotoNextSlide;
- (void)willgotoPrevSlide;


@end
