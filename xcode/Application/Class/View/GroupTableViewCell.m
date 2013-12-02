//
//  GroupTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "GroupTableViewCell.h"
#import "DateTimeUtils.h"

#define kIconChatOff @"icon_chat_off.png"
#define kIconChatOn @"icon_chat_on.png"

@implementation GroupTableViewCell

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
    return @"GroupTableCell";
}

- (void)setRowdata:(NSDictionary *)data
{
    rowdata = data;
    self.titleLabel.text = [data objectForKey:@"name"];
    NSString *datetext = (NSString *) [data objectForKey:@"updated"];
    NSDate *updatedAt = [DateTimeUtils dateFromDBDateStringNoOffset:datetext];
    datetext = [DateTimeUtils formatDecimalDate:updatedAt];
    self.dateLabel.text = datetext;

}
- (void) setStatus:(int)status {
    
    if (status == 0) {
        self.iconStatus.image = [UIImage imageNamed:kIconChatOff];
        
    } else {
        self.iconStatus.image = [UIImage imageNamed:kIconChatOn];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
