//
//  ChatsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ChatsHomeVC.h"
#import "ChatVO.h"

@interface ChatsHomeVC ()

@end

@implementation ChatsHomeVC

@synthesize tableData;

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
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    [self listMyChats];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    static NSString *CellIdentifier = @"ChatTableCell";
    static NSString *CellNib = @"ChatTableViewCell";
    
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (ChatTableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        ChatVO *rowData = (ChatVO *) [tableData objectAtIndex:indexPath.row];
        cell.rowdata = rowData;
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (NSDictionary *) readPFObjectAsDictionary:(PFObject *) data {
    NSArray * allKeys = [data allKeys];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in allKeys) {
        
        [dict setObject:[data objectForKey:key] forKey:key];
        
    }
    return dict;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            
            [DataModel shared].chat = [ChatVO readFromDictionary:rowdata];
            
            [_delegate gotoSlideWithName:@"Chat"];
            
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}

- (void)listMyChats
{
    
    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    
    [chatSvc apiListChats:[DataModel shared].user.contact_key callback:^(NSArray *results) {
        NSLog(@"Callback response objectId %i", results.count);
        ChatVO *chat;
        for (PFObject* result in results) {
//            data = [DataModel readPFObjectAsDictionary:result];
            chat = [ChatVO readFromPFObject:result];
            
            NSArray *keys = [result objectForKey:@"contact_keys"];
            NSLog(@"contact keys = %@", keys);
            
            [contactSvc apiLookupContacts:chat.contact_keys callback:^(NSArray *contacts) {
                NSMutableArray *namesArray = [[NSMutableArray alloc] init];
                NSString *fullname;
                for (ContactVO *contact in contacts) {
                    if (![contact.system_id isEqualToString:[DataModel shared].user.contact_key]) {
                        fullname = [NSString stringWithFormat:kFullNameFormat, contact.first_name, contact.last_name];
                        [namesArray addObject:fullname];
                    }
                }
                NSString *names = [namesArray componentsJoinedByString:@", "];
                chat.names = names;
//                [data setValue:names forKey:@"names"];
                
                isLoading = NO;
                [tableData addObject:chat];
                [self.theTableView reloadData];
            }];
        }
    }];
}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    NSString *sqlTemplate = @"select * from chat order by chat_id desc";
    
    isLoading = YES;
    
    NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [tableData removeAllObjects];
    
    while ([rs next]) {
        [tableData addObject:[rs resultDictionary]];
    }
    isLoading = NO;
    
    [self.theTableView reloadData];
    
    
}

#pragma mark - Action handlers

- (IBAction)tapAddButton
{
    //    BOOL isOk = YES;
    [DataModel shared].action = kActionADD;
    [_delegate gotoNextSlide];
    
}

- (IBAction)tapEditButton
{
    
}
@end
