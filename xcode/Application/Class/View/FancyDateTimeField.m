//
//  FancyDateTimeField.m
//  Regroupd
//
//  Created by Hugh Lang on 9/27/13.
//
//

#import "FancyDateTimeField.h"

@implementation FancyDateTimeField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setIcon:(UIImage *)image {
    __leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    __leftView.image = image;
    //[self addSubview:__leftView];
    //[self bringSubviewToFront:__leftView];
    [self setLeftView:__leftView];
    [self setLeftViewMode:UITextFieldViewModeAlways];
}

// See: http://vodpodgeekblog.wordpress.com/2011/03/04/ios-trick-add-padding-to-a-uitextlabel/
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 26, bounds.origin.y + 4,
                      bounds.size.width - 30, bounds.size.height - 8);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}


@end
