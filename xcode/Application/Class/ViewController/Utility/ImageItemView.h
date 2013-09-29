//
//  WebViewTemplate.h
//  Autochrome
//

#import <UIKit/UIKit.h>
#import "BaseItemView.h"

@interface ImageItemView : BaseItemView {
	UIImageView *imageView;
}

@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame andProduct:(Product *)product;

- (void)swapViews;


@end
