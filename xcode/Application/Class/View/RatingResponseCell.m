//
//  FormResponseCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "RatingResponseCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation RatingResponseCell

@synthesize titleLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];//    NSLog(@"initWithCoder");
    NSLog(@"%s", __FUNCTION__);
    
    [self.roundPic.layer setCornerRadius:23.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:1.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    
    self.roundPic.layer.shadowColor = [UIColor grayColor].CGColor;
    self.roundPic.layer.shadowOffset = CGSizeMake(0, 1);
    self.roundPic.layer.shadowOpacity = 1;
    self.roundPic.layer.shadowRadius = 2.0;
    
    CGRect sliderFrame = self.titleLabel.frame;
    sliderFrame.origin.y += 24;
    sliderFrame.size.height = 14;
    
    self.ratingSlider = [[RatingMeterSlider alloc] initWithFrame:sliderFrame];
    [self.ratingSlider setSliderColor:[UIColor colorWithHexValue:0x28cfea]];
    [self.ratingSlider setDotColor:[UIColor colorWithHexValue:0x1daac1]];
    [self.ratingSlider setBGColor:[UIColor colorWithHexValue:0xeae9e9]];
    
    [self addSubview:self.ratingSlider];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"%s", __FUNCTION__);
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return @"RatingResponseCell";
}


////http://stackoverflow.com/questions/11920156/custom-uitableviewcell-selection-style
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.titleLabel.textColor = [UIColor blackColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    [super setHighlighted:highlighted animated:animated];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}
@end
