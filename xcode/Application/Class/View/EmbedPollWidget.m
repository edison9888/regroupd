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

#define kInitialY   50
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  80

@implementation EmbedPollWidget


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
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedPollWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        
        float xpos = 0;
        float ypos = kInitialY;
        EmbedPollOption *embedOption = nil;
        CGRect itemFrame;
        int index=0;
        
        for (FormOptionVO* opt in formOptions) {
            index++;
            itemFrame = CGRectMake(xpos, ypos, kEmbedOptionWidth, kEmbedOptionHeight);
            embedOption = [[EmbedPollOption alloc] initWithFrame:itemFrame];
            [embedOption setIndex:index];
            embedOption.tag = k_CHAT_OPTION_BASETAG + index;
            embedOption.userInteractionEnabled = YES;

            embedOption.fieldLabel.text = opt.name;
            
            if (index == formOptions.count) {
                embedOption.divider.hidden = YES;
            }
            
            [self addSubview:embedOption];
            [options addObject:embedOption];
            
            ypos += kEmbedOptionHeight;
        }
        owner = NO;
        if (owner) {
            self.doneButton.hidden = YES;
        } else {
            itemFrame = self.doneButton.frame;
            itemFrame.origin.y = ypos;
            self.doneButton.frame = itemFrame;
            ypos += self.doneButton.frame.size.height;
        }
        
        NSLog(@"ypos ends at %f", ypos);
//        frame.size.height = ypos + 40;
//        _theView.frame = frame;
        self.dynamicHeight = ypos;
        
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
        int optionIndex = ((int) hitNum);
        NSLog(@"option index = %i", optionIndex);
        
        int i = 0;
        for (EmbedPollOption* opt in options) {
            if (i == optionIndex) {
                [opt selected];
            } else {
                [opt unselected];
            }
            i++;
        }
    }

}
- (IBAction)tapDoneButton {
    
}
@end
