//
//  BrandUIButton.m
//  Regroupd
//
//  Created by Hugh Lang on 9/16/13.
//
//

#import "BrandUIButton.h"

@implementation BrandUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:self.titleLabel.font.pointSize]];

    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
