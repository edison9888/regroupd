//
//  RSVPDetailVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCTableViewCell.h"
#import "ContactVO.h"
#import "FormManager.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "BrandUILabel.h"

@interface RSVPDetailVC : SlideViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    FormManager *formSvc;
    
}
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

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *maybeButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;


- (IBAction)tapCloseButton;

- (IBAction)tapAnswerButton;


- (void) loadFormOptions;

@end
