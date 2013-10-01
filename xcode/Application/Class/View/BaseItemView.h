//
//  ViewTemplate.h
//  Autochrome
//

#import <UIKit/UIKit.h>

@interface BaseItemView : UIView {
	BOOL isInScrollWindow;
    UIView *subview;
}

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic) BOOL isInScrollWindow;

- (id)initWithFrame:(CGRect)frame andData:(NSDictionary *)data;
- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView;

- (void)willFocus;
- (void)willBlur;
- (void)willRemoveFromSuperview;
- (void)swapViews;

@end
