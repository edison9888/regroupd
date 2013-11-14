//
//  EditGroupVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "EditGroupVC.h"
#import "DataModel.h"
#import "ContactManager.h"

#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

#define kSearchViewBGColor 0xCACFD0

@interface EditGroupVC ()

@end

@implementation EditGroupVC

@synthesize tableData;
@synthesize ccSearchBar;
@synthesize navTitle;

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
    
    chatSvc = [[ChatManager alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    
    if ([[DataModel shared].action isEqualToString:kActionADD]) {
        self.navTitle.text = @"New Group";
        self.groupName.text = @"new group";
        
    } else {
        self.navTitle.text = @"Edit Group";
    }
    
    xpos = 3;
    ypos = 3;
    
    contactsMap = [[NSMutableDictionary alloc] init];
    contactKeys = [[NSMutableArray alloc] init];
    
    CGRect searchFrame = CGRectMake(5,5,300,36);
    
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];
    ccSearchBar.delegate = self;
    [self.searchView addSubview:ccSearchBar];
    [self.searchView.layer setCornerRadius:3.0];
    self.searchView.backgroundColor = [UIColor clearColor];
    
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.hidden = YES;
    [self.theTableView setSeparatorColor:[UIColor grayColor]];
    
    
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    [self performSearch:@""];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UISearchBar
/*
 SOURCE: http://jduff.github.com/2010/03/01/building-a-searchview-with-uisearchbar-and-uitableview/
 */

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [ccSearchBar setShowsCancelButton:NO animated:YES];
    
    self.theTableView.allowsSelection = YES;
    self.theTableView.scrollEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length > 0) {
        self.searchView.backgroundColor = [UIColor colorWithHexValue:kSearchViewBGColor];
        self.theTableView.hidden = NO;
        [self performSearch:searchText];
    } else {
        self.searchView.backgroundColor = [UIColor clearColor];
        self.theTableView.hidden = YES;
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s", __FUNCTION__);
    ccSearchBar.text=@"";
    
    //    self.theTableView.hidden = YES;
    selectedIndex = -1;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSLog(@"search text=%@", _searchBar.text);
    
    [self performSearch:_searchBar.text];
    
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    static NSString *CellIdentifier = @"ContactTVC";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.frame = CGRectMake(0, 0, 300, 36);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
            cell.textLabel.textColor = [UIColor colorWithHexValue:0x111111];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:kFullNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            NSString *contactKey = (NSString *) [rowdata objectForKey:@"contact_key"];
            NSString *fullname = [NSString stringWithFormat:kFullNameFormat, [rowdata objectForKey:@"first_name"], [rowdata objectForKey:@"last_name"]];
            
            //            if (![contactKeys containsObject:contact.system_id]) {
            [contactKeys addObject:contactKey];
            
            float estWidth = 100;
            if (xpos + estWidth + 10 > self.selectionsView.frame.size.width) {
                xpos = 0;
                ypos +=30;
            }
            if (ypos + 30 > self.selectionsView.frame.size.height) {
                CGRect sframe = self.selectionsView.frame;
                sframe.size.height += 30;
                self.selectionsView.frame = sframe;
            }
            
            CGRect itemFrame = CGRectMake(xpos, ypos, estWidth, 24);
            SelectedItemWidget *item = [[SelectedItemWidget alloc] initWithFrame:itemFrame];
            
            [item setFieldLabel:fullname];
            
            
            [self.selectionsView addSubview:item];
            
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from phonebook where status=1 and (first_name like '%%%@%%' or last_name like '%%%@%%') limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText, searchText];
        NSLog(@"sql=%@", sql);
        
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
            NSLog(@"Result %@", [dict objectForKey:@"first_name"]);
        }
        isLoading = NO;
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate = @"select * from phonebook where status=1 order by last_name";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
}

#pragma mark - Action handlers

- (IBAction)tapDoneButton
{
    //    BOOL isOk = YES;
    
    BOOL isOK = YES;
    
    if (contactKeys.count == 0) {
        isOK = NO;
    }
    if (isOK) {
        
        // TODO: save to group table
        GroupVO *group = [[GroupVO alloc] init];
        group.name = self.groupName.text;
        group.system_id = @"";
        group.status = 0;
        group.type = 1;
        
        if (groupSvc == nil) {
            groupSvc = [[GroupManager alloc] init];
        }
        int groupId = [groupSvc saveGroup:group];
        
        NSLog(@"New groupId %i", groupId);
        
        for (NSNumber*  contactId in contactKeys) {
            
            BOOL exists = [groupSvc checkGroupContact:groupId contactId:contactId.intValue];
            
            if (!exists) {
                [groupSvc addGroupContact:groupId contactId:contactId.intValue];
            }
        }
        
        [_delegate gotoSlideWithName:@"GroupsHome"];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Try again" message:@"Please add at least one contact" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    }
    
    
}

- (IBAction)tapCancelButton
{
    [_delegate goBack];
}
@end
