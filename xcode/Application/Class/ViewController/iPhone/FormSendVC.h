//
//  FormSendVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import <MessageUI/MessageUI.h>

#import "SQLiteDB.h"
#import "MBProgressHUD.h"

#import "CCSearchBar.h"
#import "ContactVO.h"
#import "ContactManager.h"
#import "GroupManager.h"
#import "ChatManager.h"

@interface FormSendVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    CCSearchBar *ccSearchBar;

    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *contactsData;
    NSMutableArray *groupsData;

    UIView *bgLayer;
    ContactManager *contactSvc;
    GroupManager *groupSvc;
    ChatManager *chatSvc;
    
    NSMutableSet *contactSet;
    NSMutableSet *groupSet;
//    NSMutableDictionary *contactPicks;
//    NSMutableDictionary *groupPicks;
    
    
}
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, retain) CCSearchBar *ccSearchBar;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *contactsData;
@property(retain) NSMutableArray *groupsData;


- (void)performSearch:(NSString *)searchText;


@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

@property (nonatomic, strong) IBOutlet UIView *addModal;

- (IBAction)tapDoneButton;

- (IBAction)tapCancelButton;

- (void) showModal;
- (void) hideModal;


@end
