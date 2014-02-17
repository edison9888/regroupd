//
//  ContactGroupsVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ContactGroupsVC.h"

#define kMemberFlag @"Member"
#define kAddedFlag @"Added"
#define kRemovedFlag @"Removed"

@interface ContactGroupsVC ()

@end

@implementation ContactGroupsVC

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
    
    theContactKey = [DataModel shared].contact.system_id;
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
        
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    groupSvc = [[GroupManager alloc] init];
    chatSvc = [[ChatManager alloc] init];
    
    NSString *title = @"%@'s Groups";
    title = [NSString stringWithFormat:title, [DataModel shared].contact.first_name];
    self.navTitle.text = title;

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


#pragma mark - Load data

//- (void) refreshGroupContacts {
////    __weak typeof(self) weakSelf = self;
//    
//    [chatSvc apiFindGroupChats:[DataModel shared].user.contact_key withStatus:[NSNumber numberWithInt:ChatType_GROUP] excluding:nil callback:^(NSArray *results) {
//        for (PFObject *data in results) {
//            ChatVO *chat = [ChatVO readFromPFObject:data];
//            
//            GroupVO *group = [groupSvc findGroupByChatKey:chat.system_id];
//            
//            if (group == nil) {
//                
//            }
//            
//        }
//    }];
//    
//}


- (void)performSearch:(NSString *)searchText
{
    
    
    NSLog(@"%s: %@", __FUNCTION__, searchText);
//    NSMutableArray *groups = [groupSvc listContactGroups:theContactKey];
    
    chatKeys = [groupSvc listContactGroupChatKeys:theContactKey];
    
    NSLog(@"Found chatKeys %@", chatKeys);
    selectionsMap = [[NSMutableDictionary alloc] initWithCapacity:chatKeys.count];
    
    for (NSString *key in chatKeys) {
        [selectionsMap setObject:kMemberFlag forKey:key];
    }

    NSMutableArray *results = [[NSMutableArray alloc] init];
    
//    NSString *sql = @"select * from groups order by updated desc";
    NSString *sql;
    sql = @"select * from chat where status=1 and user_key='%@' order by name";
    sql = [NSString stringWithFormat:sql, [DataModel shared].user.user_key];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    
    while ([rs next]) {
//        row = [GroupVO readFromDictionary:[rs resultDictionary]];
        [results addObject:[rs resultDictionary]];
    }
    
    self.tableData = results;
    [self.theTableView reloadData];
    
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
    static NSString *CellNib = @"GroupContactCell";
    
    GroupContactCell *cell = (GroupContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (GroupContactCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        NSDictionary *rowdata = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.titleLabel.text = [rowdata objectForKey:@"name"];
        NSString *chatKey = [rowdata objectForKey:@"system_id"];
        
//        NSNumber *groupId = [rowdata objectForKey:@"group_id"];
        NSString *flag;
        
        if ([selectionsMap objectForKey:chatKey] != nil) {
            flag = (NSString *) [selectionsMap objectForKey:chatKey];
            if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
                [cell setStatus:1];
            } else {
                [cell setStatus:0];
            }
        }
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);

            GroupContactCell *tmpCell = ((GroupContactCell*)[self.theTableView cellForRowAtIndexPath:indexPath]);
            int status = tmpCell.cellStatus;
            
            if (tmpCell.cellStatus == 0) {
                status = 1;
                [tmpCell setStatus:status];
            } else {
                status = 0;
                [tmpCell setStatus:status];
            }

            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
//            NSNumber *groupId = [rowdata objectForKey:@"group_id"];
            NSString *chatKey = [rowdata objectForKey:@"system_id"];

            NSString *flag;
            flag = (NSString *) [selectionsMap objectForKey:chatKey];
            if (flag == nil) {
                if (status == 1) {
                    [selectionsMap setObject:kAddedFlag forKey:chatKey];
                } else {
                    
                    // This should not happen
                    NSLog(@"Invalid state. Trying to remove group not in original set chatKey = %@", chatKey);
                    [selectionsMap setObject:kRemovedFlag forKey:chatKey];
                }
            } else {
                if (status == 0) {
                    // Remove from group
                    if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
                        [selectionsMap setObject:kRemovedFlag forKey:chatKey];
                    } else {
                        // Do nothing. This shouldn't happen
                    }
                } else {
                    // Add contact to group
                    if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
                        // Do nothing
                        //                    [selectionsMap setObject:kRemovedFlag forKey:contactKey];
                        
                    } else {
                        // Do nothing. This shouldn't happen
                        [selectionsMap setObject:kAddedFlag forKey:chatKey];
                        
                    }
                }
                
            }
            [self.theTableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                                     withRowAnimation: UITableViewRowAnimationNone];

//            [DataModel shared].group = [GroupVO readFromDictionary:rowdata];
//            
//            [DataModel shared].action = kActionEDIT;
//            [_delegate gotoSlideWithName:@"GroupInfo" returnPath:@"ContactGroups"];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


#pragma mark - Action handlers

- (IBAction)tapCancelButton
{
    [_delegate goBack];
    
}

- (IBAction)tapDoneButton {
    NSString *flag;
    
    NSMutableArray *updateChatKeys = [NSMutableArray array];

    for (NSString *chatKey in selectionsMap) {
        flag = (NSString *) [selectionsMap objectForKey:chatKey];
        GroupVO *group = [groupSvc findGroupByChatKey:chatKey];
        
        if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
            if (group) {
                BOOL exists = [groupSvc checkGroupContact:group.group_id contacKey:theContactKey];
                if (!exists) {
                    NSLog(@"Adding new member from group %@", group.name);
                    [groupSvc saveGroupContact:group.group_id contactKey:theContactKey];
                }
            }
        } else if ([flag isEqualToString:kRemovedFlag]) {
            BOOL exists = [groupSvc checkGroupContact:group.group_id contacKey:theContactKey];
            if (exists) {
                NSLog(@"Removing member from group %@", group.name);
                [groupSvc removeGroupContact:group.group_id contactKey:theContactKey];
            }
        }
        
        if ([flag isEqualToString:kAddedFlag] || [flag isEqualToString:kRemovedFlag]) {
            [updateChatKeys addObject:chatKey];
        }
    }
    int total = updateChatKeys.count;

    __block int index = 0;
    __block NSMutableArray *contactKeys;
    
    
    for (NSString *chatKey in updateChatKeys) {
        flag = (NSString *) [selectionsMap objectForKey:chatKey];

        [chatSvc apiLoadChat:chatKey callback:^(ChatVO *_chat) {
            
            contactKeys = [_chat.contact_keys mutableCopy];
            

            if ([flag isEqualToString:kAddedFlag]) {
                
                NSLog(@"Adding contact to chat %@", chatKey);
                [contactKeys addObject:theContactKey];
            } else if ([flag isEqualToString:kRemovedFlag]) {
                NSLog(@"Removing contact from chat %@", chatKey);
                [contactKeys removeObject:theContactKey];
            }

            _chat.contact_keys = contactKeys;
            
            [chatSvc apiSaveChat:_chat callback:^(PFObject *object) {
                index++;
                if (index == total) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Changes saved"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }];
    }

    
    //    [_delegate goBack];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate goBack];
}


@end
