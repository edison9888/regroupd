//
//  ChatMessageWidget.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "ChatMessageWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"


#define kInitialY   38
#define kContentTop 20
#define kContentLeft 15
#define kContentWidth   200
#define kContentHeight  150

@implementation ChatMessageWidget

@synthesize msgView;

- (id)initWithFrame:(CGRect)frame message:(ChatMessageVO *)msg isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    
    if (self) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"ChatMessageWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        // FML: The reason why your custom fonts won't show is the textview must be Editable
        theFont = [UIFont fontWithName:@"NotoSans" size:13];
        self.msgView.font = theFont;
        self.msgView.userInteractionEnabled = NO;
        
        float ypos = kContentTop;
        float imageLeft = kContentLeft;
        if (msg.message != nil && msg.message.length > 0) {
            self.msgView.hidden = NO;
//            [self.msgView setFont:theFont];
            
            self.msgView.text = msg.message;
            
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
            
            self.dynamicHeight = ypos + estSize.height;
            NSLog(@"estSize vs. baseSize = %f // %f", estSize.height, baseSize.height);
            ypos += msgFrame.size.height + 5;
            
        } else {
            self.dynamicHeight = ypos;
            self.msgView.hidden = YES;
        }
        
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
            [self.timeLabel setTextColor:[UIColor colorWithHexValue:0x8496a0]];
            
            imageLeft += 7;
        }
        

        if (msg.photo != nil || msg.pfPhoto != nil) {
            CGRect photoFrame = CGRectMake(imageLeft, ypos, kContentWidth, kContentHeight);
            self.photoView = [[PFImageView alloc] initWithFrame:photoFrame];
            [self.photoView.layer setCornerRadius:8];
            [self.photoView.layer setMasksToBounds:YES];
            [self.photoView.layer setBorderWidth:1.0f];
            [self.photoView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [self.photoView setContentMode:UIViewContentModeScaleAspectFill];
            self.photoView.clipsToBounds = YES;
            
            if (msg.photo != nil) {
                [self.photoView setImage:msg.photo];
            }
            if (msg.pfPhoto != nil) {
                self.photoView.file = msg.pfPhoto;
                [self.photoView loadInBackground];
            }
            self.dynamicHeight += kContentHeight + 10;
            [self addSubview:self.photoView];
            [self bringSubviewToFront:self.photoView];
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
    return estSize;
}

@end
