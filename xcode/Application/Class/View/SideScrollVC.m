//
//  SideScrollVC.h
//  Regroupd
//
//

#import "SideScrollVC.h"
#import "ScrollOptionView.h"

#define kPhotoWidth 320
#define kPhotoHeight 300

@implementation SideScrollVC

@synthesize scrollView;

@synthesize currentState;
@synthesize currentIndex;

- (id)initWithData:(NSMutableArray *)pageArray
{
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    viewCount = pageArray.count;
    pages = pageArray;
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    NSLog(@"%s", __FUNCTION__);
	currentState = @"scroll";
	currentIndex = 0;
	previousView = nil;
    
    loadedViewsDictionary = [[NSMutableDictionary alloc] init];

	// initialize ScrollView
	scrollView = [[PageScrollView alloc] initWithFrame:CGRectMake(0,0,kPhotoWidth,kPhotoHeight)];
	[scrollView setContentSize:CGSizeMake(kPhotoWidth * viewCount, kPhotoHeight)];
	[scrollView setPagingEnabled:YES];
	[scrollView setShowsHorizontalScrollIndicator:NO];
	[scrollView setShowsVerticalScrollIndicator:NO];
	[scrollView setUserInteractionEnabled:YES];
	[scrollView setScrollEnabled:YES];
	[scrollView setDelaysContentTouches:NO];
	[scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
	[scrollView setDelegate:self];
	
    //    [self.view addSubview:scrollView];
	[self setView:scrollView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToPageNotificationHandler:)     name:@"scrollToPageNotification"            object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollingNotificationHandler:)  name:@"enableScrollingNotificationHandler"  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScrollingNotificationHandler:) name:@"disableScrollingNotificationHandler" object:nil];
    
    [self handleScrollWindow];
    
}

- (void) handleScrollWindow {
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
	BaseItemView* aView = nil;
	
    if(previousView) {
		[previousView willBlur];
	}
    
    
	// set all views to invisible
	for (NSNumber *key in loadedViewsDictionary) {
		aView = [loadedViewsDictionary objectForKey:key];
		[aView setIsInScrollWindow:NO];
	}
	
	// iterate over three views, one visible, one on the left one on the right
	for(int i=currentIndex-1; i <= currentIndex+1; i++) {
		if (i >= 0 && i < viewCount) {
			aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:i]];
			if (aView == nil) {
                NSDictionary *pageData = (NSDictionary *)[pages objectAtIndex:i];
                NSLog(@"xpos = %d", i*kPhotoWidth);
                
				aView = [[ScrollOptionView alloc] initWithFrame:CGRectMake(i*kPhotoWidth, 0,kPhotoWidth,kPhotoHeight) andData:pageData];
                
				[scrollView addSubview:aView];
				[loadedViewsDictionary setObject: aView forKey:[NSNumber numberWithInt:i]];
			}
			
			[aView setIsInScrollWindow:YES];
		}
	}
	
	// remove all unused views
	NSMutableArray* viewsToRemove = [NSMutableArray arrayWithCapacity:viewCount];
	
	// iterate
	for (NSNumber *key in loadedViewsDictionary) {
		aView = [loadedViewsDictionary objectForKey:key];
		
		if([aView isInScrollWindow] == NO) {
			if([aView respondsToSelector:@selector(willRemoveFromSuperview)]) {
				[aView willRemoveFromSuperview];
			}
			[aView removeFromSuperview];
			[viewsToRemove addObject:key];
		}
	}
	[loadedViewsDictionary removeObjectsForKeys:viewsToRemove];
    
    NSLog(@"currentIndex %i", currentIndex);
	
	aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:currentIndex]];
	[aView willFocus];
    previousView = aView;
    
}

- (void) handleSwapImages {
    NSLog(@"handleSwapImages %i", currentIndex);
    
    BaseItemView* aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:currentIndex]];
    
    //    ImageViewTemplate* aView = (ImageViewTemplate *) [loadedSitesDictionary objectForKey:[NSNumber numberWithInt:currentIndex]];
    //    NSLog(@"Page title is: %@", [[[aView page] chapter] title]);
    
    [aView swapViews];
}

#pragma mark Handle ScrollView

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    // Process the single tap here
    
    NSNotification* toggleInfoNotification = [NSNotification notificationWithName:@"toggleInfoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:toggleInfoNotification];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
    NSNotification* hideInfoNotification = [NSNotification notificationWithName:@"hideInfoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideInfoNotification];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
	if(decelerate) {
		[scrollView setUserInteractionEnabled:NO];
	}
}

- (void)scrollViewDidEndDecelerating:(PageScrollView *)aScrollView {
	int newIndex = (int)scrollView.contentOffset.y/kPhotoWidth;
	if (newIndex != currentIndex) {
		currentIndex = newIndex;
		
		[self handleScrollWindow];
	}
	[scrollView setUserInteractionEnabled:YES];
}

- (void)scrollToPageNotificationHandler:(NSNotification*)notification
{
    
	
    //	[self setCurrentIndex: [chapter index]];
    //	[[self scrollView] setContentOffset:CGPointMake([chapter index] * kPhotoWidth,0) animated:NO];
	[self handleScrollWindow];
    
    
}

- (void)enableScrollingNotificationHandler:(NSNotification*)notification
{
	[[self scrollView] setScrollEnabled:YES];
}

- (void)disableScrollingNotificationHandler:(NSNotification*)notification
{
	[[self scrollView] setScrollEnabled:NO];
}



@end
