//
//  PopOverView.m
//
//

#import "PopOverComponent.h"

#define _kOverlayAlpha 0.5

@implementation PopOverComponent

@synthesize overlayView = _overlayView;
@synthesize triggerButton =_triggerButton;
@synthesize slideView = _slideView;
@synthesize popOverDelegate = _popOverDelegate;


#pragma mark BaseViewController overrides

- (void)setComponentData:(NSMutableDictionary *)componentData {
	[super setComponentData:componentData];
    self.frame = CGRectMake([[componentData objectForKey:@"posX"] floatValue], [[componentData objectForKey:@"posY"] floatValue], self.frame.size.width, self.frame.size.height);
}

- (void)startComponent
{
    [super startComponent];    
    
    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _overlayView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTriggerButtonTap:)];
    [_triggerButton addGestureRecognizer:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOverlayTap:)];
    [_overlayView addGestureRecognizer:tapGesture];
}

#pragma mark - gesture handlers

- (void)onOverlayTap:(UITapGestureRecognizer*)gesture {
 
    if (_overlayView.alpha != _kOverlayAlpha){
        return;
    }
    
    [self onTriggerButtonTap:nil];
}

- (void)onTriggerButtonTap:(UITapGestureRecognizer*)gesture {
    
    if (_isAnimating) {
        return;
    }
    
    void (^animationBlock)(void);
    void (^completeBlock)(BOOL finished);
    
    if (_isDisplaying) {

        if ([_triggerButton isKindOfClass:[UIButton class]] ) {
            ((UIButton*)_triggerButton).selected = NO;
        }
        
        _isDisplaying = NO;
        [self removeFromSuperview];
        
        animationBlock = ^{
            _overlayView.alpha = 0.0;
        };
        
        completeBlock = ^(BOOL finished){
            [_overlayView removeFromSuperview];
            _isAnimating = NO;
            
            if (_popOverDelegate && [_popOverDelegate respondsToSelector:@selector(popOverClosedBy:)]) {
                [_popOverDelegate popOverClosedBy:_triggerButton];
            } 
        }; 
        
    } else {
        
        if ([_triggerButton isKindOfClass:[UIButton class]] ) {
            ((UIButton*)_triggerButton).selected = YES;
        }
        
        _isDisplaying = YES;
        [_slideView addSubview:_overlayView];
        [_slideView addSubview:_triggerButton];
        _overlayView.alpha = 0.0; 
        
        animationBlock = ^{
            _overlayView.alpha = _kOverlayAlpha;
        };
        
        completeBlock = ^(BOOL finished){
            [_slideView addSubview:self];
            _isAnimating = NO;
                        
            if (_popOverDelegate && [_popOverDelegate respondsToSelector:@selector(popOverTriggerBy:)]) {
                [_popOverDelegate popOverTriggerBy:_triggerButton];
            }
        }; 
    }
    
    _isAnimating = YES;
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:animationBlock
                     completion:completeBlock];
}

@end
