//
//  RecentHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "FaxManager.h"
//#import "CCSearchBar.h"
#import "RecentTableViewCell.h"

@interface RecentHomeVC : SlideViewController<UITableViewDataSource, UITableViewDelegate> {
    BOOL inEditMode;
    int filterOption;
    
    int selectedIndex;
    NSMutableArray *tableData;
    FaxManager *faxSvc;
    
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *unsentButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;


- (IBAction)tapAllButton;
- (IBAction)tapUnsentButton;
- (IBAction)tapEditButton;

@end
