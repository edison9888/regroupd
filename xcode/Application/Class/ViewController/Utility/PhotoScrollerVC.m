//
//  ContentViewController.m
//  Autochrome
//

#import "PhotoScrollerVC.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageItemView.h"
#import "SideScrollItemView.h"
#import "Page.h"

#define kPhotoWidth 300
#define kPhotoHeight 300

@interface PhotoScrollerVC() {
    int photoCount;
}

@end

@implementation PhotoScrollerVC

@synthesize scrollView;

@synthesize currentState;
@synthesize currentIndex;



- (id)initWithCatalog:(NSMutableArray *)items
{
    NSLog(@"%s", __FUNCTION__);
    
    photoCount = items.count;
    catalog = items;
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
	currentState = @"scroll";
	currentIndex = 0;
	previousView = nil;

	// initialize ScrollView
	scrollView = [[PhotoScrollView alloc] initWithFrame:CGRectMake(10,10,kPhotoWidth,kPhotoHeight)];
	[scrollView setContentSize:CGSizeMake(kPhotoWidth, kPhotoHeight * photoCount)];
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
		if (i >= 0 && i < photoCount) {
			aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:i]];
			if (aView == nil) {
                Page *p = [catalog objectAtIndex:i];
                NSLog(@"ypos = %d", i*kPhotoHeight);
//				aView = [[ImageItemView alloc] initWithFrame:CGRectMake(0,i*kPhotoHeight,kPhotoWidth,kPhotoHeight) andProduct:p];
                
//                UIImageView *photoView;
//                ProductPhoto *defaultPhoto = (ProductPhoto *) [p.images objectAtIndex:0];
//                photoView = [[UIImageView alloc] init];
//                // https://github.com/rs/SDWebImage
//                NSLog(@"display image from url: %@", defaultPhoto.mediumURL);
//                [photoView setOpaque:YES];
//                photoView.backgroundColor = [UIColor blackColor];
//                [photoView setImageWithURL:[NSURL URLWithString:defaultPhoto.mediumURL]];
//				aView = [[ImageItemView alloc] initWithFrame:CGRectMake(0,i*kPhotoHeight,kPhotoWidth,kPhotoHeight) andView:photoView];

                
				aView = [[SideScrollItemView alloc] initWithFrame:CGRectMake(0,i*kPhotoHeight,kPhotoWidth,kPhotoHeight) andProduct:p];

				[scrollView addSubview:aView];
				[loadedViewsDictionary setObject: aView forKey:[NSNumber numberWithInt:i]];
			}
			
			[aView setIsInScrollWindow:YES];
		}
	}
	
	// remove all unused views
	NSMutableArray* viewsToRemove = [NSMutableArray arrayWithCapacity:photoCount];
	
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
    NSLog(@"scrollViewWillBeginDragging");
    NSNotification* hideInfoNotification = [NSNotification notificationWithName:@"hideInfoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideInfoNotification];   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
	if(decelerate) {
		[scrollView setUserInteractionEnabled:NO];
	}
}

- (void)scrollViewDidEndDecelerating:(PhotoScrollView *)aScrollView {
	int newIndex = (int)scrollView.contentOffset.y/kPhotoHeight;
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


#pragma mark Standard Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return NO;
}


- (void)didReceiveMemoryWarning {   
//	BaseItemView* aView = nil;
	
    // Release any cached data, images, etc that aren't in use.
	NSLog(@"Memory Warning");

	// remove all except current view
//	NSMutableArray* viewsToRemove = [NSMutableArray arrayWithCapacity:[[book pages] count]];
//	NSNumber* currentIndexNumber = [NSNumber numberWithInt:currentIndex];
//	for (NSNumber *key in loadedSitesDictionary) {
//		if([key isEqualToNumber:currentIndexNumber] == NO) {
//			[aView removeFromSuperview];
//			[viewsToRemove addObject:key];
//		}
//	}
		
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
}

@end
