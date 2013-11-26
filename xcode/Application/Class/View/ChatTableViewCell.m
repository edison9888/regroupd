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
}
- (void) setStatus:(int)status {
    
    if (status == 0) {
        self.iconStatus.image = [UIImage imageNamed:kIconChatOff];
        
    } else {
        self.iconStatus.image = [UIImage imageNamed:kIconChatOn];
    }
}

////http://stackoverflow.com/questions/11920156/custom-uitableviewcell-selection-style
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//#ifdef DEBUGX
//    NSLog(@"%s", __FUNCTION__);
//#endif
//    if (highlighted) {
//        self.titleLabel.textColor = [UIColor blackColor];
//    } else {
//        self.titleLabel.textColor = [UIColor blackColor];
//    }
////    [super setHighlighted:<#highlighted#> animated:<#animated#>];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
