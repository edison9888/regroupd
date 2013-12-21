//
//  ChatTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "ChatTableViewCell.h"

#define kIconChatOff @"icon_chat_off.png"
#define kIconChatOn @"icon_chat_on.png"

@implementation ChatTableViewCell

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
    return @"ChatTableCell";
}
- (void)setRowdata:(ChatVO *)chat
{
    rowdata = chat;
    self.titleLabel.text = chat.names;
//    if (chat.names != nil) {
//        self.titleLabel.text = chat.names;
//    } else {
//        self.titleLabel.text = chat.name;
//    }
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
