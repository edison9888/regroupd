//
//  UIView+Helper.h
//  Incivek
//
//  Created by hugh
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (UIView_Helper)

- (void)setLayerAnchorPoint:(CGPoint)anchorPoint;
- (UIView*)findFirstResponder;

/*
 * These help deal with NSOutletCollections being sorted arbitrarily by IB
 */
+ (NSArray*)sortViewArrayByTag:(NSArray*)viewArray;
+ (NSArray*)sortViewArrayByIndex:(NSArray*)viewArray;

@end
