//
//  AquaTableViewCell.m
//  Re:group'd
//
//  Created by Hugh Lang on 10/7/13.
//
//

#import "AquaTableViewCell.h"
#import "UIColor+ColorWithHex.h"

@implementation AquaTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = YES;
        
        // Initialization code
        [self.textLabel setFont:[UIFont fontWithName:@"Raleway-Regular" size:14.0]];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        [self setBackgroundColor:[UIColor colorWithHexValue:0x28cfea]];
        
        [self.layer setBorderWidth:0];
        UIImageView *borderLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hbar_dark_grey"]];
        borderLine.alpha = 0.5;
        CGRect borderFrame = self.frame;
        borderFrame.size.height = 1;
        borderFrame.origin.y = 49;
        borderLine.frame = borderFrame;
        
        [self addSubview:borderLine];
        
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
