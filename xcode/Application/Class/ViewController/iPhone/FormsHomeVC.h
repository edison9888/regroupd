//
//  FormsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCSearchBar.h"
#import "CCTableViewCell.h"
#import "ContactVO.h"

@interface FormsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    UIView *bgLayer;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

@property (nonatomic, strong) IBOutlet UIView *addModal;


- (IBAction)tapAddButton;

- (IBAction)tapEditButton;

- (IBAction)tapPollButton;
- (IBAction)tapRankingButton;
- (IBAction)tapRSVPButton;
- (IBAction)tapCancelButton;


- (void) showModal;
- (void) hideModal;

@end
