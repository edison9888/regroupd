//
//  PopOverView.h
//
//

#import "BaseComponentView.h"

@protocol PopOverComponentDelegate <NSObject>
- (void)popOverTriggerBy:(UIView*)triggerView;
- (void)popOverClosedBy:(UIView*)triggerView;
@end


@interface PopOverComponent : BaseComponentView {
    
    UIView *_triggerButton;
    UIView *_slideView;
    UIView *_overlayView;
   
    CGPoint _position;
    BOOL _isDisplaying;
    BOOL _isAnimating;
    
    id <PopOverComponentDelegate> __weak _popOverDelegate;
}

@property (nonatomic, weak) IBOutlet id <PopOverComponentDelegate> popOverDelegate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) IBOutlet UIView *triggerButton;
@property (nonatomic, strong) IBOutlet UIView *slideView;

@end
