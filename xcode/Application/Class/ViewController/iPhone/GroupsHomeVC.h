//
//  GroupsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "GroupTableViewCell.h"
#import "ContactVO.h"

@interface GroupsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
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
