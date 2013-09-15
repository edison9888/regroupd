//
//  HitPassView.m
//  Incivek
//
//

#import "HitPassView.h"


@implementation HitPassView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (int i = self.subviews.count - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];
        UIView *hitView = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
        if (hitView) {
            return hitView;
        }
    }
    return nil;
}

@end
