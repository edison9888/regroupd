//
//  GalTextView.h
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//
//   Renamed from GalTextView and customized


#import <UIKit/UIKit.h>

@interface FancyTextView : UITextView
{
    
    BOOL showPlaceholder;
    UITextBorderStyle _borderStyle;
    UIColor *__backgroundColor;
    UITextField *bgField;
    id<UITextViewDelegate> delegate;
    
    UIView * parentView;
    
    CGFloat animatedDistance;
    
    UILabel *__numLabel;
    
}

@property(nonatomic,retain)UIView * parentView;
@property(nonatomic)BOOL showPlaceholder;
@property(nonatomic)UITextBorderStyle _borderStyle;

@property(nonatomic,retain) UITextField *bgField;

-(void)setNumLabel:(NSString*)num;
-(void)setBorderstyle:(UITextBorderStyle)borderStyle;
-(void)setPlaceholder:(NSString*)placeholder;

@end
