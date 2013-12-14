//
//  AttachFormPanelVC.m
//  Re:group'd
//
//  Created by Hugh Lang on 10/7/13.
//
//

#import "FormSelectorVC.h"
#import "SQLiteDB.h"
#import "AquaTableViewCell.h"

#define kAttachPollIcon     @"icon_attach_poll"
#define kAttachRatingIcon   @"icon_attach_rating"
#define kAttachRSVPIcon     @"icon_attach_rsvp"

@interface FormSelectorVC ()

@end

@implementation FormSelectorVC

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
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];

    self.tableData =[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    [self listFormsByType:[DataModel shared].formType];
//    [self performSearch:nil];
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
    
    static NSString *CellIdentifier = @"attachFormTVC";
    
    AquaTableViewCell *cell = (AquaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
//            CGRect cellFrame = CGRectMake(0, 0, [DataModel shared].stageWidth, 50);
            cell = [[AquaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        FormVO *form = [FormVO readFromDictionary:rowData];
        cell.textLabel.text = form.name;
        
        if ([DataModel shared].formType == FormType_POLL) {
            cell.imageView.image = [UIImage imageNamed:kAttachPollIcon];
        } else if ([DataModel shared].formType == FormType_RATING) {
            cell.imageView.image = [UIImage imageNamed:kAttachRatingIcon];
        } else if ([DataModel shared].formType == FormType_RSVP) {
            cell.imageView.image = [UIImage imageNamed:kAttachRSVPIcon];
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
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
//            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            
            FormVO *form = (FormVO *)[tableData objectAtIndex:indexPath.row];
            
            NSNotification* hideFormSelectorNotification = [NSNotification notificationWithName:@"hideFormSelectorNotification" object:form];
            [[NSNotificationCenter defaultCenter] postNotification:hideFormSelectorNotification];
            // TODO: post notification to close attachFormPanel
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}
- (void)listFormsByType:(int)formType
{
    self.tableData =[[NSMutableArray alloc]init];
    
    for (FormVO *form in [DataModel shared].formsList) {
        if (form.type == formType) {
            [self.tableData addObject:form];
        }
    }
    [self.theTableView reloadData];

    
}

- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    NSString *sql = @"select * from form where type=? order by form_id desc";
    int formtype = (int) [DataModel shared].formType;
//    NSString *sql = [NSString stringWithFormat:sqlTemplate,
//                     [NSNumber numberWithInt:formtype]];
//                     
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql, [NSNumber numberWithInt:formtype]];
    [tableData removeAllObjects];
    
    
    while ([rs next]) {
        [tableData addObject:[rs resultDictionary]];
    }
    
    [self.theTableView reloadData];
    
    
}

- (IBAction)tapCloseButton {
    NSNotification* hideFormSelectorNotification = [NSNotification notificationWithName:@"hideFormSelectorNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideFormSelectorNotification];
    
}

@end
