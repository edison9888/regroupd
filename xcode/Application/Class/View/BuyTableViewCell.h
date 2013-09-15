//
//  BuyTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ContactVO.h"
#import "BuyFaxData.h"

@interface BuyTableViewCell : UITableViewCell {
    UILabel *name;
    UIButton *buyButton;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;

@property (nonatomic, retain) BuyFaxData *rowdata;


@end
