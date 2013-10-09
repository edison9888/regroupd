//
//  EmbedPollWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedPollWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "FormOptionVO.h"

#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  80

@implementation EmbedPollWidget

- (id)initWithOptions:(NSMutableArray *)formOptions
{
    NSLog(@"===== %s", __FUNCTION__);
   self = [super init];
    if (self) {
        options = formOptions;
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedPollWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        float xpos = 0;
        float ypos = 60;
        EmbedPollOption *embedOption = nil;
        CGRect embedFrame;
        
        for (FormOptionVO* opt in formOptions) {
            embedFrame = CGRectMake(xpos, ypos, kEmbedOptionWidth, kEmbedOptionHeight);
            embedOption = [[EmbedPollOption alloc] initWithFrame:embedFrame];
            embedOption.fieldLabel.text = opt.name;
            [self addSubview:embedOption];
            ypos += kEmbedOptionHeight;
        }
//        [self.inputHolder.layer setb
                
        [self addSubview:_theView];
    }
    return self;
}

- (IBAction)tapDoneButton {
    
}
@end
