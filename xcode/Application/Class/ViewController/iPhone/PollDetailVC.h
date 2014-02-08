//
//  PollDetailVC.h
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
#import "PollResponseCell.h"
#import "ContactVO.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "FormResponseVO.h"

#import "SideScrollVC.h"

@interface PollDetailVC : SlideViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    FormManager *formSvc;
    ChatManager *chatSvc;
    ContactManager *contactSvc;
    
    BOOL isLoading;
    int selectedIndex;
    NSString *currentKey;
    int contactTotal;

    NSMutableArray *optionKeys;
    NSMutableArray *contactKeys;

    NSMutableArray *dataArray;
    NSMutableArray *tableData;
    NSMutableArray *allResponses;
    
}

@property (nonatomic, retain) SideScrollVC *carouselVC;

@property (nonatomic, retain) IBOutlet UIView *browseView;
@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *counterLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *responsesLabel;

@property (nonatomic, strong) IBOutlet BrandUILabel *optionTitle;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;

- (void)performSearch:(NSString *)searchText;

- (IBAction)tapCloseButton;
- (IBAction)tapLeftArrow;
- (IBAction)tapRightArrow;


//- (void) loadFormOptions;

@end
