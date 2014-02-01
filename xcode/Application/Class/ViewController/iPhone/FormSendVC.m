//
//  FormSendVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "FormSendVC.h"
#import "GroupContactCell.h"
#import "UIColor+ColorWithHex.h"
#import "GroupVO.h"

#define kStatusAvailable @"Available"

@interface FormSendVC ()

@end

@implementation FormSendVC

@synthesize contactsData;
@synthesize groupsData;
@synthesize ccSearchBar;

//@synthesize addressBookData;

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
    contactSvc = [[ContactManager alloc] init];
    groupSvc = [[GroupManager alloc] init];
    chatSvc = [[ChatManager alloc] init];
    formSvc = [[FormManager alloc] init];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    CGRect tableFrame = self.theTableView.frame;
    tableFrame.size.height = [DataModel shared].stageHeight - tableFrame.origin.y - 50;
    self.theTableView.frame = tableFrame;

    self.navTitle.text = [DataModel shared].form.name;
    
    CGRect searchFrame = CGRectMake(10,57,300,32);
    
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        ccSearchBar.layer.borderColor = [UIColor colorWithHexValue:0xAAAAAA].CGColor;
        ccSearchBar.layer.borderWidth = 1.0;
        ccSearchBar.layer.cornerRadius = 3;
    }

    
    ccSearchBar.delegate = self;
    [self.view addSubview:ccSearchBar];
    [self.view.layer setCornerRadius:3.0];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.contactsData =[[NSMutableArray alloc]init];
    self.groupsData =[[NSMutableArray alloc]init];
    contactSet = [[NSMutableSet alloc] init];
    groupSet = [[NSMutableSet alloc] init];
    groupPicks = [[NSMutableDictionary alloc] init];
    contactPicks = [[NSMutableDictionary alloc] init];
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
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

#pragma mark - Data Load


- (void)performSearch:(NSString *)searchText
{
    
    NSString *sqlTemplate;
    sqlTemplate = @"select * from phonebook where (first_name like '%%%@%%' or last_name like '%%%@%%') and status=%i and contact_key<>'%@' order by last_name";
    
    isLoading = YES;
    int status;
    NSString *sql;
    
    status = 1;
    sql = [NSString stringWithFormat:sqlTemplate, searchText, searchText, status, [DataModel shared].user.contact_key];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [contactsData removeAllObjects];
    
    while ([rs next]) {
        NSDictionary *dict =[rs resultDictionary];
        [contactsData addObject:dict];
    }
    
    [self.groupsData removeAllObjects];
    
    sql = @"select * from groups where name like '%%%@%%' order by name";
    sql = [NSString stringWithFormat:sql, searchText];
    isLoading = YES;
    
    rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    
    while ([rs next]) {
        NSDictionary *dict =[rs resultDictionary];
        NSLog(@"Result %@", [dict objectForKey:@"name"]);
        [self.groupsData addObject:dict];
    }

    isLoading = NO;
    
    [self.theTableView reloadData];
    
}

#pragma mark - UITableViewDataSource


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
            
        case 0:
            title = @"Available Contacts";
            break;
            
        case 1:
            title = @"Groups";
            break;
            
        default:
            break;
    }
    CGRect headerFrame = CGRectMake(0, 0, [DataModel shared].stageWidth, 30);
    
    UIView* customView = [[UIView alloc] initWithFrame:headerFrame];
    if(section==0 || section==1)
    {
        customView.backgroundColor = [UIColor colorWithHexValue:0xd6dde1];
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        [headerLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:14]];
        headerLabel.frame = CGRectMake(10, 2, 300, 20);
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = title;
        
        [customView addSubview:headerLabel];
    }
    
    
    
    return customView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.contactsData.count == 0) {
            return 1;
        } else {
            return [self.contactsData count];
        }
    } else if (section == 1) {
        if (self.groupsData.count == 0) {
            return 1;
        } else {
            return [self.groupsData count];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"GroupContactCell";
    static NSString *CellNib = @"GroupContactCell";
    
    
    if (indexPath.section == 0) {
        
        GroupContactCell *cell = (GroupContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (GroupContactCell *)[nib objectAtIndex:0];
            }
            
            if (contactsData.count > 0) {
                NSDictionary *rowData = (NSDictionary *) [contactsData objectAtIndex:indexPath.row];
                cell.titleLabel.text = [self readFullnameFromDictionary:rowData];
                
            } else {
                cell.titleLabel.text = @"No contacts";
            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        return cell;
        
    } else if  (indexPath.section == 1) {
        // Groups
        
        GroupContactCell *cell = (GroupContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (GroupContactCell *)[nib objectAtIndex:0];
            }
            if (groupsData.count > 0) {
                NSDictionary *rowdata = [self.groupsData objectAtIndex:indexPath.row];
                NSString *name = [rowdata objectForKey:@"name"];
                cell.titleLabel.text = name;
                
            } else {
                cell.titleLabel.text = @"No groups";
            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        return cell;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        @try {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [contactsData objectAtIndex:indexPath.row];
            
            NSString *key = (NSString *) [rowdata objectForKey:@"contact_key"];
            
            GroupContactCell *tmpCell = ((GroupContactCell*)[self.theTableView cellForRowAtIndexPath:indexPath]);
            int status = tmpCell.cellStatus;
            
            if ([contactSet containsObject:key]) {
                status = 0;
                [tmpCell setStatus:status];
                [contactSet removeObject:key];
                [contactPicks removeObjectForKey:key];
            } else {
                status = 1;
                [tmpCell setStatus:status];
                [contactSet addObject:key];
                [contactPicks setObject:rowdata forKey:key];
            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
    } else if (indexPath.section == 1) {
        @try {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [groupsData objectAtIndex:indexPath.row];
            
            NSNumber *groupId = (NSNumber *) [rowdata objectForKey:@"group_id"];
            
            GroupContactCell *tmpCell = ((GroupContactCell*)[self.theTableView cellForRowAtIndexPath:indexPath]);
            int status = tmpCell.cellStatus;
            
            if ([groupSet containsObject:groupId]) {
                status = 0;
                [tmpCell setStatus:status];
                [groupSet removeObject:groupId];
                [groupPicks removeObjectForKey:groupId];
            } else {
                status = 1;
                [tmpCell setStatus:status];
                [groupSet addObject:groupId];
                [groupPicks setObject:rowdata forKey:groupId];
            }
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }

        
    }
    [self.theTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
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

#pragma mark - Action handlers


- (void) showModal {
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = 666;
    [self.view addSubview:bgLayer];
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height;
    float xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    NSLog(@"modal at %f, %f", xpos, ypos);
    self.addModal.layer.zPosition = 99;
    self.addModal.frame = modalFrame;
    [self.view addSubview:self.addModal];
    
    ypos = ([DataModel shared].stageHeight - modalFrame.size.height) / 2;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}

- (void) hideModal {
    
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height - 40;
    modalFrame.origin.y = ypos;
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                         
                         NSNotification* hideMaskNotification = [NSNotification notificationWithName:@"hideMaskNotification" object:nil];
                         [[NSNotificationCenter defaultCenter] postNotification:hideMaskNotification];
                         
                     }];
    
    
}


- (NSString *) readFullnameFromDictionary:(NSDictionary *)rowData {
    //    NSLog(@"lastname %@", [rowData objectForKey:@"last_name"]);
    if ([rowData objectForKey:@"first_name"] != nil && [rowData objectForKey:@"last_name"] == nil) {
        return [rowData objectForKey:@"first_name"];
    } else if ([rowData objectForKey:@"first_name"] == nil && [rowData objectForKey:@"last_name"] != nil) {
        return [rowData objectForKey:@"last_name"];
    } else {
        return [NSString stringWithFormat:kFullNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
    }
}

#pragma mark - Action handlers

- (IBAction)tapCancelButton
{
    [_delegate goBack];
    
}

- (IBAction)tapDoneButton {
    
    
    self.sendButton.enabled = NO;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Saving"];

    [self processSelectedGroups];
/*
    [contactKeys addObjectsFromArray:contactSet.allObjects];
    NSMutableArray *keys;
    
    for (NSNumber *groupId in groupSet) {
        keys = [groupSvc listGroupContactKeys:groupId.intValue];
        [contactKeys addObjectsFromArray:keys];
    }
    
    [contactKeys addObject:[DataModel shared].user.contact_key];
    
    [chatSvc apiFindChatsByContactKeys:contactKeys.allObjects callback:^(NSArray *results) {
        BOOL chatExists = NO;
        ChatVO *chat;
        if (results && results.count > 0) {
            for (PFObject *pfChat in results) {
                if (pfChat[@"contact_keys"]) {
                    NSArray *keys =pfChat[@"contact_keys"];
                    if (keys.count == contactKeys.count) {
                        // exact match.
                        chat = [ChatVO readFromPFObject:pfChat];
                        chatExists = YES;
                        break;
                    }
                }
            }
        }
        if (chatExists) {
            NSLog(@"Found existing chat");
            [self sendFormInChat:chat];
            
            
        } else {
            NSLog(@"Creating new chat");
            chat = [[ChatVO alloc] init];
            chat.name = @"";
            chat.contact_keys = contactKeys.allObjects;
            
            [chatSvc apiSaveChat:chat callback:^(PFObject *pfChat) {
                
                // Adding push notifications subscription
                
                NSString *channelId = [@"chat_" stringByAppendingString:pfChat.objectId];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:channelId forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                chat.system_id = pfChat.objectId;
                
                [chatSvc saveChat:chat];
                
                [self sendFormInChat:chat];
                
            }];
        }
    }];
*/
    
    
    
    //    [_delegate goBack];
}

- (void) processSelectedContacts {
    
    int total = contactSet.count;
    __block int index = 0;
    
    if (total == 0) {
        // FINISH
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [_delegate gotoSlideWithName:@"FormsHome" andOverrideTransition:kPresentationTransitionFade];

        return;
    }
    NSDictionary *dict;
    ContactVO *contact;

    for (NSString *key in contactSet) {
        
        NSLog(@"Sending form to individual %@", key);
        
        dict = [contactPicks objectForKey:key];
        contact = [ContactVO readFromPhonebook:dict];
        
        ChatMessageVO *msg = [[ChatMessageVO alloc] init];
        msg.form_key = [DataModel shared].form.system_id;
        msg.contact_key = [DataModel shared].user.contact_key;
        [chatSvc apiSendMessageToContact:msg contact:contact callback:^(ChatVO *chat) {
            
            index++;
            if (index == total) {
                // finished here
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [_delegate gotoSlideWithName:@"FormsHome" andOverrideTransition:kPresentationTransitionFade];
                
            }
        }];
    }
}

- (void) processSelectedGroups {
    if (groupSet.count == 0) {
        [self processSelectedContacts];
        return;
    }
    int total = groupSet.count;
    __block int index = 0;
    NSDictionary *data;
    GroupVO *group;
    
    for (NSNumber *groupId in groupSet) {
        data = [groupPicks objectForKey:groupId];
        
        if (data) {
            group = [GroupVO readFromDictionary:data];
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            msg.form_key = [DataModel shared].form.system_id;
            msg.contact_key = [DataModel shared].user.contact_key;
            
            [chatSvc apiSendMessageToGroup:msg group:group callback:^(ChatVO *chat) {
                index++;
                if (index == total) {
                    [self processSelectedContacts];
                }
            }];
        } else {
            NSLog(@"Group not found %@", groupId);
            index++;
            if (index == total) {
                [self processSelectedContacts];
            }
        }
    }
}

- (void) sendFormInChat:(ChatVO *)chat {
    // ################# PARSE SAVE ##################
    ChatMessageVO *msg = [[ChatMessageVO alloc] init];
    
    msg.contact_key = [DataModel shared].user.contact_key;
    msg.chat_key = chat.system_id;
    msg.form_key = [DataModel shared].form.system_id;
    
    // FIXME: Need to remove blocked users
    __weak typeof(self) weakSelf = self;

    [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
        if (pfMessage) {
            
            [formSvc apiLookupFormContacts:msg.form_key contactKeys:[DataModel shared].chat.contact_keys callback:^(NSArray *savedKeys) {
                
                NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                
                for (NSString *key in [DataModel shared].chat.contact_keys) {
                    
                    if (![savedKeys containsObject:key]) {
                        [unsavedKeySet addObject:key];
                    }
                }
                
                [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                    NSLog(@"Saved form contacts count %i", savedKeys.count);
                    
                }];
            }];
            
            
            [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
                // Build a target query: everyone in the chat room except for this device.
                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                PFQuery *query = [PFInstallation query];
                
                NSString *channelId = [@"chat_" stringByAppendingString:chat.system_id];
                [query whereKey:@"channels" equalTo:channelId];
                
                NSLog(@"form type = %i", [DataModel shared].form.type);
                NSString *msgtext = @"%@ posted a new %@: %@";
                NSString *formTitle = [DataModel shared].form.name;
                switch ([DataModel shared].form.type) {
                    case FormType_POLL:
                    {
                        msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"poll", formTitle];
                        break;
                    }
                    case FormType_RATING:
                    {
                        msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"rating", formTitle];
                        
                        break;
                    }
                    case FormType_RSVP:
                    {
                        msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"RSVP", formTitle];
                        break;
                    }
                }
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      msgtext, @"alert",
                                      msg.contact_key, @"contact",
                                      chat.system_id, @"chat",
                                      pfMessage.objectId, @"msg",
                                      nil];
                // Create time interval
                NSTimeInterval interval = 60*60*24*7; // 1 week
                
                // Send push notification with expiration interval
                PFPush *push = [[PFPush alloc] init];
                [push expireAfterTimeInterval:interval];
                [push setQuery:query];
                [push setData:data];
                [push sendPushInBackground];
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Your form was successfully sent to all recipients."
                                                               delegate:weakSelf
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }];
        } else {
            NSLog(@"Chat message was not saved");
        }
    }];
    
}
#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate gotoSlideWithName:@"FormsHome"];
}



@end
