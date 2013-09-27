//
//  GalTextView.m
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//
/*
 Renamed from GalTextView and customized
 
 */
#import "ExpandingTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation ExpandingTextView

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@synthesize _borderStyle,parentView,showPlaceholder,delegate,bgField;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        __backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor whiteColor];
        bgField = [[UITextField alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
        bgField.borderStyle = UITextBorderStyleNone;
        bgField.backgroundColor = __backgroundColor;
        bgField.delegate = nil;
        bgField.enabled = NO;
        
        [self addSubview:bgField];
        [self sendSubviewToBack:bgField];
        self.clipsToBounds = YES;
        [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
        [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:15]];
        [self setTextAlignment:NSTextAlignmentLeft];
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:5];

        [self setContentInset:UIEdgeInsetsMake(0.0, 30.0, 0.0, 0.0)];

//        UIToolbar *doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, PORTRAIT_KEYBOARD_HEIGHT - 60, 320, 35)];
//        doneBar.barStyle = UIBarStyleBlack;
//        doneBar.translucent = YES;
//        [doneBar setAlpha:0.5];
//        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(hidekeyboard)];
//        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        //Add buttons to the array
//        NSArray *items = [NSArray arrayWithObjects:flexItem,doneBtn,nil];
//        [doneBar setItems:items animated:NO];
//        self.inputAccessoryView = doneBar;
        
        __leftView = nil;
    }
    
    return self;
}


-(void)hidekeyboard
{
    [self resignFirstResponder];
}

-(void)setLeftViewImage:(UIImage*)image
{
    __leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    __leftView.image = image;
    //[self addSubview:__leftView];
    //[self bringSubviewToFront:__leftView];
    [bgField setLeftView:__leftView];
    [bgField setLeftViewMode:UITextFieldViewModeAlways];
    [self setContentInset:UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0)];
    //self.contentInset = UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0);
    //[self styleString];
}

-(void)setBorderstyle:(UITextBorderStyle)borderStyle
{
    self._borderStyle = borderStyle;
    bgField.borderStyle = borderStyle;
}



-(void)setGalBackgroundColor:(UIColor *)_backgroundColor
{
    __backgroundColor = _backgroundColor;
    if(self._borderStyle == UITextBorderStyleRoundedRect){
        [bgField setBackgroundColor:_backgroundColor];
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)setPlaceholder:(NSString*)placeholder
{
    showPlaceholder = YES;
    self.text = placeholder;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)txtObject {
    NSLog(@"%s", __FUNCTION__);
	[txtObject resignFirstResponder];
	
	return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(showPlaceholder){
        showPlaceholder = NO;
        self.text = @"";
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(showPlaceholder){
        showPlaceholder = NO;
        self.text = @"";
    }

}
// See: http://vodpodgeekblog.wordpress.com/2011/03/04/ios-trick-add-padding-to-a-uitextlabel/
//- (CGRect)textRectForBounds:(CGRect)bounds {
//    return CGRectMake(bounds.origin.x + 26, bounds.origin.y + 4,
//                      bounds.size.width - 12, bounds.size.height - 8);
//}
//
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//    return [self textRectForBounds:bounds];
//}


 - (CGRect)textRectForBounds:(CGRect)bounds {
     NSLog(@"%s", __FUNCTION__);
     CGRect inset = CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
     return inset;
 }
 
 - (CGRect)editingRectForBounds:(CGRect)bounds {
     NSLog(@"%s", __FUNCTION__);
//     return [self textRectForBounds:bounds];
     CGRect inset = CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
     return inset;
 }


@end
