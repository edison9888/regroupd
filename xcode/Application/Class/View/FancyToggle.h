//
//  FormOptionCheckbox.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"

@interface FancyToggle : UIView {
    uint bgColorSelected;
    
    UIView *_theView;
}


@property BOOL isOn;

@property (nonatomic, strong) IBOutlet UIImageView *onIcon;
@property (nonatomic, strong) IBOutlet UIImageView *offIcon;
@property (nonatomic, strong) IBOutlet UIImageView *switchIcon;

- (void) toggle;
- (void) selected;
- (void) unselected;

@end
