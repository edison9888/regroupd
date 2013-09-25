//
//  FormOptionCheckbox.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"

@interface FancyCheckbox : UIView {
    uint bgColorSelected;
    UIImage *onImage;
    UIImage *offImage;
    
    UIView *_theView;
}
@property int viewId;
@property (nonatomic, strong) IBOutlet BrandUILabel *ckLabel;
@property (nonatomic, strong) IBOutlet UIImageView *ckIcon;

- (void) selected;
- (void) unselected;

@end
