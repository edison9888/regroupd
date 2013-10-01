//
//  ScrollOptionView.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "ScrollOptionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ScrollOptionView

- (id)initWithFrame:(CGRect)frame andData:(NSDictionary *)pageData {
    NSLog(@"===== %s", __FUNCTION__);
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		isInScrollWindow = NO;
        self.data = pageData;

        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"ScrollOptionView" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        NSString *imagefile = (NSString *) [self.data objectForKey:@"imagefile"];
        UIImage *img = [UIImage imageNamed:imagefile];
        self.roundPic.image = img;
        
        [self.roundPic.layer setCornerRadius:96.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:2.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_theView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
    if (self) {
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"ScrollOptionView" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        [self.roundPic.layer setCornerRadius:96.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:2.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

        [self addSubview:_theView];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ((self = [super init])) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"ScrollOptionView" owner:self options:nil] objectAtIndex:0];
    }
    
    return self;
}

- (void) setPhoto:(UIImage *)photo {
    NSLog(@"%s", __FUNCTION__);
    self.roundPic.image = photo;
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
