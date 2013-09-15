//
//  FaxTemplateView.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import "FaxTemplateView.h"

@implementation FaxTemplateView

@synthesize rcptName, rcptPhone, rcptFax, senderName, senderPhone, senderFax;
@synthesize company, street, city, state, zip;
@synthesize orderDate, orderText;
@synthesize patient;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"FaxTemplateView" owner:self options:nil] objectAtIndex:0];
        [self addSubview:_theView];
        
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
