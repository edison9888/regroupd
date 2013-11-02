//
//  EditGroupVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCSearchBar.h"
#import "CCTableViewCell.h"
#import "ChatManager.h"
#import "GroupManager.h"

#import "ChatVO.h"
#import "ContactVO.h"
#import "SelectedItemWidget.h"
#import "BrandUILabel.h"
#import "BrandUITextField.h"

@interface EditGroupVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    CCSearchBar *ccSearchBar;
    NSMutableDictionary *contactsMap;
    NSMutableArray *contactIds;
    float ypos;
    float xpos;
    ChatManager *chatSvc;
    GroupManager *groupSvc;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UIView *selectionsView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet BrandUILabel *navTitle;
@property (nonatomic, retain) IBOutlet BrandUITextField *groupName;

@property (nonatomic, retain) CCSearchBar *ccSearchBar;

@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

- (IBAction)tapDoneButton;

- (IBAction)tapCancelButton;

@end
