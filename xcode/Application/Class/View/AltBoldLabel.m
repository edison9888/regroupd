//
//  AltBoldLabel.m
//  Re:group'd
//
//  Created by Hugh Lang on 11/30/13.
//
//

#import "AltBoldLabel.h"

@implementation AltBoldLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:[UIFont fontWithName:@"Raleway-Bold" size:self.font.pointSize]];
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
