//
//  UIView+Resize.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <UIKit/UIKit.h>

@interface UIView (Resize)

- (CGFloat) resizeLabel:(UILabel *)theLabel;

- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink;

@end