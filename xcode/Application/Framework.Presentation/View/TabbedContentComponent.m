//
//  TabbedContentComponent.m
//
//

#import "TabbedContentComponent.h"

@implementation TabbedContentComponent
@synthesize contentImageView = _contentImageView;
@synthesize componentButtons = _componentButtons;


#pragma mark BaseViewController overrides

- (void)setComponentData:(NSMutableDictionary *)componentData {
	[super setComponentData:componentData];
    
}

- (void)startComponent
{
    [super startComponent];
    
    for (UIButton *button in _componentButtons) {
        [button addTarget:self 
                   action:@selector(buttonTapped:) 
         forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (int i = 0; i < [_componentButtons count]; i++) {
        [[_componentButtons objectAtIndex:i] setBackgroundImage:[[_componentButtons objectAtIndex:i] backgroundImageForState:UIControlStateSelected]
                                                       forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}

- (void)buttonTapped:(id)sender
{
    for (int i = 0; i < [_componentButtons count]; i++) {
        if ([[_componentButtons objectAtIndex:i] isSelected]) {
            [[_componentButtons objectAtIndex:i]setSelected:NO];
            break;
        }
    }
    
    [sender setSelected:YES];
    
    NSArray *contentImages = [self.componentData objectForKey:@"contentImages"];
    UIImage *image1 = [_contentImageView image];
    NSInteger buttonIndex = [_componentButtons indexOfObject:sender];
    UIImage *image2 = [UIImage imageNamed:[contentImages objectAtIndex:buttonIndex]];
    
    CABasicAnimation *crossfade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossfade.duration  = 0.5;
    crossfade.fromValue = image1;
    crossfade.toValue   = image2;
    [self.contentImageView.layer addAnimation:crossfade forKey:@"contents"];
    
    [_contentImageView setImage:image2];
}

@end
