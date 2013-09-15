//
//  SectionControllerComponent.m
//  Incivek
//
//

#import "SectionControllerComponent.h"


@implementation SectionControllerComponent
@synthesize sectionViews = _sectionViews;


- (void)switchToSection:(NSInteger)iSection
{
    if (iSection >= _sectionViews.count) {
        return;
    }
    
}

#pragma mark BaseViewController overrides

- (void)setComponentData:(NSMutableDictionary *)componentData
{
	[super setComponentData:componentData];
}

- (void)resetComponent
{
}

- (void)startComponent
{
    [super startComponent];
    
    UIView *view = [_sectionViews objectAtIndex:0];
    [self addSubview:view];
}

- (void)stopComponent
{
    [super stopComponent];
}

@end
