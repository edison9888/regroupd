//
//  SelectedItemWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "SelectedItemWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation SelectedItemWidget

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    bgColor = [UIColor colorWithHexValue:0x28CFEA andAlpha:1.0];
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:bgColor];
        [self.layer setBackgroundColor:bgColor.CGColor];
        
        [self.layer setBorderColor:[UIColor colorWithHexValue:0x09a1bd].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:3];
        
    }
    return self;
}

- (void) setFieldLabel:(NSString *)label {
    CGRect textFrame = CGRectMake(3, 3, 200, 18);
    self.itemText = [[UILabel alloc] initWithFrame:textFrame];
    self.itemText.text = label;
    [self.itemText setFont:[UIFont fontWithName:@"Raleway-Regular" size:12]];
    self.itemText.textColor = [UIColor grayColor];
    self.itemText.textAlignment = NSTextAlignmentLeft;
    
    //    self.borderStyle = UITextBorderStyleRoundedRect; // clear out default border
    
    [self setBackgroundColor:bgColor];
    
    [self addSubview:self.itemText];
    [self resizeLabel:self.itemText];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
