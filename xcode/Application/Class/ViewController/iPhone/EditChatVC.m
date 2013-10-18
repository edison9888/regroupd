//
//  EditChatVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "EditChatVC.h"
#import "DataModel.h"

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
    
    xpos = 3;
    ypos = 3;
    
    contactsMap = [[NSMutableDictionary alloc] init];
    contactIds = [[NSMutableArray alloc] init];
    
    CGRect searchFrame = CGRectMake(5, 150, 310, 32);
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];
    ccSearchBar.delegate = self;
    [self.view addSubview:ccSearchBar];

    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
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
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"CCTableCell";
    static NSString *CellNib = @"CCTableViewCell";
    
    CCTableViewCell *cell = (CCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (CCTableViewCell *)[nib objectAtIndex:0];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.rowdata = rowData;
        
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
            
            [contactsMap setObject:contact forKey:[NSNumber numberWithInt:contact.contact_id]];
            
            [contactIds addObject:[NSNumber numberWithInt:contact.contact_id]];
            
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

            [item setFieldLabel:@"Hugh Lang"];
            
            
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
        NSString *sqlTemplate = @"select * from contact where name like '%%%@%%' limit 20";
        
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
    
    if (contactIds.count == 0) {
        isOK = NO;
    }
    if (isOK) {
        ChatVO *chat = [[ChatVO alloc] init];
        
        
        chat.name = @"Test Chat";
        
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
