//
//  BuyTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "BuyTableViewCell.h"

@implementation BuyTableViewCell

@synthesize name;
@synthesize buyButton;
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
    return @"BuyTableCell";
}
- (void)setRowdata:(BuyFaxData *)data
{
    rowdata = data;
    self.name.text = data.title;
    
}


////http://stackoverflow.com/questions/11920156/custom-uitableviewcell-selection-style
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    if (highlighted) {
        self.name.textColor = [UIColor blackColor];
    } else {
        self.name.textColor = [UIColor blackColor];
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
