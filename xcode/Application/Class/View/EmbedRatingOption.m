//
//  EmbedRatingOption.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRatingOption.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"


@implementation EmbedRatingOption

@synthesize theRating;

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

        //        self.sliderGuide.alpha = 0;
        
        self.fancySlider.enabled = YES;
        self.fancySlider.userInteractionEnabled = YES;
        self.fancySlider.clipsToBounds = YES;
        [self bringSubviewToFront:self.fancySlider];
        [self addSubview:_theView];
    }
    return self;
}

-(IBAction)sliderValueChanged:(UISlider *)sender
{
    int rating = ceil(sender.value * 10);
    self.ratingValue.text = [NSNumber numberWithInt:rating].stringValue;
    self.theRating = [NSNumber numberWithInt:rating];
}

- (void) setRating:(NSNumber *)value {
    self.theRating = value;
    
//    int rating = ceil(value.intValue);
    self.ratingValue.text = self.theRating.stringValue;

    self.fancySlider.value = self.theRating.floatValue / 10;
}

- (float) getRating {
    return _rating;
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
