//
//  FormsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "FormsTableViewCell.h"
#import "FormVO.h"

@interface FormsHomeVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UIImage *nav0ImageOn;
    UIImage *nav0ImageOff;
    UIImage *nav1ImageOn;
    UIImage *nav1ImageOff;
    UIImage *nav2ImageOn;
    UIImage *nav2ImageOff;
    UIImage *nav3ImageOn;
    UIImage *nav3ImageOff;
    
    
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    UIView *bgLayer;
    
    int typeFilter;

    
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

@property (nonatomic, strong) IBOutlet UIImageView *navImage0;
@property (nonatomic, strong) IBOutlet UIImageView *navImage1;
@property (nonatomic, strong) IBOutlet UIImageView *navImage2;
@property (nonatomic, strong) IBOutlet UIImageView *navImage3;

@property (nonatomic, strong) IBOutlet UIButton *navBtnAll;
@property (nonatomic, strong) IBOutlet UIButton *navBtnPolls;
@property (nonatomic, strong) IBOutlet UIButton *navBtnRatings;
@property (nonatomic, strong) IBOutlet UIButton *navBtnRSVPs;

@property (nonatomic, strong) IBOutlet UIView *addModal;


- (IBAction)tapAddButton;

- (IBAction)tapEditButton;

- (IBAction)tapFormNav:(UIButton*)sender;

// These buttons are for the Add New modal
- (IBAction)tapPollButton;
- (IBAction)tapRatingButton;
- (IBAction)tapRSVPButton;
- (IBAction)tapCancelButton;

- (void) updateFormsNav;
- (void) showModal;
- (void) hideModal;

@end
