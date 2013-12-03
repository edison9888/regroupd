//
//  GroupContactCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"
#import "ChatVO.h"
#import "AltLabel.h"

@interface GroupContactCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UIImageView *iconStatus;

@property (nonatomic, retain) IBOutlet AltLabel *titleLabel;

@property (nonatomic, retain) NSDictionary *rowdata;

@property int cellStatus;

- (void) setStatus:(int)status;

@end
