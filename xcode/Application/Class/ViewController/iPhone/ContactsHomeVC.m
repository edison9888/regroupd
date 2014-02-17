//
//  ContactsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ContactsHomeVC.h"
#import "ContactTableViewCell.h"
#import "ContactHeadingCell.h"
#import "OtherContactCell.h"

#import "UIColor+ColorWithHex.h"

#define kStatusAvailable @"Available"

@interface ContactsHomeVC ()

@end

@implementation ContactsHomeVC
@synthesize ccSearchBar;


@synthesize contactsData;
@synthesize groupsData;
//@synthesize addressBookData;
@synthesize otherContacts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    contactSvc = [[ContactManager alloc] init];
    groupSvc = [[GroupManager alloc] init];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    self.theTableView.userInteractionEnabled = YES;
    
    CGRect tableFrame = self.theTableView.frame;
    tableFrame.size.height = [DataModel shared].stageHeight - tableFrame.origin.y - 50;
    self.theTableView.frame = tableFrame;
    
    CGRect searchFrame = CGRectMake(10,57,300,32);
    
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];
    [self.theTableView setSeparatorColor:[UIColor colorWithHexValue:0xEEEEEEE]];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        ccSearchBar.layer.borderColor = [UIColor colorWithHexValue:0xAAAAAA].CGColor;
        ccSearchBar.layer.borderWidth = 1.0;
        ccSearchBar.layer.cornerRadius = 3;
        [self.theTableView setSeparatorInset:UIEdgeInsetsZero];

    }
    
    ccSearchBar.delegate = self;
    [self.view addSubview:ccSearchBar];
    [self.view.layer setCornerRadius:3.0];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.contactsData =[[NSMutableArray alloc]init];
    self.groupsData =[[NSMutableArray alloc]init];
    self.otherContacts =[[NSMutableArray alloc]init];
    
    //    [self populateFromAddressBook];
    //    self.contactsData =[[NSMutableArray alloc]init];
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.delaysTouchesEnded = NO;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;

    [self.view addGestureRecognizer:tapRecognizer];

    
    [self performSearch:@""];
    
    [self performSelector:@selector(preparePhonebook:)
               withObject:nil
               afterDelay:3.0];
    
    
    //    [self preparePhonebook];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Data Load

- (void)performSearch:(NSString *)searchText
{
    NSString *sql;
    
    [contactsData removeAllObjects];
    [self buildAvailableContactsList:searchText];
    
    
    // ################ other contacts ##################
    [otherContacts removeAllObjects];
    [self buildOtherContactsList:searchText];
    
    
    [self.groupsData removeAllObjects];
    
    sql = @"select * from chat where status=1 and user_key='%@' and name like '%%%@%%' order by name";
    sql = [NSString stringWithFormat:sql, [DataModel shared].user.user_key, searchText];
    
    isLoading = YES;
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    
    while ([rs next]) {
        NSDictionary *dict =[rs resultDictionary];
        NSLog(@"Result %@", [dict objectForKey:@"name"]);
        [self.groupsData addObject:dict];
    }
    
    isLoading = NO;
    
    [self.theTableView reloadData];
    
}
- (void) buildAvailableContactsList:(NSString *)searchText {
    FMResultSet *rs;
    
    if (searchText.length > 0) {
        int status = 1;
        NSString *sql = @"select distinct record_id, first_name, last_name from phonebook  where (first_name like '%%%@%%' or last_name like '%%%@%%') and status=%i order by last_name";
        //    sqlTemplate = @"select * from phonebook where (first_name like '%%%@%%' or last_name like '%%%@%%') and status=%i order by last_name";
        sql = [NSString stringWithFormat:sql, searchText, searchText, status];
        
        rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        while ([rs next]) {
            
            NSDictionary *dict =[rs resultDictionary];
            [contactsData addObject:dict];
        }
        NSLog(@"contactsData %i", contactsData.count);
        
    } else {
        
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        
        NSString *alphaSql = @"select distinct CASE last_name  WHEN '' THEN substr(first_name, 1, 1) ELSE substr(last_name, 1, 1) END as alpha, CASE last_name  WHEN '' THEN first_name ELSE last_name END as sortval, pb.first_name, pb.last_name, pb.contact_key, pb.phone from phonebook pb where status=1 order by sortval, first_name";
        
        rs = [[SQLiteDB sharedConnection] executeQuery:alphaSql];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            [tmpArray addObject:dict];
        }
        NSString *alpha;
        NSString *lastAlpha = @"";
        NSDictionary *sectionDict;
        int pointer = 0;
        
        for (NSDictionary *dict in tmpArray) {
            alpha = [dict objectForKey:@"alpha"];
            
            if ([alpha isEqualToString:lastAlpha]) {
                [contactsData addObject:dict];
                
            } else {
                sectionDict = [[NSMutableDictionary alloc] init];
                [sectionDict setValue:alpha forKey:@"heading"];
                [contactsData addObject:sectionDict];
                [contactsData addObject:dict];
                lastAlpha = alpha;
            }
            pointer++;
        }
        
        NSLog(@"contactsData %i", contactsData.count);
    }
}
- (void) buildOtherContactsList:(NSString *)searchText {
    FMResultSet *rs;
    
    if (searchText.length > 0) {
        int status = 0;
        NSString *sql = @"select distinct record_id, first_name, last_name from phonebook  where (first_name like '%%%@%%' or last_name like '%%%@%%') and status=%i order by last_name";
        //    sqlTemplate = @"select * from phonebook where (first_name like '%%%@%%' or last_name like '%%%@%%') and status=%i order by last_name";
        sql = [NSString stringWithFormat:sql, searchText, searchText, status];
        
        rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        while ([rs next]) {
            
            NSDictionary *dict =[rs resultDictionary];
            [otherContacts addObject:dict];
        }
        NSLog(@"otherContacts %i", otherContacts.count);
        
    } else {
        
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        
        NSString *alphaSql = @"select distinct CASE last_name  WHEN '' THEN substr(first_name, 1, 1) ELSE substr(last_name, 1, 1) END as alpha, CASE last_name  WHEN '' THEN first_name ELSE last_name END as sortval, pb.record_id, pb.first_name, pb.last_name from phonebook pb where status=0 order by sortval, first_name";
        
        rs = [[SQLiteDB sharedConnection] executeQuery:alphaSql];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            [tmpArray addObject:dict];
        }
        NSString *alpha;
        NSString *lastAlpha = @"";
        NSDictionary *sectionDict;
        int pointer = 0;
        [otherContacts removeAllObjects];
        
        for (NSDictionary *dict in tmpArray) {
            alpha = [dict objectForKey:@"alpha"];
            
            if ([alpha isEqualToString:lastAlpha]) {
                [otherContacts addObject:dict];
                
            } else {
                sectionDict = [[NSMutableDictionary alloc] init];
                [sectionDict setValue:alpha forKey:@"heading"];
                [otherContacts addObject:sectionDict];
                [otherContacts addObject:dict];
                lastAlpha = alpha;
            }
            pointer++;
        }
        
        NSLog(@"otherContacts %i", otherContacts.count);
    }
}
- (void) preparePhonebook:(id)sender {
    
    //    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    [self.hud setLabelText:@"Loading..."];
    
    [contactSvc purgePhonebook];
    NSMutableArray *people = [contactSvc readAddressBook];
    NSLog(@"Found addressbook contacts to load qty:%i", people.count);
    
    [contactSvc bulkLoadPhonebook:[people copy]];
    
    NSMutableArray *others = [contactSvc listPhonebookByStatus:0];
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    NSDictionary *dict;
    NSString *phoneId;
    for (int i=0; i<others.count; i++) {
        dict = (NSDictionary *) [others objectAtIndex:i];
        phoneId = (NSString *)[dict objectForKey:@"phone"];
        [numbers addObject:phoneId];
    }
    
    [self batchLookupContactsByPhoneNumbers:numbers];
    
}
// http://stackoverflow.com/questions/6852012/what-is-an-easy-way-to-break-an-nsarray-with-4000-objects-in-it-into-multiple-a
- (void) batchLookupContactsByPhoneNumbers:(NSMutableArray *)srcArray {
    NSMutableArray *arrayOfArrays = [NSMutableArray array];
    
    int itemsRemaining = [srcArray count];
    int j = 0;
    
    while(j < [srcArray count]) {
        NSRange range = NSMakeRange(j, MIN(50, itemsRemaining));
        NSArray *subarray = [srcArray subarrayWithRange:range];
        [arrayOfArrays addObject:subarray];
        itemsRemaining-=range.length;
        j+=range.length;
    }
    NSLog(@"Total srcArray size %i", srcArray.count);
    if (srcArray.count > 0) {
        for (int i=0; i<arrayOfArrays.count; i++) {
            NSLog(@"batchLookupContactsByPhoneNumbers %i", i);
            NSArray *numbers = (NSArray *) [arrayOfArrays objectAtIndex:i];
            @try {
                [contactSvc apiLookupContactsByPhoneNumbers:numbers callback:^(NSArray *contacts) {
                    NSLog(@"Callback response count %i", contacts.count);
                    if (contacts) {
                        [contactSvc updatePhonebookWithContacts:contacts];
                    }
                    if (i+1 == arrayOfArrays.count) {
                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                        
                        [self performSearch:@""];
                    }
                }];
            }
            @catch (NSException *exception) {
                NSLog(@"ERROR %@", exception);
            }
            
        }
        
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
    }
    
}

#pragma mark - UISearchBar
/*
 SOURCE: http://jduff.github.com/2010/03/01/building-a-searchview-with-uisearchbar-and-uitableview/
 */

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [ccSearchBar setShowsCancelButton:YES animated:YES];
    
    self.theTableView.allowsSelection = YES;
    self.theTableView.scrollEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self performSearch:searchText];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s", __FUNCTION__);
    ccSearchBar.text=@"";
    
    //    self.theTableView.hidden = YES;
    selectedIndex = -1;
    UITextField *txfSearchField = [ccSearchBar valueForKey:@"_searchField"];
    [txfSearchField resignFirstResponder];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSLog(@"search text=%@", _searchBar.text);
    UITextField *txfSearchField = [ccSearchBar valueForKey:@"_searchField"];
    [txfSearchField resignFirstResponder];
    
    [self performSearch:_searchBar.text];
    
}



- (void)keyboardWillHide:(NSNotification *)n
{
#ifdef kDEBUG
    NSLog(@"===== %s", __FUNCTION__);
#endif
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self hideKeyboard:keyboardSize];
}

- (void)keyboardWillShow:(NSNotification *)n
{
#ifdef kDEBUG
    NSLog(@"===== %s", __FUNCTION__);
#endif
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self showKeyboard:keyboardSize];
    
}
- (void) showKeyboard:(CGSize)keyboardSize
{
    // resize the noteView
    CGRect viewFrame = self.theTableView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height = [DataModel shared].stageHeight - keyboardSize.height - viewFrame.origin.y;
    
    [self.theTableView setFrame:viewFrame];
    keyboardIsShown = YES;
    
}
- (void) hideKeyboard:(CGSize)keyboardSize
{
    // resize the scrollview
    CGRect viewFrame = self.theTableView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height = [DataModel shared].stageHeight - viewFrame.origin.y;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    
    [self.theTableView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
    
}


#pragma mark - UITableViewDataSource


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
            
        case 0:
            title = @"Available Contacts";
            break;
            
        case 1:
            title = @"Groups";
            break;
            
        case 2:
            title = @"Invite friends to re:group'd";
            break;
            
        default:
            break;
    }
    CGRect headerFrame = CGRectMake(0, 0, [DataModel shared].stageWidth, 30);
    
    UIView* customView = [[UIView alloc] initWithFrame:headerFrame];
    if(section==0 || section==1  || section==2)
    {
        customView.backgroundColor = [UIColor colorWithHexValue:0xd6dde1];
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        [headerLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:14]];
        headerLabel.frame = CGRectMake(10, 2, 300, 20);
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = title;
        
        [customView addSubview:headerLabel];
    }
    
    
    
    return customView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.contactsData.count == 0) {
            return 1;
        } else {
            return [self.contactsData count];
        }
    } else if (section == 1) {
        if (self.groupsData.count == 0) {
            return 1;
        } else {
            return [self.groupsData count];
        }
    } else if (section == 2) {
        return self.otherContacts.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (contactsData.count > 0) {
            NSDictionary *rowdata = [contactsData objectAtIndex:indexPath.row];
            if ([rowdata objectForKey:@"heading"]) {
                return 25;
            } else {
                return 50;
            }
        } else {
            return 40;
        }
    } else if (indexPath.section == 1) {
        return 40;
    } else if (indexPath.section == 2) {
        if (otherContacts.count > 0) {
            NSDictionary *rowdata = [otherContacts objectAtIndex:indexPath.row];
            if ([rowdata objectForKey:@"heading"]) {
                return 25;
            } else {
                return 40;
            }
        } else {
            return 40;
        }
    } else {
        return 40;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    static NSString *CellIdentifier = @"ContactTableCell";
    //    static NSString *CellNib = @"ContactTableViewCell";
    
    if (indexPath.section == 0) {
        if (contactsData.count == 0) {
            // TODO: replace this with generic UITableViewCell for performance
            OtherContactCell *cell = (OtherContactCell *)[tableView dequeueReusableCellWithIdentifier:kContactTableViewCell_ID];
            @try {
                
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OtherContactCell" owner:self options:nil];
                    cell = (OtherContactCell *)[nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.titleLabel.text = @"No contacts";
                
            } @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
            
            return cell;
        } else {
            NSDictionary *rowdata = (NSDictionary *) [contactsData objectAtIndex:indexPath.row];
            //        UITableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if ([rowdata objectForKey:@"heading"]) {
                ContactHeadingCell *cell = (ContactHeadingCell *)[tableView dequeueReusableCellWithIdentifier:kContactHeadingCell_ID];
                @try {
                    
                    if (cell == nil) {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactHeadingCell" owner:self options:nil];
                        cell = (ContactHeadingCell *)[nib objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                    cell.titleLabel.text = [rowdata objectForKey:@"heading"];
                    
                } @catch (NSException * e) {
                    NSLog(@"Exception: %@", e);
                }
                
                return cell;
                
            } else {
                // TODO: replace this with generic UITableViewCell for performance
                ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kContactTableViewCell_ID];
                @try {
                    
                    if (cell == nil) {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactTableViewCell" owner:self options:nil];
                        cell = (ContactTableViewCell *)[nib objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                    if (contactsData.count > 0) {
                        //                cell.titleLabel.text = [NSString stringWithFormat:kFullNameFormat, [rowdata objectForKey:@"first_name"], [rowdata objectForKey:@"last_name"]];
                        cell.titleLabel.text = [self readFullnameFromDictionary:rowdata];
                        cell.statusLabel.text = kStatusAvailable;
                        
                    } else {
                        cell.titleLabel.text = @"No contacts";
                        cell.statusLabel.text = @"";
                    }
                    
                } @catch (NSException * e) {
                    NSLog(@"Exception: %@", e);
                }
                
                return cell;
            }
            
        }
    } else if  (indexPath.section == 1) {
        // Groups
        OtherContactCell *cell = (OtherContactCell *)[tableView dequeueReusableCellWithIdentifier:kOtherContactCell_ID];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OtherContactCell" owner:self options:nil];
                cell = (OtherContactCell *)[nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (groupsData.count > 0) {
                NSDictionary *rowdata = [self.groupsData objectAtIndex:indexPath.row];
                NSString *name = [rowdata objectForKey:@"name"];
                cell.titleLabel.text = name;
                
            } else {
                cell.titleLabel.text = @"No groups";
            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        
        if (otherContacts.count == 0) {
            OtherContactCell *cell = (OtherContactCell *)[tableView dequeueReusableCellWithIdentifier:kOtherContactCell_ID];
            @try {
                
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OtherContactCell" owner:self options:nil];
                    cell = (OtherContactCell *)[nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.titleLabel.text = @"No contacts to invite";
                
            } @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
            
            return cell;
            
        } else {

            NSDictionary *rowdata = (NSDictionary *) [otherContacts objectAtIndex:indexPath.row];
            //        UITableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if ([rowdata objectForKey:@"heading"]) {
                ContactHeadingCell *cell = (ContactHeadingCell *)[tableView dequeueReusableCellWithIdentifier:kContactHeadingCell_ID];
                @try {
                    
                    if (cell == nil) {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactHeadingCell" owner:self options:nil];
                        cell = (ContactHeadingCell *)[nib objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                    cell.titleLabel.text = [rowdata objectForKey:@"heading"];
                    
                } @catch (NSException * e) {
                    NSLog(@"Exception: %@", e);
                }
                
                return cell;
                
            } else {
                OtherContactCell *cell = (OtherContactCell *)[tableView dequeueReusableCellWithIdentifier:kOtherContactCell_ID];
                @try {
                    
                    if (cell == nil) {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OtherContactCell" owner:self options:nil];
                        cell = (OtherContactCell *)[nib objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                    cell.titleLabel.text = [self readFullnameFromDictionary:rowdata];
                    
                } @catch (NSException * e) {
                    NSLog(@"Exception: %@", e);
                }
                
                return cell;
                
            }
            
        }
        
        
        
        
    }
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        @try {
            NSDictionary *rowdata = [contactsData objectAtIndex:indexPath.row];
            if ([rowdata objectForKey:@"heading"]) {
                return;
            } else {
                NSLog(@"Selected row %i", indexPath.row);
                
                selectedIndex = indexPath.row;
                NSDictionary *rowdata = [contactsData objectAtIndex:indexPath.row];
                
                [DataModel shared].contact = [ContactVO readFromPhonebook:rowdata];
                [_delegate gotoSlideWithName:@"ContactInfo"];
                
            }
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
    } else if (indexPath.section == 1) {
        
        if (self.groupsData.count == 0) {
            [self.theTableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        } else {
            NSDictionary *rowdata = [self.groupsData objectAtIndex:indexPath.row];
            NSString *chatKey = [rowdata objectForKey:@"system_id"];
            GroupVO *group = [groupSvc findGroupByChatKey:chatKey];
            
            if (group) {
                [DataModel shared].group = group;
                
                [DataModel shared].action = kActionEDIT;
                [_delegate setBackPath:@"ContactsHome"];
                [_delegate gotoSlideWithName:@"GroupInfo" andOverrideTransition:kPresentationTransitionPush|kPresentationTransitionLeft];
                
            } else {
                NSLog(@"Could not find group by chatKey %@", chatKey);
            }
            
        }
        
    } else if (indexPath.section == 2) {
        
        NSDictionary *rowdata = [otherContacts objectAtIndex:indexPath.row];
        
        if ([rowdata objectForKey:@"heading"]) {
            return;
        } else {
            ContactVO *contact = [ContactVO readFromPhonebook:rowdata];
            
            if (contact.record_id != nil) {
                contact = [contactSvc readContactFromAddressBook:contact.record_id];
                
                
                if (contact) {
                    BOOL success = YES;
                    if (contact.phoneNumbers.count > 0) {
                        success = [self createSMSInvite:contact.phoneNumbers];
                    }
                    if (!success && contact.email != nil) {
                        [self createEmailInvite:contact.email];
                    } else {
                        // Do nothing or display alert
                    }
                }
            }
            
        }
        
    }
    
    
}

#pragma mark - MessageUI

- (BOOL) createEmailInvite:(NSString *)email {
    // Email Content
    NSString *subject = @"Join re:group'd";
    NSString *message = @"Hey! Check out re:group'd, an awesome new chatting app for your smartphone! Download it today at www.getregroupd.com";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:email];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setMessageBody:message isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    return YES;
    
}

- (BOOL) createSMSInvite:(NSArray *)phones {
    
    NSString *subject = @"Join re:group'd";
    // To address
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        [messageComposer setBody:@"www.getregroupd.com"];
        messageComposer.subject = subject;
        messageComposer.recipients = phones;
        messageComposer.messageComposeDelegate = self;
        [self presentViewController:messageComposer animated:YES completion:nil];
        return YES;
    } else {
        return NO;
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultCancelled) {
        //Message cancelled
    } else if(result == MessageComposeResultSent) {
        //Message sent
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Tap Gesture

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        if (keyboardIsShown) {
            UITextField *txfSearchField = [ccSearchBar valueForKey:@"_searchField"];
            [txfSearchField resignFirstResponder];
            
        }
    }
}

#pragma mark - Action handlers

- (IBAction)tapAddButton
{
    //    //    BOOL isOk = YES;
    //    NSNotification* showMaskNotification = [NSNotification notificationWithName:@"showMaskNotification" object:nil];
    //    [[NSNotificationCenter defaultCenter] postNotification:showMaskNotification];
    
    [self showModal];
    
}

- (IBAction)tapEditButton
{
    
}

- (IBAction)tapNewContactButton {
    ABNewPersonViewController *newContactVC = [[ABNewPersonViewController alloc] init];
    
    newContactVC.newPersonViewDelegate = self;
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    
    UINavigationController *newNavigationController = [[UINavigationController alloc]
                                                       initWithRootViewController:newContactVC];
    
    [self presentViewController:newNavigationController animated:YES completion:nil];
    
    
}
- (IBAction)tapNewGroupButton {
    [DataModel shared].action = kActionADD;
    [_delegate gotoSlideWithName:@"EditGroup" returnPath:@"ContactsHome"];
}
- (IBAction)tapCancelButton {
    [self hideModal];
}


- (void) showModal {
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = 666;
    [self.view addSubview:bgLayer];
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height;
    float xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    NSLog(@"modal at %f, %f", xpos, ypos);
    self.addModal.layer.zPosition = 99;
    self.addModal.frame = modalFrame;
    [self.view addSubview:self.addModal];
    
    ypos = ([DataModel shared].stageHeight - modalFrame.size.height) / 2;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}

- (void) hideModal {
    
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height - 40;
    modalFrame.origin.y = ypos;
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                         
                         NSNotification* hideMaskNotification = [NSNotification notificationWithName:@"hideMaskNotification" object:nil];
                         [[NSNotificationCenter defaultCenter] postNotification:hideMaskNotification];
                         
                     }];
    
    
}

#pragma mark ABNewPersonViewControllerDelegate methods

// Dismisses the new-person view controller.

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person

{
    NSLog(@"%s", __FUNCTION__);
    [self hideModal];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    [self preparePhonebook:nil];
}

- (NSString *) makePhoneId:(NSString *)originalString {
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return strippedString;
}


- (ContactVO *) readContactFromABPerson:(ABRecordRef)person
{
    ContactVO* c = [[ContactVO alloc] init];
    
    ABRecordID abRecordID = ABRecordGetRecordID(person);
    NSNumber *recordId = [NSNumber numberWithInt:abRecordID];
    
    NSLog(@"RecordId = %@", recordId);
    
    if (recordId > 0) {
        CFErrorRef err;
        ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, &err);
        __block BOOL accessGranted = NO;
        
        if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //        dispatch_release(sema);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted)
        {
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            //            ABMultiValueRef profiles = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
            //            CFIndex multiCount = ABMultiValueGetCount(profiles);
            //            for (CFIndex i=0; i<multiCount; i++) {
            //                NSDictionary* profile = ( NSDictionary*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(profiles, i));
            //                NSLog(@"Profile: %@", profile);
            //                c.facebook_id=[profile objectForKey:@"identifier"];
            //            }
            //            CFRelease(profiles);
            NSString *phoneNumber;
            if(phones)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, 0);
                CFRelease(phones);
                phoneNumber = (__bridge NSString *)phoneNumberRef;
                c.phone=phoneNumber;
            }
            if (ABPersonHasImageData(person))
            {
                UIImage *image = [UIImage imageWithData:(NSData *)CFBridgingRelease(ABPersonCopyImageData(person))];
                if(image) {
                    //                    p.imagen=image;
                }
            } else  {
                //                p.imagen=[UIImage imageNamed:@"profile-default-sm.png"];
            }
            CFStringRef email = ABMultiValueCopyValueAtIndex(emails, 0);
            CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            c.first_name = (__bridge NSString *)firstName;
            c.last_name = (__bridge NSString *)lastName;
            
            if (firstName)
                CFRelease(firstName);
            if (lastName)
                CFRelease(lastName);
            if(email)
                CFRelease(email);
            CFRelease(emails);
        }
        CFRelease(ab);
        return c;
        
    } else {
        return nil;
    }
    
}

- (NSString *) readFullnameFromDictionary:(NSDictionary *)rowdata {
    //    NSLog(@"lastname %@", [rowdata objectForKey:@"last_name"]);
    if ([rowdata objectForKey:@"first_name"] != nil && [rowdata objectForKey:@"last_name"] == nil) {
        return [rowdata objectForKey:@"first_name"];
    } else if ([rowdata objectForKey:@"first_name"] == nil && [rowdata objectForKey:@"last_name"] != nil) {
        return [rowdata objectForKey:@"last_name"];
    } else {
        return [NSString stringWithFormat:kFullNameFormat, [rowdata objectForKey:@"first_name"], [rowdata objectForKey:@"last_name"]];
    }
}


@end
