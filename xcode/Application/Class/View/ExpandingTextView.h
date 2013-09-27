//
//  GalTextView.h
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//
//   Renamed from GalTextView and customized


#import <UIKit/UIKit.h>

@interface ExpandingTextView : UITextView<UITextViewDelegate,UITextFieldDelegate>
{

    BOOL showPlaceholder;
    UITextBorderStyle _borderStyle;
    UIColor *__backgroundColor;
    UITextField *bgField;
    id<UITextViewDelegate> delegate;
    ///doubletapspeed=delay in seconds or milliseconds ( depends on whatever you set it for ) between first "Return" tap and second to hids the keyboard.
    //default is 1.5 seconds
    CGFloat doubleTapSpeed;

    UIView * parentView;
    
    CGFloat animatedDistance;
    
    UIImageView *__leftView;
}
@property(nonatomic,retain)id<UITextViewDelegate> delegate;
@property(nonatomic,retain)UIView * parentView;
@property(nonatomic)BOOL showPlaceholder;
@property(nonatomic)UITextBorderStyle _borderStyle;
@property(nonatomic)CGFloat doubleTapSpeed;


/*
 UITextBorderStyleNone,
 UITextBorderStyleLine,
 UITextBorderStyleBezel,
 UITextBorderStyleRoundedRect
 */
-(void)setBorderstyle:(UITextBorderStyle)borderStyle;
-(void)setLeftViewImage:(UIImage*)image;
-(void)setPlaceholder:(NSString*)placeholder;
-(void)setGalBackgroundColor:(UIColor *)_backgroundColor;
- (CGRect)textRectForBounds:(CGRect)bounds;
- (CGRect)editingRectForBounds:(CGRect)bounds;

@end
