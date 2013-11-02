//
//  EditChatVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "EditChatVC.h"
#import "DataModel.h"
#import "UIColor+ColorWithHex.h"

#define kcontactsRowHeight  25
#define kcontactsGap  5

@interface EditChatVC ()

@end

@implementation EditChatVC

@synthesize tableData;
@synthesize ccSearchBar;

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
    
    xpos = 0;
    ypos = 3;
    
    contactsMap = [[NSMutableDictionary alloc] init];
    contactKeys = [[NSMutableArray alloc] init];
    
    CGRect searchFrame = CGRectMake(5, 5, 300, 36);
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];
    ccSearchBar.delegate = self;
    [self.searchView addSubview:ccSearchBar];
 
    [self.searchView.layer setCornerRadius:3.0];
//    self.searchView.backgroundColor = [UIColor clearColor];
    
    
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
    
    self.theTableView.hidden = NO;
    [self performSearch:searchText];
    
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
    return 54;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            ContactVO *contact;
            contact = [ContactVO readFromDictionary:rowdata];
            [DataModel shared].contact = contact;
            
//            [contactsMap setObject:contact forKey:[NSNumber numberWithInt:contact.contact_id]];
            
//            if (![contactKeys containsObject:contact.system_id]) {
                [contactKeys addObject:contact.system_id];
                NSString *fullname = [NSString stringWithFormat:kFullNameFormat, contact.first_name, contact.last_name];
            
                float estWidth = fullname.length * 8 + 10;
                if (xpos + estWidth + 10 > self.selectionsView.frame.size.width) {
                    xpos = 0;
                    ypos +=kcontactsRowHeight;
                }
                
                if (ypos + kcontactsRowHeight > self.selectionsView.frame.size.height) {
                    CGRect sframe = self.selectionsView.frame;
                    sframe.size.height += kcontactsRowHeight;
                    self.selectionsView.frame = sframe;
                    
                    CGRect searchFrame = self.searchView.frame;
                    if (sframe.origin.y + sframe.size.height > searchFrame.origin.y) {
                        searchFrame.origin.y += kcontactsRowHeight;
                        searchFrame.size.height -= kcontactsRowHeight;
                        self.searchView.frame = searchFrame;
                    }
                }
                
                CGRect itemFrame = CGRectMake(xpos, ypos, estWidth, 24);
                SelectedItemWidget *item = [[SelectedItemWidget alloc] initWithFrame:itemFrame];
                
                [item setFieldLabel:fullname];

                xpos += estWidth + 10;
                [self.selectionsView addSubview:item];
                
//            }
            
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from contact where first_name like '%%%@%%' or last_name like '%%%@%%' limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            [tableData addObject:[rs resultDictionary]];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate = @"select * from contact order by name";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            NSLog(@"Result %@", [dict objectForKey:@"name"]);
            
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
        
        NSLog(@"contact keys count = %i", contactKeys.count);

        [contactKeys addObject:[DataModel shared].user.contact_key];
         
        ChatVO *chat = [[ChatVO alloc] init];
        
        chat.contact_keys = [contactKeys copy];
        
        NSString *objectId = [chatSvc apiSaveChat:chat];
        
        chat.system_id = objectId;
        
        [chatSvc saveChat:chat];
        
        [DataModel shared].chat = chat;
        
        [_delegate gotoSlideWithName:@"Chat"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Try again" message:@"Please add at least one contact" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    }
    
    
}

- (IBAction)tapCancelButton
{
    [_delegate gotoPreviousSlide];
}
@end
