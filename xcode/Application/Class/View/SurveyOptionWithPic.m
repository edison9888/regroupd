//
//  SurveyOptionWithPic.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "SurveyOptionWithPic.h"
#import <QuartzCore/QuartzCore.h>

@implementation SurveyOptionWithPic

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super initWithFrame:frame];
    if (self) {
                
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"SurveyOptionWithPic" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        [self.roundPic.layer setCornerRadius:30.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

        self.photoHolder.hidden = YES;

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

- (IBAction)tapPickPhoto {
    NSLog(@"%s", __FUNCTION__);
    NSNumber *num = [NSNumber numberWithInt:self.index];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification
                                                            notificationWithName:@"showImagePickerNotification"
                                                            object:num]];
    
}
- (void) setPhoto:(UIImage *)photo {
    NSLog(@"%s", __FUNCTION__);
    self.photoHolder.hidden = NO;
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
