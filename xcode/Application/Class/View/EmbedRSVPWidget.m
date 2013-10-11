//
//  EmbedRSVPWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRSVPWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "FormOptionVO.h"

#define kInitialY   50
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  100
#define kTagOption1     101
#define kTagOption2     102
#define kTagOption3     103
#define kTagDone     199

#define kCheckboxOnImage    @"poll_checkbox_on"
#define kCheckboxOffImage   @"poll_checkbox"


@implementation EmbedRSVPWidget


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    
    if (self) {
        
        offFont = [UIFont fontWithName:@"Raleway-Regular" size:14];
        onFont = [UIFont fontWithName:@"Raleway-Bold" size:14];
        
        offCheckbox = [UIImage imageNamed:kCheckboxOffImage];
        onCheckbox = [UIImage imageNamed:kCheckboxOnImage];
//        self.hotspot1.backgroundColor = [UIColor clearColor];
//        self.hotspot2.backgroundColor = [UIColor clearColor];
//        self.hotspot3.backgroundColor = [UIColor clearColor];
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRSVPWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];

        
        [self.roundPic.layer setCornerRadius:36.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

        
        float ypos = kInitialY;
        
        if (owner) {
            self.doneButton.hidden = YES;
            formLocked = YES;
            ypos = self.frame.size.height - 40;
        } else {
            formLocked = NO;
            self.doneButton.enabled = YES;
            
            ypos = self.frame.size.height;
        }
        self.dynamicHeight = ypos + 10;
        
        
        [self addSubview:_theView];

//        UIImage *detailsImage = [UIImage imageNamed:@"see_details"];
//        CGRect detailsFrame = CGRectMake(self.headerView.frame.origin.x + 100, self.headerView.frame.origin.y + 70, 143, 41);
//
//        UIView *detailsView = [[UIView alloc] initWithFrame:detailsFrame];
//        detailsView.backgroundColor = [UIColor orangeColor];
        
//        UIButton *detailsButton;
//        detailsButton = [[UIButton alloc] init];
//        detailsButton.imageView.image = detailsImage;
//        
//        detailsButton.frame = detailsFrame;
//        [self addSubview:detailsView];
        
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    
    float hitY = locationPoint.y;
    float hitNum = (hitY - kInitialY) / kEmbedOptionHeight;
    NSLog(@"y = %f", hitNum);
    
    UIView* hitView = [self hitTest:locationPoint withEvent:event];
    NSLog(@"hitView.tag = %i", hitView.tag);
    
    switch (hitView.tag) {
        case kTagOption1:
        {
            self.checkbox1.image = onCheckbox;
            self.label1.font = onFont;
            self.checkbox2.image = offCheckbox;
            self.label2.font = offFont;
            self.checkbox3.image = offCheckbox;
            self.label3.font = offFont;
            
            break;
        }
        case kTagOption2:
        {
            self.checkbox1.image = offCheckbox;
            self.label1.font = offFont;
            self.checkbox2.image = onCheckbox;
            self.label2.font = onFont;
            self.checkbox3.image = offCheckbox;
            self.label3.font = offFont;
            break;
        }
        case kTagOption3:
        {
            self.checkbox1.image = offCheckbox;
            self.label1.font = offFont;
            self.checkbox2.image = offCheckbox;
            self.label2.font = offFont;
            self.checkbox3.image = onCheckbox;
            self.label3.font = onFont;
            break;
        }
            
    }

}
- (IBAction)tapDoneButton {
    self.dynamicHeight -= self.doneButton.frame.size.height;
    self.doneButton.enabled = NO;
    formLocked = YES;
}
@end
