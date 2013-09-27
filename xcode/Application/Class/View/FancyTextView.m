//
//
//
#import "FancyTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

#define kLeftIndent 30

@implementation FancyTextView

@synthesize _borderStyle,parentView,showPlaceholder,bgField;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        __backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor whiteColor];
        
//        CGRect bgFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//        
//        bgField = [[UITextField alloc] initWithFrame:bgFrame];
//        bgField.borderStyle = UITextBorderStyleNone;
//        bgField.backgroundColor = [UIColor grayColor];
//        bgField.delegate = nil;
//        bgField.enabled = NO;
//        
//        [self addSubview:bgField];
//        [self sendSubviewToBack:bgField];
        self.clipsToBounds = YES;
        [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
        [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:15]];
        [self setTextAlignment:NSTextAlignmentLeft];
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:5];
        [self setScrollEnabled:NO];

//        __numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
//        __numLabel.backgroundColor = [UIColor yellowColor];
//        [__numLabel setTextColor:[UIColor colorWithHexValue:0x28cfea andAlpha:1.0]];
//        [__numLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:15]];
//        [__numLabel setTextAlignment:NSTextAlignmentLeft];
//        [bgField setLeftView:__numLabel];
//        [bgField setLeftViewMode:UITextFieldViewModeAlways];
        [self setContentInset:UIEdgeInsetsMake(0.0, 25.0, 0.0, -25.0)];

    }
    
    return self;
}
-(void)setNumLabel:(NSString*)num {
    __numLabel.text = num;    
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

// Doesn't work in iOS7
//- (id)styleString
//{
//    return @"line-height: 1.6em;margin-right: 0px; margin-left: 25px; ";
//}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    return YES;
//}
//
//-(BOOL)textFieldShouldReturn:(UITextField *)txtObject {
//    NSLog(@"%s", __FUNCTION__);
//	[txtObject resignFirstResponder];
//	
//	return YES;
//}
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    if(showPlaceholder){
//        showPlaceholder = NO;
//        self.text = @"";
//    }
//    return YES;
//}
//
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    if(showPlaceholder){
//        showPlaceholder = NO;
//        self.text = @"";
//    }
//    
//}


@end
