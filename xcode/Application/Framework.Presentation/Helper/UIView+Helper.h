//
//  UIView+Helper.h
//  Incivek
//
//

#import <Foundation/Foundation.h>


@interface UIView (UIView_Helper)

- (void)setLayerAnchorPoint:(CGPoint)anchorPoint;

/*
 * These help deal with NSOutletCollections being sorted arbitrarily by IB
 */

+ (NSArray*)sortViewArrayByTag:(NSArray*)viewArray;
+ (NSArray*)sortViewArrayByIndex:(NSArray*)viewArray;

@end
