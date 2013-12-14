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
    [self preloadData];
    
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

- (void) preloadData
{
    contactSvc = [[ContactManager alloc] init];
    
    [contactSvc apiPrivacyListBlocks:[DataModel shared].user.contact_key callback:^(NSArray *keys) {
        _blockedKeys = keys;
        [self listMyChats];
    }];
}
- (void)listMyChats
{
    NSLog(@"%s", __FUNCTION__);
    self.tableData =[[NSMutableArray alloc]init];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading"];
    [self.hud setDimBackground:YES];
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
            ChatVO *lookup = [chatSvc loadChatByKey:chat.system_id];
            if (lookup == nil) {
                // need to add
                [chatSvc saveChat:chat];
                chat.hasNew = YES;
                
            } else {
                // ignore
                
                NSTimeInterval serverTime = [chat.updatedAt timeIntervalSince1970];
                
                NSLog(@"Compare localTime %f vs. serverTime %f", lookup.read_timestamp.doubleValue, serverTime);
                
                if (lookup.read_timestamp.doubleValue + kTimestampDelay < serverTime) {
                    chat.hasNew = YES;
                } else {
                    chat.hasNew = NO;
                }
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
            
            [DataModel shared].chat = (ChatVO *)[tableData objectAtIndex:indexPath.row];
            
            [_delegate gotoSlideWithName:@"Chat"];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
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
