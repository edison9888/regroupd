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

#define LEFT_EDITING_MARGIN 20
#define RIGHT_EDITING_MARGIN 0


@implementation GroupTableViewCell

@synthesize titleLabel;
//@synthesize rowdata;


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

//- (void)setRowdata:(NSDictionary *)data
//{
//    rowdata = data;
//    self.titleLabel.text = [data objectForKey:@"name"];
//    NSString *datetext = (NSString *) [data objectForKey:@"updated"];
//    NSDate *updatedAt = [DateTimeUtils dateFromDBDateStringNoOffset:datetext];
//    datetext = [DateTimeUtils formatDecimalDate:updatedAt];
//    self.dateLabel.text = datetext;
//
//}

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
- (void)layoutSubviews {
    [super layoutSubviews];
    self.accessoryView.frame = CGRectMake(self.accessoryView.frame.origin.x + 15, 0, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
//    self.accessoryView.frame.origin.x = 20;
}
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
////    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
//    
////    if (self.editing && self.contentView.frame.origin.x != 0) {
////        NSLog(@"%s", __FUNCTION__);
////
////        CGRect frame = self.contentView.frame;
////        CGFloat diff = LEFT_EDITING_MARGIN - frame.origin.x;
////        frame.origin.x = LEFT_EDITING_MARGIN;
////        frame.size.width -= diff;
////        self.contentView.frame = frame;
////    }
//}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    
    NSLog(@"%s state=%i", __FUNCTION__, state);
    // See: http://stackoverflow.com/questions/1615469/custom-delete-button-on-editing-in-uitableview-cell
    // http://stackoverflow.com/questions/18647097/how-can-i-make-a-custom-view-of-the-delete-button-when-performing-commiteditin
    
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
            NSLog(@"============= Delete mode");
        if (self.editing && self.contentView.frame.origin.x != 0) {
            CGRect frame = self.contentView.frame;
//            CGFloat diff = RIGHT_EDITING_MARGIN - frame.origin.x;
        
            frame.origin.x = 0;
            frame.size.width -= 100;
            self.contentView.frame = frame;
        }
    }
}
@end
