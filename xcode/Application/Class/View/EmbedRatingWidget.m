//
//  EmbedRatingWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRatingWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "FormOptionVO.h"
#import "FormManager.h"

#define kInitialY   55
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  90

@implementation EmbedRatingWidget


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
//
//- (id)initWithOptions:(NSMutableArray *)formOptions
//{
//    NSLog(@"===== %s", __FUNCTION__);
//   self = [super init];
    if (self) {
        options = [[NSMutableArray alloc] initWithCapacity:formOptions.count];
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRatingWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        float xpos = 0;
        float ypos = kInitialY;
        EmbedRatingOption *embedOption = nil;
        CGRect itemFrame;
        int index=0;
        FormManager *formSvc = [[FormManager alloc]init];

        for (FormOptionVO* opt in formOptions) {
            index++;
            itemFrame = CGRectMake(xpos, ypos, kEmbedOptionWidth, kEmbedOptionHeight);
            embedOption = [[EmbedRatingOption alloc] initWithFrame:itemFrame];
            [embedOption setIndex:index];
            embedOption.tag = k_CHAT_OPTION_BASETAG + index;
            embedOption.userInteractionEnabled = YES;

            embedOption.fieldLabel.text = opt.name;
            [embedOption setRating:5];

            if (opt.imagefile != nil && opt.imagefile.length > 0) {
                UIImage *img = nil;
                img = [formSvc loadFormImage:opt.imagefile];
                embedOption.roundPic.image =img;
            }
            
            if (index == formOptions.count) {
                embedOption.divider.hidden = YES;
                ypos += kEmbedOptionHeight;
                
            } else {
                ypos += kEmbedOptionHeight;
            }
            
            [self addSubview:embedOption];
            [options addObject:embedOption];
            
        }
        if (owner) {
            self.doneButton.hidden = YES;
            formLocked = YES;
        } else {
            formLocked = NO;
            self.doneButton.enabled = YES;
            
            itemFrame = self.doneView.frame;
            itemFrame.origin.y = ypos;
            self.doneView.frame = itemFrame;
            ypos += self.doneView.frame.size.height;
        }
        
        self.dynamicHeight = ypos + 10;
        
        [self addSubview:_theView];
        
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    [super touchesBegan:touches withEvent:event];
//    [self.nextResponder touchesBegan:touches withEvent:event];
    CGPoint locationPoint = [[touches anyObject] locationInView:self];

    float hitY = locationPoint.y;
    float hitNum = (hitY - kInitialY) / kEmbedOptionHeight;
    NSLog(@"y = %f", hitNum);
    
    if (hitNum > 0 && hitNum < options.count) {
        if (!formLocked) {
            self.doneButton.enabled = YES;
            
            int optionIndex = ((int) hitNum);
            NSLog(@"option index = %i", optionIndex);
            
            int i = 0;
            for (EmbedRatingOption* opt in options) {
//                if (i == optionIndex) {
//                    [opt selected];
//                } else {
//                    [opt unselected];
//                }
                i++;
            }
        }
    }

}
- (IBAction)tapDoneButton {
    self.dynamicHeight -= self.doneButton.frame.size.height;
    self.doneButton.enabled = NO;
    formLocked = YES;
}
@end
