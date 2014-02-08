//
//  GroupsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "GroupsHomeVC.h"
#import "DateTimeUtils.h"

#define kTimestampDelay 100

@interface GroupsHomeVC ()

@end

@implementation GroupsHomeVC

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
    
    groupSvc = [[GroupManager alloc] init];
    chatSvc = [[ChatManager alloc] init];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    CGRect tableFrame = self.theTableView.frame;
    tableFrame.size.height = [DataModel shared].stageHeight - tableFrame.origin.y - 50;
    self.theTableView.frame = tableFrame;
    
    self.tableData =[[NSMutableArray alloc]init];
        
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    [self performSearch:@""];
    
    
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

#pragma mark - Load Data

- (void)listGroupChats:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
//    self.tableData =[[NSMutableArray alloc]init];
    
    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
    }
    
    [chatSvc apiListChats:[DataModel shared].user.contact_key status:[NSNumber numberWithInt:ChatType_GROUP]  callback:^(NSArray *results) {
        NSLog(@"apiListChats response count %i", results.count);
        if (results.count == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self.theTableView reloadData];
            return;
        }
        
        NSMutableArray *chatsArray = [[NSMutableArray alloc] initWithCapacity:results.count];
        ChatVO *chat;
        //        ChatVO *dbChat;
        
        for (PFObject* result in results) {
            chat = [ChatVO readFromPFObject:result];
            BOOL isBlocked = NO;
            
            NSArray *keys = chat.contact_keys;
            if ([chat.removed_keys containsObject:[DataModel shared].user.contact_key]) {
                isBlocked = YES;
            }
            
            if (keys.count < 2) {
                isBlocked = YES;
                [chatsArray addObject:chat];
            }
            if (isBlocked) {
                continue;
            } else {
                [chatsArray addObject:chat];
            }

        }
        
        for (ChatVO *chat in chatsArray) {
            
            ChatVO *lookup = [chatSvc loadChatByKey:chat.system_id];
            if (lookup == nil) {
                // need to add
                if (chat.status == nil) {
                    chat.status = [NSNumber numberWithInt:ChatType_GROUP];
                }
                [chatSvc saveChat:chat];
                chat.hasNew = YES;
                
            } else {
                // ignore
//                [chatSvc updateChat:chat.system_id withName:chat.name status:[NSNumber numberWithInt:ChatStatus_GROUP]];
                NSTimeInterval serverTime = [chat.updatedAt timeIntervalSince1970];
                
                if (lookup.read_timestamp.doubleValue < serverTime) {
                    chat.hasNew = YES;
                } else {
                    chat.hasNew = NO;
                }
            }
            
//            [tableData addObject:chat];
            
        }
        
    }];
}

//- (void)performSearch:(NSString *)searchText
//{
//    NSLog(@"%s: %@", __FUNCTION__, searchText);
//    self.tableData =[[NSMutableArray alloc]init];
//    
//    NSString *sql = @"select * from chat where name is not null and status <> 1";
//    
//    isLoading = YES;
//    
//    //    NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
//    
//    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
//    [tableData removeAllObjects];
//    ChatVO *chat;
//    while ([rs next]) {
//        chat = [ChatVO readFromDictionary:[rs resultDictionary]];
//        NSLog(@"chat.names = %@", chat.name);
//        [tableData addObject:chat];
//    }
//    isLoading = NO;
//    
//    [self.theTableView reloadData];
//    
//    //    [self performSelector:@selector(preloadData:)
//    //               withObject:nil
//    //               afterDelay:1.0];
////    [self listGroupChats:<#(id)#>];
//    
//}

- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);

    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    
    NSMutableSet *myChatKeys = [[NSMutableSet alloc] init];
    GroupVO *group;
    NSString *chatKey;
    NSString *sql = @"select * from groups order by name";
    
    isLoading = YES;
    
//    NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [tableData removeAllObjects];
    
    while ([rs next]) {
        
        group = [GroupVO readFromDictionary:[rs resultDictionary]];
        group.type = kGroupTypeLocal;
        chatKey = group.chat_key;
        if (chatKey != nil && chatKey.length > 0) {
            [myChatKeys addObject:chatKey];
        }
        [groupsArray addObject:group];
    }
    isLoading = NO;
    
//    NSLog(@"excludedKeys %@", myChatKeys);
    
    /*
     Find group chats not already in local database
     */
    [chatSvc apiFindGroupChats:[DataModel shared].user.contact_key
                    withStatus:[NSNumber numberWithInt:ChatType_GROUP]
                     excluding:[myChatKeys allObjects] callback:^(NSArray *results) {

                         for (PFObject *pfChat in results) {
                             GroupVO *g = [GroupVO readFromPFChat:pfChat];
                             g.type = kGroupTypeRemote;
                             g.chat_key = pfChat.objectId;
                             
                             if (![myChatKeys containsObject:g.chat_key]) {
//                                 NSLog(@"Adding chatKey %@", g.chat_key);
                                 [groupsArray addObject:g];
                             }
                         }
                         NSArray *sortedArray;
                         sortedArray = [groupsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                             NSString *first = [(GroupVO*)a name];
                             NSString *second = [(GroupVO*)b name];
                             return [first compare:second];
                         }];
                         
                         tableData = [sortedArray mutableCopy];
                         [self.theTableView reloadData];
                         
                         
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             [self listGroupChats:nil];
                         });

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
    NSLog(@"%s", __FUNCTION__);
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"GroupTableCell";
    static NSString *CellNib = @"GroupTableViewCell";
    
    GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (GroupTableViewCell *)[nib objectAtIndex:0];
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            cell.shouldIndentWhileEditing = NO;
            cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin  | UIViewAutoresizingFlexibleLeftMargin;
        }
        
        GroupVO *group = (GroupVO *) [tableData objectAtIndex:indexPath.row];
        cell.titleLabel.text = group.name;
        NSString *datetext;
        if (group.type == kGroupTypeLocal) {
            
            datetext = group.created;
            NSDate *createdAt = [DateTimeUtils dateFromDBDateString:datetext];
            datetext = [DateTimeUtils formatDecimalDate:createdAt];
            cell.dateLabel.text = datetext;
            
            
            UIImage *image = [UIImage imageNamed:@"cell_arrow_big.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, 44, 54);
            
//            button.layer.borderColor = [UIColor grayColor].CGColor;
//            button.layer.borderWidth = 1;
            
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
            button.frame = frame;
            [button setImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(checkButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            
            cell.accessoryView = button;
            
//            CGRect accFrame = cell.accessoryView.frame;
//            accFrame.origin.x +=20;
//            cell.accessoryView.frame = accFrame;
            

        } else if (group.type == kGroupTypeRemote) {
            datetext = [DateTimeUtils formatDecimalDate:group.updatedAt];
            cell.dateLabel.text = datetext;
        }
        
//        cell.dateLabel.text = group.chat_key;

        
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
            GroupVO *group = (GroupVO *) [tableData objectAtIndex:indexPath.row];

            [DataModel shared].group = group;

            if (group.chat_key != nil && group.chat_key.length > 0) {
                __weak typeof(self) weakSelf = self;
                [chatSvc apiLoadChat:group.chat_key callback:^(ChatVO *chat) {
                    [DataModel shared].chat = chat;
                    [DataModel shared].mode = @"Groups";
                    [weakSelf.delegate setBackPath:@"GroupsHome"];
                    [weakSelf.delegate gotoSlideWithName:@"Chat"];
                }];
            } else {
                
                NSLog(@"Creating new chat");
                NSMutableArray *contactKeys = [groupSvc listGroupContactKeys:group.group_id];
                [contactKeys addObject:[DataModel shared].user.contact_key];
                
                ChatVO *chat = [[ChatVO alloc] init];
                chat.name = group.name;
                chat.status = [NSNumber numberWithInt:ChatType_GROUP];
                chat.contact_keys = contactKeys;
                __weak typeof(self) weakSelf = self;

                [chatSvc apiSaveChat:chat callback:^(PFObject *pfChat) {
                    
                    if (!pfChat) {
                        NSLog(@"apiSaveChat failed");
                    } else {
                        // Adding push notifications subscription
                        NSLog(@"Saving group chat_key %@", pfChat.objectId);
//                        GroupVO *group = [DataModel shared].group;
                        group.chat_key = pfChat.objectId;
                        [groupSvc updateGroup:group];
                        
                        NSString *channelId = [@"chat_" stringByAppendingString:pfChat.objectId];
                        
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        [currentInstallation addUniqueObject:channelId forKey:@"channels"];
                        [currentInstallation saveInBackground];
                        
                        chat.system_id = pfChat.objectId;
                        
                        [chatSvc saveChat:chat];
                        
                        [DataModel shared].chat = chat;
                        [DataModel shared].mode = @"Groups";
                        
                        [weakSelf.delegate setBackPath:@"GroupsHome"];
                        [weakSelf.delegate gotoSlideWithName:@"Chat"];

//                        [DataModel shared].navIndex = 2;
//                        NSNotification* switchNavNotification = [NSNotification notificationWithName:@"switchNavNotification" object:@"Chat"];
//                        [[NSNotificationCenter defaultCenter] postNotification:switchNavNotification];
                        
                    }
                }];
                
            }
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)checkButtonTapped:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.theTableView];
    NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil)
    {
        NSLog(@"button index %@", indexPath);
        NSLog(@"Selected row %i", indexPath.row);
        
        selectedIndex = indexPath.row;
        GroupVO *group = (GroupVO *) [tableData objectAtIndex:indexPath.row];
        [DataModel shared].group = group;
        
        [DataModel shared].action = kActionEDIT;
        [_delegate gotoSlideWithName:@"GroupInfo" returnPath:@"GroupsHome"];
        
    }
}

- (void) tapCellAccessory:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
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
        
        
        GroupVO *group = (GroupVO *) [tableData objectAtIndex:indexPath.row];
        if (group.type == kGroupTypeLocal) {
            
            
        } else if (group.type == kGroupTypeRemote) {
            
        }
        
//        [groupSvc deleteGroup:group];
        [self setEditing:NO animated:YES];
        [self performSearch:@""];
        
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    [self.theTableView setEditing:editing];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Select the editing style of each cell
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do not allow inserts / deletes
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
    [_delegate gotoSlideWithName:@"EditGroup" returnPath:@"GroupsHome"];
    
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
