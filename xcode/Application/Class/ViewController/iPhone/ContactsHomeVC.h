//
//  ContactsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCSearchBar.h"
#import "ContactVO.h"
#import "ContactManager.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
//ABPersonViewControllerDelegate, 
@interface ContactsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *contactsData;
    NSMutableArray *groupsData;
//    NSArray *addressBookData;

    NSMutableArray *peopleData;

    UIView *bgLayer;
    ContactManager *contactSvc;
    
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *contactsData;
@property(retain) NSMutableArray *groupsData;
//@property(retain) NSArray *addressBookData;
@property(retain) NSArray *peopleData;


- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

@property (nonatomic, strong) IBOutlet UIView *addModal;


- (IBAction)tapAddButton;
- (IBAction)tapEditButton;

- (IBAction)tapNewContactButton;
- (IBAction)tapNewGroupButton;
- (IBAction)tapCancelButton;

- (void) showModal;
- (void) hideModal;


@end
