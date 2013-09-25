//
//  SurveyOptionWithPic.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "SurveyOptionWithPic.h"

@implementation SurveyOptionWithPic

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super initWithFrame:frame];
    if (self) {
                
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"SurveyOptionWithPic" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_theView];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ((self = [super init])) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"SurveyOptionWithPic" owner:self options:nil] objectAtIndex:0];
    }
    
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
