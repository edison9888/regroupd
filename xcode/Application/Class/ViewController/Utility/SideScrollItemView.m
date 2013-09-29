//
//  SideScrollItemView.m
//  photiq
//
//  Created by Hugh Lang on 2/13/13.
//  Copyright (c) 2013 Tastemakerlabs. All rights reserved.
//

#import "SideScrollItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+ColorWithHex.h"

#import "ProductPhoto.h"
#import "ImageItemView.h"
#import "CustomMenuItemView.h"
#import "ClearOpenSansButton.h"

@implementation SideScrollItemView

@synthesize scrollView;

@synthesize currentState;
@synthesize currentIndex;

#define menuButtonWidth 200

- (id)initWithFrame:(CGRect)frame andProduct:(Product *)product {
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    if ((self = [super initWithFrame: frame])) {
        [self setProduct:product];
        currentState = @"scroll";
        currentIndex = 0;
        previousView = nil;
        viewCount = product.images.count + 1;
        photos = product.images.mutableCopy;
        
        // initialize ScrollView
        scrollView = [[PhotoScrollView alloc] initWithFrame:CGRectMake(0,0,kPhotoWidth,kPhotoHeight)];
        [scrollView setContentSize:CGSizeMake(kPhotoWidth * viewCount, kPhotoHeight)];
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:YES];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setUserInteractionEnabled:YES];
        [scrollView setScrollEnabled:YES];
        [scrollView setDelaysContentTouches:NO];
        [scrollView setBackgroundColor:[UIColor blackColor]];
        [scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [scrollView setDelegate:self];
        
        //    [self.view addSubview:scrollView];
        [self addSubview:scrollView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideScrollToPageNotificationHandler:)     name:@"sideScrollToPageNotification"            object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSideScrollingNotificationHandler:)  name:@"enableSideScrollingNotificationHandler"  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableSideScrollingNotificationHandler:) name:@"disableSideScrollingNotificationHandler" object:nil];
        
        [self handleScrollWindow];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView {
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        //		isInScrollWindow = NO;
        //        subview = embedView;
        //        subview.frame = self.bounds;
        //        [self addSubview:subview];
    }
    return self;
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
		if (i >= 0 && i < viewCount-1) {
			aView = [loadedViewsDictionary objectForKey:[NSNumber numberWithInt:i]];
			if (aView == nil) {
                ProductPhoto *ph = [photos objectAtIndex:i];
                UIImageView *photoView;
                photoView = [[UIImageView alloc] init];
                // https://github.com/rs/SDWebImage
                NSLog(@"display image from url: %@", ph.mediumURL);
                [photoView setOpaque:YES];
                photoView.backgroundColor = [UIColor blackColor];
                [photoView setImageWithURL:[NSURL URLWithString:ph.mediumURL]];
				aView = [[ImageItemView alloc] initWithFrame:CGRectMake(0,i*kPhotoHeight,kPhotoWidth,kPhotoHeight) andView:photoView];
                
				[scrollView addSubview:aView];
				[loadedViewsDictionary setObject: aView forKey:[NSNumber numberWithInt:i]];
			}
			
			[aView setIsInScrollWindow:YES];
		} else if (i == viewCount - 1){
            NSLog(@"Adding menu view");
//            Add UIView with custom content
            UIView *menuView = [[UIView alloc] init];
//            UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kPhotoWidth,kPhotoHeight)];
            menuView.backgroundColor = [UIColor colorWithHexValue:0x555555];
            
            ClearOpenSansButton *addPhotoButton = [[ClearOpenSansButton alloc] init];
            addPhotoButton.frame = CGRectMake((kPhotoWidth - menuButtonWidth)/2, kPhotoHeight - 100, menuButtonWidth, 50);
            
            [addPhotoButton setTitle:@"Add another photo" forState:UIControlStateNormal];
            
            [addPhotoButton addTarget:self action:@selector(addPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [menuView addSubview:addPhotoButton];
            
            aView = [[CustomMenuItemView alloc] initWithFrame:CGRectMake(0,i*kPhotoHeight,kPhotoWidth,kPhotoHeight) andView:menuView];
            [scrollView addSubview:aView];
            [loadedViewsDictionary setObject: aView forKey:[NSNumber numberWithInt:i]];
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
	int newIndex = (int)scrollView.contentOffset.x/kPhotoHeight;
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

#pragma mark - Action handlers

- (void)addPhotoAction: (id)sender {
#ifdef kDEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
}



@end
