//
//  GroupsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "GroupsHomeVC.h"
#import "DateTimeUtils.h"

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
    
    [chatSvc apiFindGroupChats:[DataModel shared].user.contact_key
                    withStatus:[NSNumber numberWithInt:ChatStatus_GROUP]
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
            
            datetext = group.updated;
            NSDate *updatedAt = [DateTimeUtils dateFromDBDateStringNoOffset:datetext];
            datetext = [DateTimeUtils formatDecimalDate:updatedAt];
            cell.dateLabel.text = datetext;

            UIImage *image = [UIImage imageNamed:@"groups_cell_arrow.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
            //        UIImageView *arrow = [[UIImageView alloc] initWithImage:image];
            //        arrow.frame = frame;
            button.frame = frame;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(checkButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;

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
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            
            GroupVO *group = [GroupVO readFromDictionary:rowdata];
            [DataModel shared].group = group;

            if (group.chat_key != nil && group.chat_key.length > 0) {
                
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
        NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
        
        [DataModel shared].group = [GroupVO readFromDictionary:rowdata];
        
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
        
        NSDictionary *rowdata = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        GroupVO *group = [GroupVO readFromDictionary:rowdata];
        [groupSvc deleteGroup:group];
        [self setEditing:NO animated:YES];
        [self performSearch:@""];
        
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    [self.theTableView setEditing:editing];
    
//    if (inEditMode) {
//        [super setEditing:(BOOL)editing animated:(BOOL)animated];
//    } else {
//        
//    }
//    if (editing)
//        self.editingFromEditButton = YES;
//    self.editingFromEditButton = NO;
    // Other code you may want at this point...
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
