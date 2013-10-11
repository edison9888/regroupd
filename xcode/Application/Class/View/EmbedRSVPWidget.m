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

@implementation EmbedRSVPWidget


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
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRSVPWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        self.doneButton.enabled = NO;
        
        float ypos = kInitialY;
        
        if (owner) {
            self.doneButton.hidden = YES;
            formLocked = YES;
            ypos = self.frame.size.height - 40;
        } else {
            formLocked = NO;
            
//            itemFrame = self.doneButton.frame;
//            itemFrame.origin.y = ypos;
//            self.doneButton.frame = itemFrame;
            ypos = self.frame.size.height;
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
    

}
- (IBAction)tapDoneButton {
    self.dynamicHeight -= self.doneButton.frame.size.height;
    self.doneButton.enabled = NO;
    formLocked = YES;
}
@end
