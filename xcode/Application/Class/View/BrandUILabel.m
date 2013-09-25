//
//  BrandUILabel.m
//  Regroupd
//
//  Created by Hugh Lang on 9/14/13.
//
//

#import "BrandUILabel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation BrandUILabel

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
    
    
    [self setFont:[UIFont fontWithName:@"Raleway-Bold" size:self.font.pointSize]];
//    self.textColor = [UIColor whiteColor];
//    self.textAlignment = UITextAlignmentCenter;
    
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
