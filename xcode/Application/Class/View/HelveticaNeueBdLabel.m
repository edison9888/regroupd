//
//  NewsGothicBoldLabel.m
//  Blocpad
//
//  Created by Hugh Lang on 4/4/13.
//
//

#import "HelveticaNeueBdLabel.h"

@implementation HelveticaNeueBdLabel

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:self.font.pointSize]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    // Font naming convention
    // See: http://stackoverflow.com/questions/13104770/ios-custom-fonts-not-working
    [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:self.font.pointSize]];
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
