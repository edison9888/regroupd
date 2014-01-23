//
//  ContactHeadingCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "ContactHeadingCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation ContactHeadingCell

@synthesize titleLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.layer.backgroundColor = [UIColor colorWithHexValue:0x0D7DAC].CGColor;
        self.contentView.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return kContactHeadingCell_ID;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}
@end
