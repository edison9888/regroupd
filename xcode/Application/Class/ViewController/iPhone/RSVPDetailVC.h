//
//  RSVPDetailVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"

#import "FormManager.h"
#import "ChatManager.h"
#import "ContactManager.h"

#import "ContactVO.h"
#import "FormVO.h"
#import "FormOptionVO.h"

#import "MBProgressHUD.h"
#import "BrandUILabel.h"

@interface RSVPDetailVC : SlideViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
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
    NSMutableDictionary *responseMap;
    
}

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *middleView;
@property (nonatomic, retain) IBOutlet UIView *footerView;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;

@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *dateLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;

@property (nonatomic, strong) IBOutlet BrandUILabel *whatText;
@property (nonatomic, strong) IBOutlet BrandUILabel *whereText;

@property (nonatomic, strong) IBOutlet PFImageView *roundPic;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *maybeButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;


- (IBAction)tapCloseButton;

- (IBAction)tapAnswerButton;


- (void) loadFormOptions;

@end
