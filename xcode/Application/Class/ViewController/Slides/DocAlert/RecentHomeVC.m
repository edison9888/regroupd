//
//  RecentHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "RecentHomeVC.h"
#import "FaxManager.h"
#import "FaxAccountVO.h"
#import "ContactVO.h"
#import "FaxLogVO.h"
#import "UIColor+ColorWithHex.h"

@interface RecentHomeVC ()

@end

@implementation RecentHomeVC

@synthesize tableData;

static NSString *kEditLabel = @"EDIT";
static NSString *kDoneLabel = @"DONE";
// light green 0x6CCC86
// default green 0x509DAB


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
    inEditMode = NO;
    filterOption = 0;
    
    self.allButton.backgroundColor = [UIColor colorWithHexValue:0x6CCC86];

    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    self.navCaption.text = qtyLeftCaption;

    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    faxSvc = [[FaxManager alloc] init];
    
    [self performSearch:@""];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"RecentTableCell";
    static NSString *CellNib = @"RecentTableViewCell";
    
    RecentTableViewCell *cell = (RecentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (RecentTableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        int mode = -1;
        if (inEditMode) {
            mode = 1;
        } else {
            mode = 0;
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        [cell setRowdata:rowData inMode:mode];
        
        
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
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            FaxLogVO *faxlog = [FaxLogVO readFromDictionary:rowdata];
            
            [DataModel shared].faxlog = faxlog;
            
            ContactVO *contact = [faxSvc selectContactByID:faxlog.contact_id];
            [DataModel shared].contact = contact;
            
            [_delegate gotoNextSlide];
            
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
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete 
    }
}

//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    
//    if (editing)
//        self.editingFromEditButton = YES;
//    [super setEditing:(BOOL)editing animated:(BOOL)animated];
//    self.editingFromEditButton = NO;
//    // Other code you may want at this point...
//}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    NSString *sqlTemplate = nil;
    
    if (filterOption == 0) {
        sqlTemplate = @"select f.*, c.name from fax_log as f join contact as c on f.contact_id=c.contact_id order by f.created desc";
    } else {
        sqlTemplate = @"select f.*, c.name from fax_log as f join contact as c on f.contact_id=c.contact_id where f.status=0 order by f.created desc";
        
    }
    
    
    NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    [tableData removeAllObjects];
    
    while ([rs next]) {
        [tableData addObject:[rs resultDictionary]];
    }
    
    [self.theTableView reloadData];
    
    
}

#pragma mark - Action handlers
// light green 0x6CCC86
// default green 0x509DAB

- (IBAction)tapAllButton
{
    if (filterOption == 1) {
        filterOption = 0;
        self.allButton.backgroundColor = [UIColor colorWithHexValue:0x6CCC86];
        self.unsentButton.backgroundColor = [UIColor colorWithHexValue:0x509DAB];
        [self performSearch:nil];
    }
}

- (IBAction)tapUnsentButton
{
    if (filterOption == 0) {
        filterOption = 1;
        self.allButton.backgroundColor = [UIColor colorWithHexValue:0x509DAB];
        self.unsentButton.backgroundColor = [UIColor colorWithHexValue:0x6CCC86];

        [self performSearch:nil];
        
    }
}

- (IBAction)tapEditButton
{
    if (inEditMode) {
        inEditMode = NO;
        [self.editButton setTitle:kEditLabel forState:UIControlStateNormal];
        
        [self.theTableView reloadData];
        
    } else {
        inEditMode = YES;
        [self.editButton setTitle:kDoneLabel forState:UIControlStateNormal];

        [self.theTableView reloadData];

    }
    
    
    
}


@end
