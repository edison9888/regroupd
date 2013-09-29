//
//  ViewTemplate.h
//  Autochrome
//

#import <UIKit/UIKit.h>
#import "Page.h"

@interface BaseItemView : UIView {
	BOOL isInScrollWindow;
    UIView *subview;
}

@property (nonatomic, retain) Page *page;
@property (nonatomic) BOOL isInScrollWindow;

- (id)initWithFrame:(CGRect)frame andPage:(Page *)page;
- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView;

- (void)willFocus;
- (void)willBlur;
- (void)willRemoveFromSuperview;
- (void)swapViews;

@end
