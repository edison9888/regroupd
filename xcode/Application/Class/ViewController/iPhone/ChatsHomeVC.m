//
//  ChatsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ChatsHomeVC.h"
#import "ChatVO.h"

#define kTimestampDelay 10

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
    
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    fetchCount = 0;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self performSearch:nil];
//    [self preloadData];
    
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
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    self.tableData =[[NSMutableArray alloc]init];

    NSString *sql = @"select * from chat where name is not null and status > -1";
    
    isLoading = YES;
    
//    NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [tableData removeAllObjects];
    ChatVO *chat;
    while ([rs next]) {
        chat = [ChatVO readFromDictionary:[rs resultDictionary]];
        NSLog(@"chat.names = %@", chat.names);
        [tableData addObject:chat];
    }
    isLoading = NO;
    
    [self.theTableView reloadData];

//    [self performSelector:@selector(preloadData:)
//               withObject:nil
//               afterDelay:1.0];
    [self preloadData:nil];
    
}


- (void) preloadData:(id)sender
{
    contactSvc = [[ContactManager alloc] init];
    
    [contactSvc apiPrivacyListBlocks:[DataModel shared].user.contact_key callback:^(NSArray *keys) {
        _blockedKeys = keys;
        for (NSString *key in keys) {
            [chatSvc updateChatStatus:key status:-1];
        }
        [self listMyChats:nil];
    }];
}
- (void)listMyChats:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    self.tableData =[[NSMutableArray alloc]init];
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self.hud setLabelText:@"Loading"];
//    [self.hud setDimBackground:YES];
    
    contactKeySet = [[NSMutableSet alloc] init];  // collect full set of contact keys
    
    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    
    
    [chatSvc apiListChats:[DataModel shared].user.contact_key callback:^(NSArray *results) {
        fetchCount++;
        NSLog(@"apiListChats response count %i", results.count);
        if (results.count == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self.theTableView reloadData];
            return;
        }
        
        NSMutableArray *chatsArray = [[NSMutableArray alloc] initWithCapacity:results.count];
        ChatVO *chat;
        ChatVO *dbChat;
        
        for (PFObject* result in results) {
            
            NSArray *keys = [result objectForKey:@"contact_keys"];
            NSLog(@"contact keys = %@", keys);
            [contactKeySet addObjectsFromArray:keys];

            chat = [ChatVO readFromPFObject:result];
            BOOL isBlocked = NO;
            if (keys.count == 2) {
                // This is an individual chat. One of the keys belongs to current user.
                for (NSString *key in keys) {
                    if (![key isEqualToString:[DataModel shared].user.contact_key]) {
                        if ([_blockedKeys containsObject:key]) {
                            NSLog(@"Found blocked individual chat with key %@", key);
                            isBlocked = YES;
                        }
                    }
                }
                
            }
            if (isBlocked) {
                continue;
            }
            
            [chatsArray addObject:chat];
            
            
        }
        
        // Loads phonebookCache
        [contactSvc lookupContactsFromPhonebook:[contactKeySet allObjects]];
        
        [contactSvc apiLookupContacts:[contactKeySet allObjects] callback:^(NSArray *results) {
            ContactVO *contact;
            NSString *name;
            
            for (ChatVO *chat in chatsArray) {
                
                NSMutableArray *namesArray = [[NSMutableArray alloc] init];
                
                for (NSString *key in chat.contact_keys) {
                    contact = nil;
                    name = nil;
                    if (![key isEqualToString:[DataModel shared].user.contact_key]) {
                        if ([[DataModel shared].phonebookCache objectForKey:key]) {
                            contact = (ContactVO *) [[DataModel shared].phonebookCache objectForKey:key];
                            if (contact.first_name != nil && contact.last_name != nil) {
                                name = contact.fullname;
                                [namesArray addObject:name];
                                
                                ((ContactVO *) [[DataModel shared].contactCache objectForKey:key]).first_name = contact.first_name;
                                ((ContactVO *) [[DataModel shared].contactCache objectForKey:key]).last_name = contact.last_name;
                                
                            } else if (contact.phone != nil) {
                                name = contact.phone;
                                [namesArray addObject:name];
                            } else {
                                // This is unlikely. Contact results are from address book
                                NSLog(@"Unexpected condition: contact has no name or phone");
                            }
                        } else {
                            if ([[DataModel shared].contactCache objectForKey:key]) {
                                contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:key];
                                name = contact.phone;
                                [namesArray addObject:name];
                            } else {
                                NSLog(@"Unexpected condition: contact not in any cache");
                                name = key;
                                [namesArray addObject:name];
                            }
                        }
                    } else {
                        // Ignore current user
                    }
                    
                    
                }
                NSString *names = [namesArray componentsJoinedByString:@", "];
                chat.names = names;
                
                ChatVO *lookup = [chatSvc loadChatByKey:chat.system_id];
                if (lookup == nil) {
                    // need to add
                    [chatSvc saveChat:chat];
                    chat.hasNew = YES;
                    
                } else {
                    // ignore
//                    [chatSvc updateChatStatus:chat.system_id name:chat.names readtime:[NSNumber numberWithDouble:0.0]];
                    [chatSvc updateChat:chat.system_id withName:names];
                    NSTimeInterval serverTime = [chat.updatedAt timeIntervalSince1970];
                    
//                    NSLog(@"Compare localTime %f vs. serverTime %f", lookup.read_timestamp.doubleValue, serverTime);
                    
                    if (lookup.read_timestamp.doubleValue + kTimestampDelay < serverTime) {
                        chat.hasNew = YES;
                    } else {
                        chat.hasNew = NO;
                    }
                }

                [tableData addObject:chat];
                
            }
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self.theTableView reloadData];
            isLoading = NO;
            
        }];
        
    }];
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
        if (rowData.hasNew) {
            [cell setStatus:1];
        } else {
            [cell setStatus:0];
        }
        
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
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            
            [DataModel shared].chat = (ChatVO *)[tableData objectAtIndex:indexPath.row];
            NSLog(@"Fetching chat %@ with cutoffDate %@", [DataModel shared].chat.system_id, [DataModel shared].chat.cutoffDate);

            [_delegate gotoSlideWithName:@"Chat"];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        ChatVO *chat = [tableData objectAtIndex:indexPath.row];
        
        [chatSvc apiModifyChat:chat.system_id removeContact:[DataModel shared].user.contact_key callback:^(PFObject *pfChat) {
            NSLog(@"ready to delete local chat db");
            if (pfChat) {
                [chatSvc deleteChat:chat];
                [self setEditing:NO animated:YES];
                [self performSearch:@""];
            }
        }];
        
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    
    
    [self.theTableView setEditing:editing];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // i also tried to  return YES;
}

// Select the editing style of each cell
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return UITableViewCellEditingStyleDelete;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
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
    if (inEditMode) {
        inEditMode = NO;
        [self.editButton setTitle:kEditLabel forState:UIControlStateNormal];
        
        [self setEditing:inEditMode animated:YES];
        
        
        [self.theTableView reloadData];
        
    } else {
        inEditMode = YES;
        [self setEditing:inEditMode animated:YES];
        
        [self.editButton setTitle:kDoneLabel forState:UIControlStateNormal];
        
        [self.theTableView reloadData];
        
        
    }

    
}
@end
