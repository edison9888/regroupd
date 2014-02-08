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

//- (void)listGroupChats:(id)sender
//{
//    NSLog(@"%s", __FUNCTION__);
//    //    self.tableData =[[NSMutableArray alloc]init];
//
//    if (chatSvc == nil) {
//        chatSvc = [[ChatManager alloc] init];
//    }
//
//    [chatSvc apiListChats:[DataModel shared].user.contact_key status:[NSNumber numberWithInt:ChatType_GROUP]  callback:^(NSArray *results) {
//        NSLog(@"apiListChats response count %i", results.count);
//        if (results.count == 0) {
//            [MBProgressHUD hideHUDForView:self.view animated:NO];
//            [self.theTableView reloadData];
//            return;
//        }
//
//        NSMutableArray *chatsArray = [[NSMutableArray alloc] initWithCapacity:results.count];
//        ChatVO *chat;
//        //        ChatVO *dbChat;
//
//        for (PFObject* result in results) {
//            chat = [ChatVO readFromPFObject:result];
//            BOOL isBlocked = NO;
//
//            NSArray *keys = chat.contact_keys;
//            if ([chat.removed_keys containsObject:[DataModel shared].user.contact_key]) {
//                isBlocked = YES;
//            }
//
//            if (keys.count < 2) {
//                isBlocked = YES;
//                [chatsArray addObject:chat];
//            }
//            if (isBlocked) {
//                continue;
//            } else {
//                [chatsArray addObject:chat];
//            }
//
//        }
//
//        for (ChatVO *chat in chatsArray) {
//
//            ChatVO *lookup = [chatSvc loadChatByKey:chat.system_id];
//            if (lookup == nil) {
//                // need to add
//                if (chat.status == nil) {
//                    chat.status = [NSNumber numberWithInt:ChatType_GROUP];
//                }
//                [chatSvc saveChat:chat];
//                chat.hasNew = YES;
//
//            } else {
//                // ignore
//                //                [chatSvc updateChat:chat.system_id withName:chat.name status:[NSNumber numberWithInt:ChatStatus_GROUP]];
//                NSTimeInterval serverTime = [chat.updatedAt timeIntervalSince1970];
//
//                if (lookup.read_timestamp.doubleValue < serverTime) {
//                    chat.hasNew = YES;
//                } else {
//                    chat.hasNew = NO;
//                }
//            }
//
//            //            [tableData addObject:chat];
//
//        }
//
//    }];
//}

- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    self.tableData =[[NSMutableArray alloc]init];
    
    NSString *sql = @"select * from chat where name is not null and status==1 order by created desc";
    
    isLoading = YES;
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [tableData removeAllObjects];
    ChatVO *chat;
    while ([rs next]) {
        chat = [ChatVO readFromDictionary:[rs resultDictionary]];
        NSLog(@"chat.names = %@", chat.name);
        [tableData addObject:chat];
    }
    isLoading = NO;
    
    [self.theTableView reloadData];
    
    [self listMyChats:nil];
}

- (void)listMyChats:(id)sender
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
            
            
            if (isBlocked) {
                continue;
            } else {
                NSLog(@"contact keys = %@", keys);
                
                [chatsArray addObject:chat];
                
            }
            
        }
        
        [self compareLocalAndRemoteChats:chatsArray];
    }];
}

- (void) compareLocalAndRemoteChats:(NSMutableArray *)chatsArray {
    NSMutableArray *newChats = [NSMutableArray array];
    
    for (ChatVO *chat in chatsArray) {
        ChatVO *lookup = [chatSvc loadChatByKey:chat.system_id];
        [DataModel shared].chatsList = tableData;
        if (lookup == nil) {
            // need to add
            if (chat.status == nil) {
                chat.status = [NSNumber numberWithInt:ChatType_GROUP];
            }
            [chatSvc saveChat:chat];
            chat.hasNew = YES;
            [newChats addObject:chat];
            
        } else {
            // ignore
            //            NSTimeInterval serverTime = [chat.updatedAt timeIntervalSince1970];
            //
            //
            //            if (lookup.read_timestamp.doubleValue < serverTime) {
            //
            //                chat.hasNew = YES;
            //                [tableData addObject:chat];
            //
            //            } else {
            //                chat.hasNew = NO;
            //                [tableData addObject:chat];
            //            }
        }
    }
    
    [newChats addObjectsFromArray:tableData];
    tableData = newChats;
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self.theTableView reloadData];
    isLoading = NO;
    
    
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
        
        ChatVO *chat = (ChatVO *) [tableData objectAtIndex:indexPath.row];
        cell.titleLabel.text = chat.name;
        
        
        NSString *datetext;
        
        if (chat.createdAt != nil) {
            datetext = [DateTimeUtils formatDecimalDate:chat.createdAt];
        } else {
            NSDate *dt = [DateTimeUtils dateFromDBDateStringNoOffset:chat.created];
            datetext = [DateTimeUtils formatDecimalDate:dt];
        }
        cell.dateLabel.text = datetext;
        
        //        UserVO *user = [DataModel shared].user;
        
        //        NSLog(@"%@ -- Compare chat.user_key %@ with user %@", chat.name, chat.user_key, [DataModel shared].user.user_key);
        if ([chat.user_key isEqualToString:[DataModel shared].user.user_key]) {
            
            
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
            ChatVO *chat = (ChatVO *) [tableData objectAtIndex:indexPath.row];
            
            // Load from parse, because we need contact_keys
            [chatSvc apiLoadChat:chat.system_id callback:^(ChatVO *theChat) {
                [DataModel shared].chat = theChat;
                [DataModel shared].mode = @"Groups";
                
                [_delegate setBackPath:@"GroupsHome"];
                [_delegate gotoSlideWithName:@"Chat"];
            }];

            
            //            if (group.chat_key != nil && group.chat_key.length > 0) {
            //                __weak typeof(self) weakSelf = self;
            //                [chatSvc apiLoadChat:group.chat_key callback:^(ChatVO *chat) {
            //                    [DataModel shared].chat = chat;
            //                    [DataModel shared].mode = @"Groups";
            //                    [weakSelf.delegate setBackPath:@"GroupsHome"];
            //                    [weakSelf.delegate gotoSlideWithName:@"Chat"];
            //                }];
            //            } else {
            //
            //                NSLog(@"Creating new chat");
            //                NSMutableArray *contactKeys = [groupSvc listGroupContactKeys:group.group_id];
            //                [contactKeys addObject:[DataModel shared].user.contact_key];
            //
            //                ChatVO *chat = [[ChatVO alloc] init];
            //                chat.name = group.name;
            //                chat.status = [NSNumber numberWithInt:ChatType_GROUP];
            //                chat.contact_keys = contactKeys;
            //                __weak typeof(self) weakSelf = self;
            //
            //                [chatSvc apiSaveChat:chat callback:^(PFObject *pfChat) {
            //
            //                    if (!pfChat) {
            //                        NSLog(@"apiSaveChat failed");
            //                    } else {
            //                        // Adding push notifications subscription
            //                        NSLog(@"Saving group chat_key %@", pfChat.objectId);
            ////                        ChatVO *group = [DataModel shared].group;
            //                        group.chat_key = pfChat.objectId;
            //                        [groupSvc updateGroup:group];
            //
            //                        NSString *channelId = [@"chat_" stringByAppendingString:pfChat.objectId];
            //
            //                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            //                        [currentInstallation addUniqueObject:channelId forKey:@"channels"];
            //                        [currentInstallation saveInBackground];
            //
            //                        chat.system_id = pfChat.objectId;
            //
            //                        [chatSvc saveChat:chat];
            //
            //                        [DataModel shared].chat = chat;
            //                        [DataModel shared].mode = @"Groups";
            //
            //                        [weakSelf.delegate setBackPath:@"GroupsHome"];
            //                        [weakSelf.delegate gotoSlideWithName:@"Chat"];
            //
            ////                        [DataModel shared].navIndex = 2;
            ////                        NSNotification* switchNavNotification = [NSNotification notificationWithName:@"switchNavNotification" object:@"Chat"];
            ////                        [[NSNotificationCenter defaultCenter] postNotification:switchNavNotification];
            //
            //                    }
            //                }];
            //
            //            }
            
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
        ChatVO *_chat = [tableData objectAtIndex:indexPath.row];
        GroupVO *group = [groupSvc findGroupByChatKey:_chat.system_id];
        group.status = -1;
        [groupSvc updateGroup:group];
        
        [chatSvc apiLoadChat:_chat.system_id callback:^(ChatVO *theChat) {
            if (theChat.removed_keys == nil) {
                
                theChat.removed_keys = [NSArray arrayWithObject:[DataModel shared].user.contact_key];
                [chatSvc apiSaveChat:theChat callback:^(PFObject *object) {
                    [tableData removeObjectAtIndex:indexPath.row];
                    [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    
                }];
            } else {
                if ([theChat.removed_keys containsObject:[DataModel shared].user.contact_key]) {
                    [tableData removeObjectAtIndex:indexPath.row];
                    [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    
                } else {
                    NSMutableArray *removedKeys = [theChat.removed_keys mutableCopy];
                    [removedKeys addObject:[DataModel shared].user.contact_key];
                    theChat.removed_keys = [removedKeys copy];
                    [chatSvc apiSaveChat:theChat callback:^(PFObject *object) {
                        [tableData removeObjectAtIndex:indexPath.row];
                        [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                        
                    }];
                }
            }
        }];
        
        //
        //        ChatVO *group = (ChatVO *) [tableData objectAtIndex:indexPath.row];
        //        if (group.type == kGroupTypeLocal) {
        //
        //
        //        } else if (group.type == kGroupTypeRemote) {
        //
        //        }
        
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
        ChatVO *chat = (ChatVO *) [tableData objectAtIndex:indexPath.row];
        
        if ([chat.user_key isEqualToString:[DataModel shared].user.user_key]) {
            
            GroupVO *group = [groupSvc findGroupByChatKey:chat.system_id];
            
            if (group) {
                [DataModel shared].group = group;
                group.status = 1;
                group.chat_key = chat.system_id;
                [groupSvc updateGroup:group];
                
                [DataModel shared].action = kActionEDIT;
                [_delegate gotoSlideWithName:@"GroupInfo" returnPath:@"GroupsHome"];
                
            } else {
                
                group = [[GroupVO alloc] init];
                group.name = chat.name;
                group.chat_key = chat.system_id;
                group.status = 1;
                group.type = 1;
                group.createdAt = chat.createdAt;
                group.updatedAt = chat.updatedAt;
                
                int groupId = [groupSvc saveGroup:group];
                
                NSLog(@"New groupId %i", groupId);
                [chatSvc apiLoadChat:chat.system_id callback:^(ChatVO *theChat) {
                    
//                    for (NSString* contactKey in theChat.contact_keys) {
//                        BOOL exists = [groupSvc checkGroupContact:groupId contacKey:contactKey];
//                        if (!exists) {
//                            NSLog(@"Adding new member %@", contactKey);
//                            [groupSvc saveGroupContact:groupId contactKey:contactKey];
//                        }
//                    }
                    
                    [DataModel shared].group = group;
                    
                    [DataModel shared].action = kActionEDIT;
                    [_delegate gotoSlideWithName:@"GroupInfo" returnPath:@"GroupsHome"];
                }];
                
            }
            
            
        }
        
    }
}

//- (void) tapCellAccessory:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
//
//}
//


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
