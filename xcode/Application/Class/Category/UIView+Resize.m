//
//  UIView+Resize.m
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//  http://blog.carbonfive.com/2009/07/10/resizing-uilabel-to-fit-text/

#import "UIView+Resize.h"

@implementation UIView (Resize)

- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink {
    CGRect frame = [theLabel frame];
    CGSize size = [theLabel.text sizeWithFont:theLabel.font
                            constrainedToSize:CGSizeMake(frame.size.width, 9999)
                                lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat delta = size.height - frame.size.height;
    frame.size.height = size.height;
    [theLabel setFrame:frame];
    
    CGRect contentFrame = self.frame;
    contentFrame.size.height = contentFrame.size.height + delta;
    if(canShrink || delta > 0) {
        [self setFrame:contentFrame];
    }
    return delta;
}

- (CGFloat) resizeLabel:(UILabel *)theLabel {
    return [self resizeLabel:theLabel shrinkViewIfLabelShrinks:YES];
}

@end