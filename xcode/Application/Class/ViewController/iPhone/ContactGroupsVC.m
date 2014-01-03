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
        
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    groupSvc = [[GroupManager alloc] init];
    
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


- (void)performSearch:(NSString *)searchText
{
    
    
    NSLog(@"%s: %@", __FUNCTION__, searchText);
//    NSMutableArray *groups = [groupSvc listContactGroups:theContactKey];
    
    memberKeys = [groupSvc listContactGroupIds:theContactKey];
    selectionsMap = [[NSMutableDictionary alloc] initWithCapacity:memberKeys.count];
    
    for (NSString *key in memberKeys) {
        [selectionsMap setObject:kMemberFlag forKey:key];
    }

    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select * from groups order by updated desc";
    
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
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.titleLabel.text = [rowData objectForKey:@"name"];
        
        NSNumber *groupId = [rowData objectForKey:@"group_id"];
        NSString *flag;
        if ([selectionsMap objectForKey:groupId] != nil) {
            flag = (NSString *) [selectionsMap objectForKey:groupId];
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
            NSNumber *groupId = [rowdata objectForKey:@"group_id"];

            NSString *flag;
            flag = (NSString *) [selectionsMap objectForKey:groupId];
            if (flag == nil) {
                if (status == 1) {
                    [selectionsMap setObject:kAddedFlag forKey:groupId];
                } else {
                    
                    // This should not happen
                    NSLog(@"Invalid state. Trying to remove group not in original set groupId = %@", groupId);
                    [selectionsMap setObject:kRemovedFlag forKey:groupId];
                }
            } else {
                if (status == 0) {
                    // Remove from group
                    if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
                        [selectionsMap setObject:kRemovedFlag forKey:groupId];
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
                        [selectionsMap setObject:kAddedFlag forKey:groupId];
                        
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
    
    for (NSNumber *num in selectionsMap) {
        flag = (NSString *) [selectionsMap objectForKey:num];
        
        if ([flag isEqualToString:kMemberFlag] || [flag isEqualToString:kAddedFlag]) {
            BOOL exists = [groupSvc checkGroupContact:num.intValue contacKey:theContactKey];
            if (!exists) {
                NSLog(@"Adding new member from group %@", num);
                [groupSvc saveGroupContact:num.intValue contactKey:theContactKey];
                
            }
        } else if ([flag isEqualToString:kRemovedFlag]) {
            BOOL exists = [groupSvc checkGroupContact:num.intValue contacKey:theContactKey];
            if (exists) {
                NSLog(@"Removing member from group %@", num);
                [groupSvc removeGroupContact:num.intValue contactKey:theContactKey];
            }
        }
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Changes saved"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    
    
    //    [_delegate goBack];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate goBack];
}


@end
