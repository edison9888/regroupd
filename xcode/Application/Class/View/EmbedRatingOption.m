//
//  EmbedRatingOption.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRatingOption.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

#define kSelectedColor      0x8755a2   //purple
#define kDotColor           0x613976  // dark purple
#define kUnselectedColor    0x68747b  // grey
#define kFadedAlpha     0.8f

@implementation EmbedRatingOption

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super initWithFrame:frame];
    if (self) {
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRatingOption" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        _theView.userInteractionEnabled = YES;
//        [self.inputHolder.layer setb
                
        [self.roundPic.layer setCornerRadius:32.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
        self.sliderGuide.alpha = 0;
        
        [self addSubview:_theView];
    }
    return self;
}

- (void) setRating:(float)value {
    self.ratingValue.text = [NSString stringWithFormat:@"%i",
    [NSNumber numberWithFloat:value].intValue];
    
    if (self.slider == nil) {
        CGRect sliderFrame = self.sliderGuide.frame;
        self.slider = [[RatingMeterSlider alloc] initWithFrame:sliderFrame];
        [self.slider setSliderColor:[UIColor colorWithHexValue:kSelectedColor]];
        [self.slider setDotColor:[UIColor colorWithHexValue:kDotColor]];
        [self addSubview:self.slider];
        [self.slider setRatingBar:value];
        
    } else {
        [self.slider setRatingBar:value];
    }
    
}
- (void) setIndex:(int)index {
    _index = index;
    self.tag = k_CHAT_OPTION_BASETAG + index;
    
    
}

- (void) resizeHeight:(float)height {
    
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
