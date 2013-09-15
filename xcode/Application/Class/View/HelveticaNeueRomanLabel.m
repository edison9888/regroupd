//
//  OpenSansLabel.m
//

#import "HelveticaNeueRomanLabel.h"

@implementation HelveticaNeueRomanLabel

-(id)init {
    self = [super init];
    if (self) {
        [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:self.font.pointSize]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithCoder:aDecoder];
    [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:self.font.pointSize]];
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

- (void)setText:(NSString *)text {
  [super setText:text];
}

@end
