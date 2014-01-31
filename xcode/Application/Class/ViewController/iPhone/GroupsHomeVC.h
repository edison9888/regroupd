//
//  GroupsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "MBProgressHUD.h"

#import "GroupTableViewCell.h"
#import "GroupVO.h"
#import "ContactVO.h"
#import "GroupManager.h"
#import "ChatManager.h"

@interface GroupsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    GroupManager *groupSvc;
    ChatManager *chatSvc;
    
    BOOL isLoading;
    BOOL inEditMode;
    int selectedIndex;
    
    NSMutableArray *tableData;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;


- (IBAction)tapAddButton;

- (IBAction)tapEditButton;

@end
