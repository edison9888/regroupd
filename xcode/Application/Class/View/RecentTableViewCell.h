//
//  RecentTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"

@interface RecentTableViewCell : UITableViewCell {
    UILabel *name;
    UILabel *timestamp;
    UILabel *patient;
    UIImageView *arrowView;
    UIImageView *dotView;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *timestamp;
@property (nonatomic, retain) IBOutlet UILabel *patient;
@property (nonatomic, retain) IBOutlet UIImageView *arrowView;
@property (nonatomic, retain) IBOutlet UIImageView *dotView;

@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

- (IBAction)tapDelete;

//@property (nonatomic, retain) NSDictionary *rowdata;

- (void)setRowdata:(NSDictionary *)data inMode:(int)mode;

@end
