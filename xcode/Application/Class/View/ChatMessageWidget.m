//
//  ChatMessageWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "ChatMessageWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"
#define kInitialY   38

@implementation ChatMessageWidget


- (id)initWithFrame:(CGRect)frame message:(NSString *)msgtext isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    
    if (self) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"ChatMessageWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];
        
        [self.msgView setFont:theFont];
        
        self.msgView.text = msgtext;
        
        CGSize estSize;
        CGRect msgFrame = self.msgView.frame;
        CGSize baseSize = msgFrame.size;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            estSize = [self.msgView sizeThatFits:self.msgView.frame.size];
        } else {
            estSize = self.msgView.contentSize;
        }
        msgFrame.size = estSize;
        
        self.msgView.frame = msgFrame;
        
        self.dynamicHeight = kInitialY + estSize.height - baseSize.height;
        NSLog(@"estSize vs. baseSize = %f // %f", estSize.height, baseSize.height);

        if (owner) {
            self.leftCallout.hidden = YES;
            self.rightCallout.hidden = NO;
            [self.msgView setTextColor:[UIColor whiteColor]];
            [self.timeLabel setTextColor:[UIColor whiteColor]];
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x28CFEA]];

        } else {
            self.leftCallout.hidden = NO;
            self.rightCallout.hidden = YES;
            [self.msgView setTextColor:[UIColor blackColor]];
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x0d7dac]];
            [self.timeLabel setTextColor:[UIColor blackColor]];
        }
        
        [self addSubview:_theView];
        
    }
    return self;
}
- (CGSize)determineSize:(NSString *)text constrainedToSize:(CGSize)size
{
    CGSize estSize;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        estSize = [self.msgView sizeThatFits:self.msgView.frame.size];
    } else {
        estSize = self.msgView.contentSize;
    }
}

@end