//
//  ManageGroupVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "GroupManager.h"
#import "SQLiteDB.h"
#import "ContactVO.h"

@interface ManageGroupVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    GroupManager *groupSvc;
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    NSMutableArray *alphasArray;
    NSMutableDictionary *alphaMap;
    BOOL isSearching;
    
    NSMutableArray *memberKeys;
    NSMutableDictionary *selectionsMap;

}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;


- (IBAction)tapCancelButton;

- (IBAction)tapDoneButton;

@end
