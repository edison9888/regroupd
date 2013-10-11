//
//  EmbedRSVPOption.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRSVPOption.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"


@implementation EmbedRSVPOption

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super initWithFrame:frame];
    if (self) {
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRSVPOption" owner:self options:nil] objectAtIndex:0];
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

- (void) setIndex:(int)index {
    _index = index;
    self.tag = k_CHAT_OPTION_BASETAG + index;
    
    
}

- (void) resizeHeight:(float)height {

}


@end
