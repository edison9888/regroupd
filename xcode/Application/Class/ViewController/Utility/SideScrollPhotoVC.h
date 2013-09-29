//
//  SideScrollItemView.h
//  photiq
//
//  Created by Hugh Lang on 2/13/13.
//  Copyright (c) 2013 Tastemakerlabs. All rights reserved.
//

#import "BaseItemView.h"
#import "PhotoScrollView.h"

/*
 This view is designed to allow a horizontal scrollable container inside a vertical scroller
 */
@interface SideScrollPhotoVC : UIViewController <UIScrollViewDelegate>
{
    UIView *mainView;
    PhotoScrollView *scrollView;
	NSMutableDictionary *loadedViewsDictionary;
    BaseItemView *previousView;
    
    NSString *currentState;
    NSMutableArray *photos;

    int viewCount;
	int currentIndex;
    
}

@property (nonatomic, retain) PhotoScrollView *scrollView;

@property (nonatomic,retain) NSString *currentState;
@property (nonatomic) int currentIndex;

- (id)initWithPhotos:(NSMutableArray *)photosArray;

- (void) handleScrollWindow;
- (void) handleSwapImages;


@end
