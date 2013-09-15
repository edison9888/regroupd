//
//  SlideModel.m
//  Presentation Framework
//
//

#import "SlideModel.h"
#import	"NSObject+InvocationHelper.h"

typedef struct {
	__unsafe_unretained NSString *string;
	NSInteger flag;
} StringFlagMap;


@implementation SlideModel
@synthesize name = _name;
@synthesize url = _url;
@synthesize nibName = _nibName;
@synthesize controllerName = _controllerName;
@synthesize slideIndex = _slideIndex;
@synthesize transitionFlags = _transitionFlags;
@synthesize gravityFlags = _gravityFlags;
@synthesize transitionSlideNames = _transitionSlideNames;
@synthesize nextSlideIndex = _nextSlideIndex;
@synthesize previousSlideIndex = _previousSlideIndex;
@synthesize category = _category;
@synthesize slideData = _slideData;
@synthesize components = _components;
@synthesize sections = _sections;
@synthesize movieFilename = _movieFilename;
@synthesize previousSlideName = _previousSlideName;
@synthesize nextSlideName = _nextSlideName;
@synthesize isFavorite = _isFavorite;
@synthesize isModal = _isModal;
@synthesize isConcurrent = _isConcurrent;
@synthesize isExclusive = _isExclusive;
@synthesize allowLeftSlide = _allowLeftSlide;
@synthesize allowRightSlide = _allowRightSlide;
@synthesize fullscreenGoesLandscape = _fullscreenGoesLandscape;
@synthesize loopMovie = _loopMovie;
@synthesize slideOptions = _slideOptions;


- (id)initWithDictionary:(NSDictionary *)slideDict
{
	if ((self = [super init])) {
		NSArray *allKeys = slideDict.allKeys;
		for (NSString *key in allKeys) {
			if ([key isEqual:@"transitionFlags"]) {
				_transitionFlags = [SlideModel transitionFlagsFromString:[slideDict objectForKey:key]];
				continue;
			}
			if ([key isEqual:@"gravityFlags"]) {
				_gravityFlags = (PresentationGravityFlags)[SlideModel gravityFlagsFromString:[slideDict objectForKey:key]];
				continue;
			}
			
			// experimental: programmatic conversion from dictionary to properties
			NSString *selName = [NSString stringWithFormat:@"set%@%@:", 
								 [[key substringToIndex:1] capitalizedString],
								 [key substringFromIndex:1]];
                        
			SEL selector = NSSelectorFromString(selName);
			
			if ([self respondsToSelector:selector]) {
				id object = [slideDict objectForKey:key];
				                
				// detect and handle primitive types
				NSMethodSignature *sig = [SlideModel instanceMethodSignatureForSelector:selector];
				const char *argType = [sig getArgumentTypeAtIndex:2];
				if (strcmp(argType, @encode(BOOL)) == 0) {
					BOOL value = [object boolValue];
					NSInvocation *invocation = [self invocationWithSelector:selector primitive:&value];
					[invocation invokeWithTarget:self];
				}
				else if (strcmp(argType, @encode(NSInteger)) == 0) {
					NSInteger value = [object intValue];
					NSInvocation *invocation = [self invocationWithSelector:selector primitive:&value];
					[invocation invokeWithTarget:self];
				}
                else {
					// assumption: NSObject type
					[self performSelector:selector withObject:object];
				}
			}
		}
        
        // parse the name to separate out url portion, if present
        NSRange range;
        if ((range = [_name rangeOfString:@"/"]).location != NSNotFound) {
            _url = [_name substringFromIndex:range.location + 1];
            self.name = [_name substringToIndex:range.location];
        }
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone 
{
    SlideModel *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        [copy setName:[self name]];
        [copy setUrl:[self url]];
        [copy setNibName:[self nibName]];
        [copy setControllerName:[self controllerName]];
        [copy setGravityFlags:[self gravityFlags]];
        [copy setTransitionFlags:[self transitionFlags]];
        
        
        
        [copy setTransitionSlideNames:[self transitionSlideNames]];
        [copy setSlideIndex:[self slideIndex]];
        [copy setNextSlideIndex:[self nextSlideIndex]];
        [copy setPreviousSlideIndex:[self previousSlideIndex]];
        [copy setCategory:[self category]];
        
        NSDictionary *slideDataCopy = [[self slideData] copy];
        [copy setSlideData:slideDataCopy];
        
        NSDictionary *componentsCopy = [[self components] copy];
        [copy setComponents:componentsCopy];
        
        NSArray *sectionsCopy = [[self sections] copy];
        [copy setSections:sectionsCopy];
        
        [copy setMovieFilename:[self movieFilename]];
        
        [copy setPreviousSlideName:[self previousSlideName]];
        [copy setNextSlideName:[self nextSlideName]];
        
        [copy setIsFavorite:[self isFavorite]];
        [copy setIsModal:[self isModal]];
        [copy setIsConcurrent:[self isConcurrent]];
        [copy setIsExclusive:[self isExclusive]];
        [copy setAllowLeftSlide:[self allowLeftSlide]];
        [copy setAllowRightSlide:[self allowRightSlide]];
        [copy setFullscreenGoesLandscape:[self fullscreenGoesLandscape]];
        [copy setLoopMovie:[self loopMovie]];
        
        NSDictionary *slideOptionsCopy = [[self slideOptions] copy];
        [copy setSlideOptions:slideOptionsCopy];
    }
	
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (object == nil || [object class] != [self class]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    
    return [self.name isEqualToString:[object name]];
}

#pragma mark - Memory Management


#pragma mark - Data Querying Methods
/*-(NSString*)getAnimationTypeForPreviousSlide:(NSString *)slideId wasModal:(BOOL)wasModal
{
    if (_isModal) {
        return @"modalAnimation";
    }
    if (wasModal) {
        return @"exitingModalAnimation";
    }
    
    __block NSString *result = nil;
    
    for (NSDictionary *animationType in _animationTypes) {
        NSArray *targetedPages = [animationType objectForKey:@"previousPages"];
		if (!targetedPages.count && !result) {
			// use the animation type globally if one is not defined
			result = [animationType objectForKey:@"animationName"];
		} else {
			// else use only for specific entry slides
            for (NSString *targetPageId in targetedPages) {
                if ([targetPageId isEqualToString:slideId]) {
					result = [animationType objectForKey:@"animationName"];
					break;
				} 
            }
        }
    }
    
    return result;
}
*/

#pragma mark - Class methods

+ (SlideModel*)slideModelWithDictionary:(NSDictionary*)slideDict
{
	return [[SlideModel alloc] initWithDictionary:slideDict];
}

+ (PresentationTransitionFlags)transitionFlagsFromString:(NSString*)transitionString
{
	StringFlagMap map[] = { 
		{ @"cut", kPresentationTransitionCut }, 
		{ @"fade", kPresentationTransitionFade },
		{ @"push", kPresentationTransitionPush },
		{ @"modal", kPresentationTransitionModal },
        { @"fadeInFadeOut", kPresentationTransitionFadeInFadeOut },
		{ @"left", kPresentationTransitionLeft },
		{ @"right", kPresentationTransitionRight },
		{ @"up", kPresentationTransitionUp },
		{ @"down", kPresentationTransitionDown },
		{ @"auto", kPresentationTransitionAuto },
	};
		
	PresentationTransitionFlags flags = 0; 
	NSInteger nMapItems = sizeof(map) / sizeof(map[0]);
	NSArray *comps = [transitionString componentsSeparatedByString:@"|"];
	for (NSString *string in comps) {
		for (int i = 0; i < nMapItems; i++) {
			if ([string isEqual:map[i].string]) {
				flags |= map[i].flag;
				break;
			}
		}
	}
	
	return flags;
}

+ (PresentationTransitionFlags)gravityFlagsFromString:(NSString*)gravityString
{
	StringFlagMap map[] = { 
		{ @"left", kPresentationGravityLeft }, 
		{ @"center", kPresentationGravityCenter },
		{ @"right", kPresentationGravityRight },
		{ @"top", kPresentationGravityTop },
		{ @"middle", kPresentationGravityMiddle },
		{ @"bottom", kPresentationGravityBottom },
	};
	
	PresentationGravityFlags flags = 0; 
	NSInteger nMapItems = sizeof(map) / sizeof(map[0]);
	NSArray *comps = [gravityString componentsSeparatedByString:@"|"];
	for (NSString *string in comps) {
		for (int i = 0; i < nMapItems; i++) {
			if ([string isEqual:map[i].string]) {
				flags |= map[i].flag;
				break;
			}
		}
	}
	
	return (PresentationTransitionFlags)flags;
}


@end
