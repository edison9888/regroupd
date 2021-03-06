//
//  ContactGroupsVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "GroupContactCell.h"
#import "ContactVO.h"
#import "GroupManager.h"
#import "ChatManager.h"

@interface ContactGroupsVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    GroupManager *groupSvc;
    ChatManager *chatSvc;
    
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    
    NSMutableArray *chatKeys;
    NSMutableDictionary *selectionsMap;
    
    NSString *theContactKey;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;


- (IBAction)tapCancelButton;

- (IBAction)tapDoneButton;


@end
