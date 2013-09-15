//
//  HelveticaNeueMdCnLabel.m
//  Blocpad
//
//  Created by Hugh Lang on 4/15/13.
//
//

#import "HelveticaNeueMdCnLabel.h"

@implementation HelveticaNeueMdCnLabel

-(id)initWithSize:(int)pointSize {
    self = [super init];
    if (self) {
        // Initialization code
        [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:pointSize]];
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:self.font.pointSize]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:self.font.pointSize]];
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
}

@end
