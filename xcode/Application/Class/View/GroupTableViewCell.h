//
//  GroupTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"
#import "ChatVO.h"
#import "AltLabel.h"

@interface GroupTableViewCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UIImageView *iconStatus;

@property (nonatomic, retain) IBOutlet AltLabel *titleLabel;
@property (nonatomic, retain) IBOutlet AltLabel *dateLabel;

@property (nonatomic, retain) NSDictionary *rowdata;

- (void) setStatus:(int)status;

@end
