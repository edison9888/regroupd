//
//  ManageGroupVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ManageGroupVC.h"
#import "GroupContactCell.h"
#import "UIColor+ColorWithHex.h"

#define kMemberFlag @"Member"
#define kAddedFlag @"Added"
#define kRemovedFlag @"Removed"

@interface ManageGroupVC ()

@end

@implementation ManageGroupVC

@synthesize tableData;
@synthesize theChat, theGroup;

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
    groupSvc = [[GroupManager alloc] init];
    chatSvc = [[ChatManager alloc] init];
    
    self.theGroup = [DataModel shared].group;
    
//
//    - See more at: http://refactr.com/blog/2012/09/ios-tips-custom-fonts/#sthash.Qi1jzSHT.dpuf
    // Do any additional setup after loading the view from its nib.
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
        
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
//    [self performSearch:@""];
    isSearching = NO;
    [self refreshGroupContacts];
    
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

- (void) refreshGroupContacts {
    NSString *chatId = [DataModel shared].group.chat_key;
    int groupId = [DataModel shared].group.group_id;
    __weak typeof(self) weakSelf = self;
    [chatSvc apiLoadChat:chatId callback:^(ChatVO *_chat) {
        
        for (NSString* contactKey in _chat.contact_keys) {
            BOOL exists = [groupSvc checkGroupContact:groupId contacKey:contactKey];
            if (!exists) {
                NSLog(@"Adding new member %@", contactKey);
                [groupSvc saveGroupContact:groupId contactKey:contactKey];
                
            }
        }
        [weakSelf loadGroupContacts];
    }];
    
}
- (void)loadGroupContacts {
    isLoading = YES;
    
    isSearching = NO;
    
    static NSString *alphaSql = @"select distinct CASE last_name  WHEN '' THEN substr(first_name, 1, 1) \
    ELSE substr(last_name, 1, 1) END as alpha from phonebook where status=1 order by alpha";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:alphaSql];
    NSString *alpha;
    alphasArray = [[NSMutableArray alloc] init];
    while ([rs next]) {
        alpha = [rs stringForColumnIndex:0];
        [alphasArray addObject:alpha];
    }
    alphaMap = [[NSMutableDictionary alloc] initWithCapacity:alphasArray.count];
    NSMutableArray *results;
    for (NSString *letter in alphasArray) {
        results = [[NSMutableArray alloc] init];
        [alphaMap setObject:results forKey:letter];
    }
    
    //    NSString *sql = @"select CASE last_name  WHEN '' THEN substr(first_name, 1, 1) ELSE substr(last_name, 1, 1) END as alpha, \
    CASE last_name  WHEN '' THEN first_name ELSE last_name END as sortval, * from phonebook where status=1 and contact_key<>? \
    order by sortval, first_name";
    
    NSString *sql = @"select distinct \
    CASE last_name  WHEN '' THEN substr(first_name, 1, 1) ELSE substr(last_name, 1, 1) END as alpha, \
    CASE last_name  WHEN '' THEN first_name ELSE last_name END as sortval, \
    pb.first_name, pb.last_name, pb.contact_key, pb.phone from phonebook pb \
    where status=1 and contact_key<>? order by sortval, first_name";
    
    [rs close];
    
    rs = [[SQLiteDB sharedConnection] executeQuery:sql, [DataModel shared].user.contact_key];
    
    while ([rs next]) {
        NSDictionary *dict =[rs resultDictionary];
        alpha = [rs stringForColumnIndex:0];
        [((NSMutableArray *)[alphaMap objectForKey:alpha]) addObject:dict];
    }
    
    
    memberKeys = [groupSvc listGroupContactKeys:[DataModel shared].group.group_id];
    selectionsMap = [[NSMutableDictionary alloc] initWithCapacity:memberKeys.count];
    
    for (NSString *key in memberKeys) {
        [selectionsMap setObject:kMemberFlag forKey:key];
    }
    
    isLoading = NO;
    [self.theTableView reloadData];

    
}
- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from phonebook where status=1 and contact_key<>'%@' and (first_name like '%%%@%%' or last_name like '%%%@%%') limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, [DataModel shared].user.contact_key, searchText, searchText];
        NSLog(@"sql=%@", sql);
        
        
        [tableData removeAllObjects];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate = @"select * from phonebook where status=1 and contact_key<>'%@' order by last_name";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, [DataModel shared].user.contact_key, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
}

#pragma mark - UITableViewDataSource

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *letter = [alphasArray objectAtIndex:section];

    return [self headerViewWithTitle:letter];
}


- (UIView *)headerViewWithTitle:(NSString *)title {
    UIView * sectionHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    sectionHeaderView.backgroundColor = [UIColor colorWithHexValue:0x0d7dac];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"Raleway-Bold" size:17];
    headerLabel.frame = CGRectMake(14, 5, 308, 20);
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [sectionHeaderView addSubview:headerLabel];
    
    headerLabel.text = title;
    
    return sectionHeaderView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if (isSearching) {
        return 1;
    } else {
        return alphasArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
//    int index = [alphasArray indexOfObject:<#(id)#>]
    
    if (isSearching) {
        return [tableData count];
        
    } else {
        NSString *letter = [alphasArray objectAtIndex:section];
        return ((NSMutableArray *)[alphaMap objectForKey:letter]).count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    
    static NSString *CellIdentifier = @"GroupContactCell";
    static NSString *CellNib = @"GroupContactCell";
    
    GroupContactCell *cell = (GroupContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {

        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (GroupContactCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        NSString *contactKey;
//        if (isSearching) {
//            NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
//            cell.titleLabel.text = [self readFullnameFromDictionary:rowData];
//            
//            contactKey = [rowData objectForKey:@"contact_key"];
//        } else {
        
            NSString *letter = [alphasArray objectAtIndex:indexPath.section];
            NSMutableArray *results = (NSMutableArray *)[alphaMap objectForKey:letter];
            NSDictionary *rowData = (NSDictionary *) [results objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = [self readFullnameFromDictionary:rowData];
            contactKey = [rowData objectForKey:@"contact_key"];
//        }
        NSString *flag;
        if ([selectionsMap objectForKey:contactKey] != nil) {
            flag = (NSString *) [selectionsMap objectForKey:contactKey];
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
        NSString *contactKey;
        if (isSearching) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowData = [tableData objectAtIndex:indexPath.row];
            contactKey = [rowData objectForKey:@"contact_key"];
        } else {
            NSString *letter = [alphasArray objectAtIndex:indexPath.section];
            NSMutableArray *results = (NSMutableArray *)[alphaMap objectForKey:letter];
            NSDictionary *rowData = (NSDictionary *) [results objectAtIndex:indexPath.row];
            contactKey = [rowData objectForKey:@"contact_key"];
        }
        
        GroupContactCell *tmpCell = ((GroupContactCell*)[self.theTableView cellForRowAtIndexPath:indexPath]);
        int status = tmpCell.cellStatus;
        
        if (tmpCell.cellStatus == 0) {
            status = 1;
            [tmpCell setStatus:status];
        } else {
            status = 0;
            [tmpCell setStatus:status];
        }
        
        NSString *flag;
        flag = (NSString *) [selectionsMap objectForKey:contactKey];
        if (flag == nil) {
            if (status == 1) {
                [selectionsMap setObject:kAddedFlag forKey:contactKey];
            } else {
                
                // This should not happen
                NSLog(@"Invalid state. Trying to remove contactKey not in original set contactKey = %@", contactKey);
                [selectionsMap setObject:kRemovedFlag forKey:contactKey];
            }
        } else {
            if (status == 0) {
                // Remove from group
                if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
                    [selectionsMap setObject:kRemovedFlag forKey:contactKey];
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
                    [selectionsMap setObject:kAddedFlag forKey:contactKey];

                }
            }
            
        }
        [self.theTableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                         withRowAnimation: UITableViewRowAnimationNone];
        
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSString *) readFullnameFromDictionary:(NSDictionary *)rowData {
    //    NSLog(@"lastname %@", [rowData objectForKey:@"last_name"]);
    if ([rowData objectForKey:@"first_name"] != NULL && [rowData objectForKey:@"last_name"] == NULL) {
        return [rowData objectForKey:@"first_name"];
    } else if ([rowData objectForKey:@"first_name"] == NULL && [rowData objectForKey:@"last_name"] != NULL) {
        return [rowData objectForKey:@"last_name"];
    } else {
        return [NSString stringWithFormat:kFullNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
    }
}


#pragma mark - Action handlers

- (IBAction)tapCancelButton {
    [_delegate goBack];
}

- (IBAction)tapDoneButton {
    NSString *flag;
    
    for (NSString *key in selectionsMap) {
        flag = (NSString *) [selectionsMap objectForKey:key];
        
        if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
            BOOL exists = [groupSvc checkGroupContact:[DataModel shared].group.group_id contacKey:key];
            if (!exists) {
                NSLog(@"Adding new member %@", key);
                [groupSvc saveGroupContact:[DataModel shared].group.group_id contactKey:key];
                
            }
        } else if ([flag isEqualToString:kRemovedFlag]) {
            BOOL exists = [groupSvc checkGroupContact:[DataModel shared].group.group_id contacKey:key];
            if (exists) {
                NSLog(@"Removing member %@", key);
                [groupSvc removeGroupContact:[DataModel shared].group.group_id contactKey:key];
            }
        }
    }
    
    NSMutableArray *contactKeys = [NSMutableArray arrayWithArray:selectionsMap.allKeys];
    if (![contactKeys containsObject:[DataModel shared].user.contact_key]) {
        [contactKeys addObject:[DataModel shared].user.contact_key];
    }
    
    [chatSvc apiLoadChat:self.theGroup.chat_key callback:^(ChatVO *_chat) {
        _chat.contact_keys = contactKeys;
        [chatSvc apiSaveChat:_chat callback:^(PFObject *object) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Changes saved"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }];
    
//    [_delegate goBack];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate goBack];
}

@end
