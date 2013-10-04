//
//  EditChatVC.h
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
#import "SelectedItemWidget.h"

@interface EditChatVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    CCSearchBar *ccSearchBar;
    NSMutableDictionary *contactsMap;
    NSMutableArray *contactIds;
    float ypos;
    float xpos;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UIView *selectionsView;

@property (nonatomic, retain) CCSearchBar *ccSearchBar;

@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;

- (IBAction)tapDoneButton;

- (IBAction)tapCancelButton;

@end