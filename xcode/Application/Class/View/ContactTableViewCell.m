//
//  ContactTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

@synthesize titleLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return @"ContactTableCell";
}


////http://stackoverflow.com/questions/11920156/custom-uitableviewcell-selection-style
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    if (highlighted) {
        self.titleLabel.textColor = [UIColor blackColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    [super setHighlighted:highlighted animated:animated];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    [super setSelected:selected animated:animated];

}
@end
