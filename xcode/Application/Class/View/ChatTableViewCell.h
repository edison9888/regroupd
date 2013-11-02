//
//  ChatTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"
#import "ChatVO.h"

@interface ChatTableViewCell : UITableViewCell {
    UILabel *titleLabel;
    
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) ChatVO *rowdata;


@end
