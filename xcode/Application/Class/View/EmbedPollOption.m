//
//  EmbedPollOption.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedPollOption.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

#define kCheckboxOnImage    @"poll_checkbox_on@2x.png"
#define kCheckboxOffImage   @"poll_checkbox@2x.png"
#define kSelectedColor      0x8755a2   //purple
#define kUnselectedColor    0x68747b  // grey
#define kFadedAlpha     0.8f

@implementation EmbedPollOption

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super initWithFrame:frame];
    if (self) {
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedPollOption" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        _theView.userInteractionEnabled = YES;
//        [self.inputHolder.layer setb
                
        [self.roundPic.layer setCornerRadius:32.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

        [self addSubview:_theView];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ((self = [super init])) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedPollOption" owner:self options:nil] objectAtIndex:0];
    }
    
    return self;
}

- (void) setIndex:(int)index {
    _index = index;
    self.tag = k_CHAT_OPTION_BASETAG + index;
    
    
}

- (void) selected {
    self.isSelected = YES;
    self.inputHolder.backgroundColor = [UIColor colorWithHexValue:kSelectedColor];
    self.checkbox.image = [UIImage imageNamed:kCheckboxOnImage];
    self.fieldLabel.alpha = 1.0;
    
}
- (void) unselected {
    self.isSelected = NO;
    self.inputHolder.backgroundColor = [UIColor colorWithHexValue:kUnselectedColor];
    self.checkbox.image = [UIImage imageNamed:kCheckboxOffImage];
    self.fieldLabel.alpha = kFadedAlpha;
}

- (void) resizeHeight:(float)height {
    
//    CGRect inputFrame = CGRectMake(self.input.frame.origin.x,
//                                   self.input.frame.origin.y,
//                                   self.input.frame.size.width,
//                                   height);
//    self.input.frame = inputFrame;

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
