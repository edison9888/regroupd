//
//  ChatsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "MBProgressHUD.h"

#import "ChatTableViewCell.h"
#import "ContactVO.h"
#import "ChatManager.h"
#import "ContactManager.h"

@interface ChatsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    ChatManager *chatSvc;
    ContactManager *contactSvc;
    NSMutableArray *unknownContactKeys;
}

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;


- (IBAction)tapAddButton;

- (IBAction)tapEditButton;

@end
