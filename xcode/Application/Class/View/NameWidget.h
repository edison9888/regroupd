//
//  SelectedItemWidget.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <UIKit/UIKit.h>
#import "UIView+Resize.h"
#import "WidgetStyle.h"

#define kNameWidgetRowHeight  30
#define kNameWidgetGap  5

@interface NameWidget : UIView {
    UIColor *bgColor;
    UIFont *theFont;
}
- (id)initWithFrame:(CGRect)frame andStyle:(WidgetStyle *)widgetStyle;

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIImageView *rightIcon;

@property (nonatomic, retain) UIButton *clearButton;
@property (nonatomic, retain) NSString *itemKey;

- (void) setupButton:(NSString *)key;

- (void) setFieldLabel:(NSString *)label;
- (void) setIcon:(UIImage *)image;


@end
