//
//  RatingDetailVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "FormManager.h"
#import "ChatManager.h"
#import "ContactManager.h"
#import "SQLiteDB.h"

#import "ContactVO.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "SideScrollVC.h"

#import "RatingResponseCell.h"
#import "RatingMeterSlider.h"


@interface RatingDetailVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    FormManager *formSvc;
    ChatManager *chatSvc;
    ContactManager *contactSvc;

    BOOL isLoading;
    int selectedIndex;

    NSString *currentKey;
    int contactTotal;

    NSMutableArray *dataArray;
    NSMutableArray *optionKeys;
    NSMutableArray *contactKeys;
    NSMutableSet *recipientKeySet;
    
    NSMutableArray *tableData;
    NSMutableArray *allResponses;
    
}

@property (nonatomic, retain) SideScrollVC *carouselVC;
@property (nonatomic, retain) RatingMeterSlider *totalRatingSlider;

@property (nonatomic, retain) IBOutlet UIView *browseView;

@property (nonatomic, strong) IBOutlet BrandUILabel *optionTitle;
@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *counterLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *responsesLabel;

@property (nonatomic, retain) IBOutlet UIImageView *starRatingBG;
@property (nonatomic, strong) IBOutlet BrandUILabel *starRatingLabel;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;


- (IBAction)tapCloseButton;
- (IBAction)tapLeftArrow;
- (IBAction)tapRightArrow;


- (void) loadFormOptions;

@end
