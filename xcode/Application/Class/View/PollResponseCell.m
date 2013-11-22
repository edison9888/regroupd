//
//  FormResponseCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "PollResponseCell.h"

@implementation PollResponseCell

@synthesize titleLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self.roundPic.layer setCornerRadius:23.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return @"PollResponseCell";
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
