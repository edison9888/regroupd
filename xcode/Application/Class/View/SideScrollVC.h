//
//  SideScrollVC.h
//  Regroupd
//
//  Created by Hugh Lang on 9/30/13.
//
//

#import "BaseItemView.h"
#import "PageScrollView.h"
#import "ScrollOptionView.h"
#import "FormOptionVO.h"


/*
 This view is designed to allow a horizontal scrollable container inside a vertical scroller
 */
@interface SideScrollVC : UIViewController <UIScrollViewDelegate>
{
    UIView *mainView;
    PageScrollView *scrollView;
	NSMutableDictionary *loadedViewsDictionary;
    BaseItemView *previousView;
    
    NSString *currentState;
    NSMutableArray *pages;
    
    int viewCount;
	int currentIndex;
    
}

@property (nonatomic, retain) PageScrollView *scrollView;

@property (nonatomic,retain) NSString *currentState;
@property (nonatomic) int currentIndex;

- (id)initWithData:(NSMutableArray *)pageArray;

- (void) handleScrollWindow;
- (void) handleSwapImages;


@end
