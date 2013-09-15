//
//  CCTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "CCTableViewCell.h"

@implementation CCTableViewCell

@synthesize titleLabel;
@synthesize rowdata;


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
    return @"CCTableCell";
}
- (void)setRowdata:(NSDictionary *)data
{
    rowdata = data;
    self.titleLabel.text = [data objectForKey:@"name"];
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
//    [super setHighlighted:<#highlighted#> animated:<#animated#>];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
