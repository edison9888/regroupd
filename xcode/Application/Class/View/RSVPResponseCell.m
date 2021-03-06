//
//  FormResponseCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "RSVPResponseCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RSVPResponseCell

@synthesize titleLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"%s", __FUNCTION__);
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"%s", __FUNCTION__);

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self.roundPic.layer setCornerRadius:23.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
//        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
        
        self.roundPic.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.roundPic.layer.shadowOffset = CGSizeMake(1, 1);
        self.roundPic.layer.shadowOpacity = 1;
        self.roundPic.layer.shadowRadius = 1.0;
        self.roundPic.clipsToBounds = NO;
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return @"RSVPResponseCell";
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
