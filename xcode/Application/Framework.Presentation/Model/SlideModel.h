//
//  SlideModel.h
//  Presentation Framework
//
//

#import <Foundation/Foundation.h>

typedef enum {
	kPresentationTransitionEmpty =           0x0000,
	kPresentationTransitionCut =             0x0001,
	kPresentationTransitionFade =            0x0002,
	kPresentationTransitionPush =            0x0004,
	kPresentationTransitionModal =           0x0008,
    kPresentationTransitionFadeInFadeOut =   0x0010,
	kPresentationTransitionLeft =            0x0100,
	kPresentationTransitionRight =           0x0200,
	kPresentationTransitionUp =              0x0400,
	kPresentationTransitionDown =            0x0800,
	kPresentationTransitionAuto =            0x1000,
    
	kPresentationTransitionTypeMask =        0x00FF,
} PresentationTransitionFlags;

typedef enum {
	kPresentationGravityEmpty =				0x00,
	kPresentationGravityLeft =				0x01,
	kPresentationGravityCenter =			0x02,
	kPresentationGravityRight =				0x04,
	kPresentationGravityTop =				0x10,
	kPresentationGravityMiddle =			0x20,
	kPresentationGravityBottom =			0x40,
    
	kPresentationTransitionHorizontalMask = 0x0F,
	kPresentationTransitionVerticalMask =	0xF0,
} PresentationGravityFlags;


@interface SlideModel : NSObject <NSCopying> {
	// default gravity and transition flags
	PresentationTransitionFlags _transitionFlags;
	NSArray			*_transitionSlideNames;
	PresentationGravityFlags	_gravityFlags;
	
    // position in navigation slide history
    NSInteger		_slideIndex;
    NSInteger		_nextSlideIndex;
    NSInteger		_previousSlideIndex;
    
    //Slide data definition
    NSString		*_name;
    NSString        *_url;
    NSString		*_nibName;
    NSString        *_controllerName;
    NSString		*_category;
    NSDictionary	*_slideData;
    NSDictionary	*_components;
    NSArray         *_sections;
    
    //Define in PLIST to override swipe next/prev navigation
    NSString		*_previousSlideName;
    NSString		*_nextSlideName;
    
    BOOL			_isModal;
	BOOL			_isConcurrent;
	BOOL			_isExclusive;
    BOOL			_allowLeftSlide;
    BOOL			_allowRightSlide;

	// application-level items
    BOOL			_isFavorite;
    NSString		*_movieFilename;
	BOOL			_fullscreenGoesLandscape;
	BOOL			_loopMovie;
	NSMutableDictionary	*_slideOptions;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, copy) NSString *controllerName;
@property (nonatomic, assign) PresentationGravityFlags gravityFlags;
@property (nonatomic, assign) PresentationTransitionFlags transitionFlags;
@property (nonatomic, copy) NSArray *transitionSlideNames;
@property (nonatomic, assign) NSInteger slideIndex;
@property (nonatomic, assign) NSInteger nextSlideIndex;
@property (nonatomic, assign) NSInteger previousSlideIndex;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSDictionary *slideData;
@property (nonatomic, strong) NSDictionary *components;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, copy) NSString *movieFilename;

@property (copy) NSString *previousSlideName;
@property (copy) NSString *nextSlideName;

@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, assign) BOOL isConcurrent;
@property (nonatomic, assign) BOOL isExclusive;
@property (nonatomic, assign) BOOL allowLeftSlide;
@property (nonatomic, assign) BOOL allowRightSlide;
@property (nonatomic, assign) BOOL fullscreenGoesLandscape;
@property (nonatomic, assign) BOOL loopMovie;

@property (nonatomic, strong) NSDictionary *slideOptions;


- (id)initWithDictionary:(NSDictionary *)slideDict;
//- (NSString*)getAnimationTypeForPreviousSlide:(NSString *)slideId wasModal:(BOOL)wasModal;

+ (SlideModel*)slideModelWithDictionary:(NSDictionary*)slideDict;
+ (PresentationTransitionFlags)transitionFlagsFromString:(NSString*)transitionString;
+ (PresentationTransitionFlags)gravityFlagsFromString:(NSString*)gravityString;


@end
