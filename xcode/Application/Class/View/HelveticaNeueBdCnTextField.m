//
//  OpenSansTextField.m
//

#import "HelveticaNeueBdCnTextField.h"

@implementation HelveticaNeueBdCnTextField

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
    [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:self.font.pointSize]];
    
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;
}
@end
