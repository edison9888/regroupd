//
//  PhotoScrollView.m
//
//  Created by Hugh Lang on 8/11/11.
//

#import "PhotoScrollView.h"

@implementation PhotoScrollView

- (id)initWithFrame:(CGRect)frame 
{
    return [super initWithFrame:frame];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    

}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    // If not dragging, send event to next responder
    if (!self.dragging) 
        [self.nextResponder touchesEnded: touches withEvent:event]; 
    else
        [super touchesEnded: touches withEvent: event];
}


@end
