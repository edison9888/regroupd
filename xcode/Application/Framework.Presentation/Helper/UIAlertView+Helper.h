//
//  UIAlertViewHelper.h
//  Presentation Framework
//
//  Created by Shaun Harrison on 10/16/08.
//  Copyright 2008 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * Convenience method to throw a quick alert to the user
 */
@interface UIAlertView (UIAlertView_Helper)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message;
+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message dismissButtonTitle:(NSString*)dismissButtonTitle;
+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message dismissButtonTitle:(NSString*)dismissButtonTitle delegate:(id<UIAlertViewDelegate>)delegate;

@end
