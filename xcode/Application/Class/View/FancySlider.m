//
//  ANPopoverSlider.m
//  CustomSlider
//
//

#import "FancySlider.h"
#import "UIColor+ColorWithHex.h"

@implementation FancySlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self constructSlider];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self constructSlider];
    }
    return self;
}

#pragma mark - UIControl touch event tracking
//-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
//    // Fade in and update the popup view
//    CGPoint touchPoint = [touch locationInView:self];
//    
//    // Check if the knob is touched. If so, show the popup view
//    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint)) {
//        [self positionAndUpdatePopupView];
//        [self fadePopupViewInAndOut:YES];
//    }
//    
//    return [super beginTrackingWithTouch:touch withEvent:event];
//}

//-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    // Update the popup view as slider knob is being moved
//    [self positionAndUpdatePopupView];
//    return [super continueTrackingWithTouch:touch withEvent:event];
//}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

//-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    // Fade out the popup view
//    [self fadePopupViewInAndOut:NO];
//    [super endTrackingWithTouch:touch withEvent:event];
//}


#pragma mark - Helper methods
-(void)constructSlider {
//    self.backgroundColor = [UIColor colorWithHexValue:kSelectedColor];
//    _popupView = [[ANPopoverView alloc] initWithFrame:CGRectZero];
//    _popupView.backgroundColor = [UIColor clearColor];
//    _popupView.alpha = 0.0;
//    [self addSubview:_popupView];
}

-(void)fadePopupViewInAndOut:(BOOL)aFadeIn {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    if (aFadeIn) {
//        _popupView.alpha = 1.0;
//    } else {
//        _popupView.alpha = 0.0;
//    }
//    [UIView commitAnimations];
}

-(void)positionAndUpdatePopupView {
//    CGRect zeThumbRect = self.thumbRect;
//    CGRect popupRect = CGRectOffset(zeThumbRect, 0, -floor(zeThumbRect.size.height * 1.5));
//    _popupView.frame = CGRectInset(popupRect, -20, -10);
//    _popupView.value = self.value;
}


#pragma mark - Property accessors
-(CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
    return thumbR;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// See: http://stackoverflow.com/questions/4847163/round-two-corners-in-uiview
-(void) setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners radius:(float)radius
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

@end
