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
#import "FancyTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation FancyTextView

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
        
        __leftView = nil;
    }
    
    return self;
}

-(void)setBorderstyle:(UITextBorderStyle)borderStyle
{
    self._borderStyle = borderStyle;
    bgField.borderStyle = borderStyle;
}


-(void)setPlaceholder:(NSString*)placeholder
{
    showPlaceholder = YES;
    self.text = placeholder;
}


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
