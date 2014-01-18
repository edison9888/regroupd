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
#import "ChatManager.h"
#import "ChatVO.h"
#import "ContactVO.h"
#import "NameWidget.h"
#import "WidgetStyle.h"

@interface EditChatVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    CCSearchBar *ccSearchBar;
    float ypos;
    float xpos;
    ChatManager *chatSvc;

    NSMutableDictionary *contactsMap;
    NSMutableArray *contactKeys;
    NSMutableArray *contactsArray;
    NSMutableArray *nameWidgets;
    WidgetStyle *widgetStyle;
    UIImage *xicon;
    UIFont *theFont;

    UITextField *_currentField;
    BOOL keyboardIsShown;
    CGSize keyboardSize;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UIView *selectionsView;
@property (nonatomic, retain) IBOutlet UIView *searchView;

@property (nonatomic, retain) CCSearchBar *ccSearchBar;

@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;

- (IBAction)tapDoneButton;

- (IBAction)tapCancelButton;

@end
