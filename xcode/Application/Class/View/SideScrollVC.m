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
	[scrollView setBackgroundColor:[UIColor clearColor]];
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
    
    NSLog(@"%s", __FUNCTION__);
    
    
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
        NSLog(@"Iterate pages: i=%i",i);
        
		if (i >= 0 && i < viewCount) {
			aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:i]];
			if (aView == nil) {
                NSDictionary *pageData = (NSDictionary *)[pages objectAtIndex:i];
                NSLog(@"xpos = %d", i*kPhotoWidth);
                
				aView = [[ScrollOptionView alloc] initWithFrame:CGRectMake(i*kPhotoWidth, 0,kPhotoWidth,kPhotoHeight) andData:pageData];
                aView.backgroundColor = [UIColor clearColor];
                
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
    
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification
                                                            notificationWithName:@"pageUpdateNotification"
                                                            object:[NSNumber numberWithInt:currentIndex]]];

}

- (void) handleSwapImages {
//    NSLog(@"handleSwapImages %i", currentIndex);
//    
//    BaseItemView* aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:currentIndex]];
//    
//    [aView swapViews];
}


#pragma mark Handle ScrollView

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    // Process the single tap here
    
//    NSNotification* toggleInfoNotification = [NSNotification notificationWithName:@"toggleInfoNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:toggleInfoNotification];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    
//    NSNotification* hideInfoNotification = [NSNotification notificationWithName:@"hideInfoNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:hideInfoNotification];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
	if(decelerate) {
		[scrollView setUserInteractionEnabled:NO];
	}
}

- (void)scrollViewDidEndDecelerating:(PageScrollView *)aScrollView {
    NSLog(@"%s", __FUNCTION__);
	int newIndex = (int)scrollView.contentOffset.x / (int)kPhotoWidth;
    NSLog(@"newIndex %i -- currentIndex %i", newIndex, currentIndex);

	if (newIndex != currentIndex) {
        
		currentIndex = newIndex;
		
		[self handleScrollWindow];
	}
	[scrollView setUserInteractionEnabled:YES];
}

- (void)scrollToPageNotificationHandler:(NSNotification*)notification
{
//    NSLog(@"%s", __FUNCTION__);
//    NSNumber *num = (NSNumber *) notification.object;
    
	
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

#pragma mark - actions 
- (void) goPrevious {
    if (currentIndex > 0) {
        currentIndex -= 1;
        
        CGRect frame = CGRectMake(currentIndex * kPhotoWidth, 0, kPhotoWidth, kPhotoWidth); 
        [self.scrollView scrollRectToVisible:frame animated:YES];
		[self handleScrollWindow];
        
    }
    
}
- (void) goNext {
    if (currentIndex < viewCount - 1) {
        currentIndex += 1;
        
        CGRect frame = CGRectMake(currentIndex * kPhotoWidth, 0, kPhotoWidth, kPhotoWidth);
        [self.scrollView scrollRectToVisible:frame animated:YES];
		[self handleScrollWindow];
        
    }
    
}



@end
