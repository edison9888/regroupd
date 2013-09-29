//
//  ViewTemplate.h
//  Autochrome
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface BaseItemView : UIView {
	BOOL isInScrollWindow;
    UIView *subview;
}

@property (nonatomic, retain) Product *product;
@property (nonatomic) BOOL isInScrollWindow;

- (id)initWithFrame:(CGRect)frame andProduct:(Product *)product;
- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView;

- (void)willFocus;
- (void)willBlur;
- (void)willRemoveFromSuperview;
- (void)swapViews;

@end
