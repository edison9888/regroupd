//
//  FancyTextView.m
//  Regroupd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import "FancyTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation FancyTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:self.font.pointSize]];
    self.textColor = [UIColor colorWithHexValue:0x333333];
    self.textAlignment = NSTextAlignmentLeft;
    
    //    self.borderStyle = UITextBorderStyleRoundedRect; // clear out default border
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.layer setBorderWidth:0];
    
    return self;
}

// See: http://vodpodgeekblog.wordpress.com/2011/03/04/ios-trick-add-padding-to-a-uitextlabel/
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 26, bounds.origin.y + 4,
                      bounds.size.width - 12, bounds.size.height - 8);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void) setFieldLabel:(NSString *)label {
    
}
@end
