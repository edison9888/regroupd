//
//  SideScrollItemView.m
//  photiq
//
//  Created by Hugh Lang on 2/13/13.
//  Copyright (c) 2013 Tastemakerlabs. All rights reserved.
//

#import "SideScrollPhotoVC.h"
#import "ImageItemView.h"
#import "Page.h"

@implementation SideScrollPhotoVC

@synthesize scrollView;

@synthesize currentState;
@synthesize currentIndex;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}



- (id)initWithPhotos:(NSMutableArray *)photosArray
{
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    viewCount = photosArray.count;
    photos = photosArray;
    
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
    
	// initialize ScrollView
	scrollView = [[PhotoScrollView alloc] initWithFrame:CGRectMake(10,10,kPhotoWidth,kPhotoHeight)];
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
                Page *p = [photos objectAtIndex:i];
                NSLog(@"ypos = %d", i*kPhotoHeight);
                
				aView = [[ImageItemView alloc] initWithFrame:CGRectMake(i*kPhotoWidth, 0,kPhotoWidth,kPhotoHeight) andPage:p];
                
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

//- (void)shareContentNotification:(NSNotification*)notification
//{
//	Page *aPage      = [[book pages] objectAtIndex: currentIndex];
//	Chapter *aChapter = [aPage chapter];
//
//	if([aChapter shareSubject] && [aChapter shareLink]) {
//		NSMutableString* ms = [NSMutableString stringWithString:@"mailto:?subject="];
//		[ms appendString:[aChapter shareSubject]];
//		[ms appendString:@"&body=\n\n<a href=\""];
//		[ms appendString:[aChapter shareLink]];
//		[ms appendString:@"\">Steichen Autochrome: "];
//		[ms appendString:[aChapter title]];
//		[ms appendString:@"</a>"];
//
//		NSString *encodedBody = [ms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//		NSURL *url = [[NSURL alloc] initWithString:encodedBody];
//		[[UIApplication sharedApplication] openURL:url];
//	}
//}


@end
