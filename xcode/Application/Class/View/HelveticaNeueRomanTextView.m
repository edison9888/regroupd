//
//  NewsGothicTextView.m
//  Blocpad
//
//  Created by Hugh Lang on 4/5/13.
//
//

#import "HelveticaNeueRomanTextView.h"

@implementation HelveticaNeueRomanTextView

-(id)init {
    NSLog(@"%s", __FUNCTION__);
    self = [super init];
    if (self) {
        // Initialization code
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

@end
