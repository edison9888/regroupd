//
//  SectionControllerComponent.h
//  Incivek
//
//

#import <Foundation/Foundation.h>
#import "PopOverComponent.h"

@interface SectionControllerComponent : PopOverComponent {
	NSArray			*_sectionViews;
}

- (void)switchToSection:(NSInteger)iSection;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *sectionViews;

@end
