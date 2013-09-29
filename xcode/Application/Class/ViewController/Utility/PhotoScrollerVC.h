//
//  ContentViewController.h
//  Autochrome
//

#import <UIKit/UIKit.h>
#import "PhotoScrollView.h"
#import "BaseItemView.h"

@class PhotoScrollView;

@interface PhotoScrollerVC : UIViewController <UIScrollViewDelegate> {
    UIView *mainView;
    PhotoScrollView *scrollView;
	NSMutableDictionary *loadedViewsDictionary;
    BaseItemView *previousView;
    
    NSString *currentState;
    NSMutableArray *catalog;
	int currentIndex;
}

@property (nonatomic, retain) PhotoScrollView *scrollView;

@property (nonatomic,retain) NSString *currentState;
@property (nonatomic) int currentIndex;

- (id)initWithCatalog:(NSMutableArray *)items;

- (void) handleScrollWindow;
- (void) handleSwapImages;

@end
