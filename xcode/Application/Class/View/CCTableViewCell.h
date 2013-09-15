//
//  CCTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"

@interface CCTableViewCell : UITableViewCell {
    UILabel *titleLabel;
    
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) NSDictionary *rowdata;


@end
