//
//  SelectedItemWidget.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <UIKit/UIKit.h>
#import "UIView+Resize.h"

@interface SelectedItemWidget : UIView {
    
}

@property (nonatomic, strong) UILabel *itemText;
@property (nonatomic, strong) UIButton *xButton;

- (void) setFieldLabel:(NSString *)label;


@end
