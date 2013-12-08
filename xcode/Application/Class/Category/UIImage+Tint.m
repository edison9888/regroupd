//
//  UIImage+Tint.m
//  Snowcraft
//
//  Created by hlang on 12/16/12.
//  Copyright (c) 2012 hlang. All rights reserved.

// Copied from: http://stackoverflow.com/questions/4681903/how-to-implement-highlighting-on-uiimage-like-uibutton-does-when-tapped/4684876#4684876

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContext(self.size);
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end