//
//  PresentationModel.h
//  Presentation Framework
//
//

#import <Foundation/Foundation.h>
#import "SlideModel.h"

@interface PresentationModel : NSObject {
	NSString					*_name;
	NSString					*_firstSlideName;
	NSString					*_lastSlideName;
	PresentationTransitionFlags	_transitionFlags;
	NSTimeInterval				_transitionDuration;
    BOOL                        _allowCircularNavigation;
	
	/**
	 * array of SlideModel objects
	 */
    NSMutableArray				*_slides;
}

@property (readonly) NSString *name;
@property (readonly) NSString *firstSlideName;
@property (readonly) NSString *lastSlideName;
@property (readonly) NSMutableArray *slides;
@property (readonly, assign) PresentationTransitionFlags transitionFlags;
@property (readonly, assign) NSTimeInterval transitionDuration;
@property (readonly, assign) BOOL allowCircularNavigation;

- (id)initWithPlistFile:(NSString*)plistFilename;
- (SlideModel*)slideWithName:(NSString*)name;

/**
 * Recompute slide indices if the slides array is manipulated directly
 */
- (void)recomputeSlideIndices;


+ (PresentationModel*)presentationModelWithPlistFile:(NSString*)plistFilename;

@end
