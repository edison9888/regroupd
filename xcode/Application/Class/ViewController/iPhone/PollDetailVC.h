//
//  PollDetailVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCTableViewCell.h"
#import "ContactVO.h"
#import "FormManager.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "SideScrollVC.h"

@interface PollDetailVC : SlideViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    FormManager *formSvc;
    
}

@property (nonatomic, retain) SideScrollVC *carouselVC;

@property (nonatomic, retain) IBOutlet UIView *browseView;
@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *counterLabel;


@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property(retain) NSMutableArray *tableData;
- (void)performSearch:(NSString *)searchText;


- (IBAction)tapCloseButton;
- (IBAction)tapLeftArrow;
- (IBAction)tapRightArrow;


- (void) loadFormOptions;

@end
