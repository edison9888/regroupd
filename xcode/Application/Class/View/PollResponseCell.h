//
//  FormResponseCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "ContactVO.h"

@interface PollResponseCell : UITableViewCell {
    BrandUILabel *titleLabel;
    
}
@property (nonatomic, strong) IBOutlet PFImageView *roundPic;

@property (nonatomic, retain) IBOutlet BrandUILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@end
