//
//  GroupContactCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "GroupContactCell.h"

#define kIconStatusOff @"group_check_off.png"
#define kIconStatusOn @"group_check_on.png"

@implementation GroupContactCell

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
    return @"GroupContactCell";
}

- (void)setRowdata:(NSDictionary *)data
{
    rowdata = data;
    self.titleLabel.text = [data objectForKey:@"name"];

}
- (void) setStatus:(int)status {

    self.cellStatus = status;
    
    if (status == 0) {
        self.iconStatus.image = [UIImage imageNamed:kIconStatusOff];
        
    } else {
        
        self.iconStatus.image = [UIImage imageNamed:kIconStatusOn];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
