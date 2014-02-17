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
    if ([DataModel shared].groupsList != nil && [DataModel shared].groupsList.count > 0) {
        self.tableData = [DataModel shared].groupsList;
        [self.theTableView reloadData];
    }
    
//    NSString *sql = @"select * from chat where name is not null and status==1 order by created desc";
//    
//    isLoading = YES;
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
    
//    [self listMyChats:nil];
    __weak typeof(self) weakSelf = self;

    [chatSvc apiRefreshLocalChatsAndGroups:[DataModel shared].user.contact_key callback:^(NSMutableArray *chats) {
        [self.tableData removeAllObjects];
        
        //    [newChats addObjectsFromArray:tableData];
        weakSelf.tableData = chats;
        [DataModel shared].groupsList = tableData;
        
//        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [weakSelf.theTableView reloadData];
        isLoading = NO;
        
    }];
}

- (void)listMyChats:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    isLoading = YES;
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
        

        if (lookup == nil) {
            // need to add
            if (chat.status == nil) {
                chat.status = [NSNumber numberWithInt:ChatType_GROUP];
            }
            [chatSvc saveChat:chat];
            chat.hasNew = YES;
            [newChats addObject:chat];
            
        } else {
            [newChats addObject:chat];
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
    [self.tableData removeAllObjects];

//    [newChats addObjectsFromArray:tableData];
    self.tableData = newChats;
    [DataModel shared].groupsList = tableData;

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
            cell.accessoryView.hidden = NO;
            
        } else {
            cell.accessoryView.hidden = YES;
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
        self.theTableView.userInteractionEnabled = NO;
        //add code here for when you hit delete
        ChatVO *_chat = [tableData objectAtIndex:indexPath.row];
        GroupVO *group = [groupSvc findGroupByChatKey:_chat.system_id];
        group.status = -1;
        [groupSvc updateGroup:group];
        
        NSLog(@"Removing contact %@ from chat %@", [DataModel shared].user.contact_key, _chat.system_id);
        
        [chatSvc apiLoadChat:_chat.system_id callback:^(ChatVO *theChat) {
            if (theChat.removed_keys == nil) {
                
                theChat.removed_keys = [NSArray arrayWithObject:[DataModel shared].user.contact_key];
                [chatSvc apiSaveChat:theChat callback:^(PFObject *object) {
                    [tableData removeObjectAtIndex:indexPath.row];
                    [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    self.theTableView.userInteractionEnabled = YES;
                    
                }];
            } else {
                if ([theChat.removed_keys containsObject:[DataModel shared].user.contact_key]) {
                    [tableData removeObjectAtIndex:indexPath.row];
                    [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    self.theTableView.userInteractionEnabled = YES;
                    
                } else {
                    NSMutableArray *removedKeys = [theChat.removed_keys mutableCopy];
                    [removedKeys addObject:[DataModel shared].user.contact_key];
                    theChat.removed_keys = [removedKeys copy];
                    [chatSvc apiSaveChat:theChat callback:^(PFObject *object) {
                        [tableData removeObjectAtIndex:indexPath.row];
                        [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                        
                        self.theTableView.userInteractionEnabled = YES;
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
//        [self setEditing:NO animated:YES];
//        [self performSearch:@""];
        
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    [self.theTableView setEditing:editing];
    
    if (editing) {
        [self.editButton setTitle:kEditLabel forState:UIControlStateNormal];
        [self.theTableView reloadData];

    } else {
        [self.editButton setTitle:kDoneLabel forState:UIControlStateNormal];
        [self.theTableView reloadData];
        

    }
    
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
        
        [self setEditing:inEditMode animated:YES];
        
        
    } else {
        inEditMode = YES;
        [self setEditing:inEditMode animated:YES];
        
        
    }
    
}
@end
