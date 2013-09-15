//
//  UIAlertViewHelper.m
//  Presentation Framework
//
//  Created by Shaun Harrison on 10/16/08.
//  Copyright 2008 enormego. All rights reserved.
//

#import "UIAlertView+Helper.h"


@implementation UIAlertView (UIAlertView_Helper)


+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
	return [UIAlertView showAlertWithTitle:title message:message dismissButtonTitle:@"OK" delegate:nil];
}

+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message dismissButtonTitle:(NSString*)dismissButtonTitle
{
	return [UIAlertView showAlertWithTitle:title message:message dismissButtonTitle:dismissButtonTitle delegate:nil];
}

+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message dismissButtonTitle:(NSString*)dismissButtonTitle delegate:(id<UIAlertViewDelegate>)delegate
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate 
										  cancelButtonTitle:dismissButtonTitle
										  otherButtonTitles:nil];
	[alert show];
	return alert;
}


@end
