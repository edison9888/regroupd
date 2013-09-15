//
//  UIView+Helper.m
//  Incivek
//
//

#import "UIView+Helper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (UIView_Helper)


- (void)setLayerAnchorPoint:(CGPoint)anchorPoint
{
    CGRect frame = self.frame;
    CGFloat xDif = anchorPoint.x - self.layer.anchorPoint.x;
    CGFloat yDif = anchorPoint.y - self.layer.anchorPoint.y;
    frame.origin.x += xDif * frame.size.width;
    frame.origin.y += yDif * frame.size.height;
    self.frame = frame;
    self.layer.anchorPoint = anchorPoint;
}

+ (NSArray*)sortViewArrayByTag:(NSArray*)viewArray
{
    return [viewArray sortedArrayUsingComparator:
             ^(id v1, id v2) {
                 int viewIndex1 = ((UIView*)v1).tag;
                 int viewIndex2 = ((UIView*)v2).tag;
                 if (viewIndex1 < viewIndex2) {
                     return NSOrderedAscending;
                 }
                 if (viewIndex1 > viewIndex2) {
                     return NSOrderedDescending;
                 }
                 return NSOrderedSame;
             }];
}

+ (NSArray*)sortViewArrayByIndex:(NSArray*)viewArray
{
	return [viewArray sortedArrayUsingComparator:
					   ^(id v1, id v2) {
						   int viewIndex1 = [((UIView*)v1).superview.subviews indexOfObject:v1];
						   int viewIndex2 = [((UIView*)v2).superview.subviews indexOfObject:v2];
						   if (viewIndex1 < viewIndex2) {
							   return NSOrderedAscending;
						   }
						   if (viewIndex1 > viewIndex2) {
							   return NSOrderedDescending;
						   }
						   return NSOrderedSame;
					   }];
}

@end
