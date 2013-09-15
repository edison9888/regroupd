//
//  PresentationModel.m
//  Presentation Framework
//
//

#import "PresentationModel.h"

@interface PresentationModel ()
@end

@implementation PresentationModel
@synthesize name = _name;
@synthesize firstSlideName = _firstSlideName;
@synthesize lastSlideName = _lastSlideName;
@synthesize transitionFlags = _transitionFlags;
@synthesize transitionDuration = _transitionDuration;
@synthesize slides = _slides;
@synthesize allowCircularNavigation = _allowCircularNavigation;


- (id)initWithPlistFile:(NSString*)plistFilename 
{
	if ((self = [super init])) {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistFilename ofType:nil];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		
		// read presentation parameters
		NSDictionary *parameters = [dict objectForKey:@"presentation"]; 
        
		_name = [parameters objectForKey:@"name"];        
		_firstSlideName = [parameters objectForKey:@"firstSlideName"];
		_lastSlideName = [parameters objectForKey:@"lastSlideName"];
		_transitionFlags = [SlideModel transitionFlagsFromString:[parameters objectForKey:@"transitionFlags"]];
		_transitionDuration = [[parameters objectForKey:@"transitionDuration"] floatValue];
        _allowCircularNavigation = [[parameters objectForKey:@"allowCircularNavigation"] boolValue];
		
		// convert slide dictionaries into model objects
		NSArray *rawSlides = [dict objectForKey:@"slides"];
		_slides = [[NSMutableArray alloc] initWithCapacity:rawSlides.count];
		
		for (NSInteger i = 0; i < rawSlides.count; i++) {
			NSDictionary *rawSlide = [rawSlides objectAtIndex:i];
			SlideModel *slide = [SlideModel slideModelWithDictionary:rawSlide];
			[_slides addObject:slide];
		}

		[self recomputeSlideIndices];
	}
	
	return self;
}


- (SlideModel*)slideWithName:(NSString*)name
{
	if (!name.length) {
		return nil;
	}
	
	for (SlideModel *slide in _slides) {
		if ([slide.name isEqual:name]) {
			return [slide copy];
		}
	}
	
	return nil;
}

- (void)recomputeSlideIndices
{
	for (NSInteger i = 0; i < _slides.count; i++) {
		SlideModel *slide = [_slides objectAtIndex:i];
		slide.slideIndex = i;
        if (_allowCircularNavigation) {
            slide.previousSlideIndex = i == 0 ? _slides.count - 1 : i - 1;
            slide.nextSlideIndex = i < _slides.count - 1 ? i + 1 : 0;
        } else {
            slide.previousSlideIndex = i - 1;
            slide.nextSlideIndex = i < _slides.count - 1 ? i + 1 : -1;
        }
	}
	
	// honor any ordering overrides
	for (SlideModel *slide in _slides) {
		if (slide.previousSlideName.length) {
			SlideModel *previousSlide = [self slideWithName:slide.previousSlideName];
			if (previousSlide) {
				slide.previousSlideIndex = previousSlide.slideIndex;
			}
		}
		if (slide.nextSlideName.length) {
			SlideModel *nextSlide = [self slideWithName:slide.nextSlideName];
			if (nextSlide) {
				slide.nextSlideIndex = nextSlide.slideIndex;
			}
		}
	}
}

#pragma mark Class methods

+ (PresentationModel*)presentationModelWithPlistFile:(NSString*)plistFilename
{
	return [[PresentationModel alloc] initWithPlistFile:plistFilename];
}



@end
