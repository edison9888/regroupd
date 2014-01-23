//
//  ContactHeadingCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"
#import "BrandUILabel.h"

#define kContactHeadingCell_ID  @"ContactHeadingCell_ID"

@interface ContactHeadingCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet BrandUILabel *titleLabel;

@end
