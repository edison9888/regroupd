//
//
//
#import "FancyTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

#define kLeftIndent 30

@implementation FancyTextView


- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.clipsToBounds = YES;
        [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
        [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
        [self setTextAlignment:NSTextAlignmentLeft];
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:5];
        [self setScrollEnabled:NO];

        [self setContentInset:UIEdgeInsetsMake(0.0, 25.0, 0.0, -25.0)];

    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.clipsToBounds = YES;
    [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
    [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
    [self setTextAlignment:NSTextAlignmentLeft];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:5];
    [self setScrollEnabled:NO];
    
    [self setContentInset:UIEdgeInsetsMake(0.0, 25.0, 0.0, -25.0)];
    
    return self;
}
-(void)setNumLabel:(NSString*)num {
    __numLabel.text = num;    
}

-(void)setPlaceholder:(NSString*)placeholder
{
    showPlaceholder = YES;
    self.text = placeholder;
}

-(void)unsetPlaceholder:(NSString*)placeholder {
    
}

@end
