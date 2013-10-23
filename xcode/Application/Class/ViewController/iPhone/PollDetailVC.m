//
//  PollDetailVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "PollDetailVC.h"
#import "SQLiteDB.h"

@interface PollDetailVC ()

@end

@implementation PollDetailVC

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
    
    formSvc = [[FormManager alloc] init];
    
    self.subjectLabel.text = [DataModel shared].form.name;
    
    [self loadFormOptions];
    
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePageNumberHandler:)     name:@"updatePageNumber"            object:nil];

    [self performSearch:@""];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Form Options handling

- (void) loadFormOptions {
    
    @try {
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        NSString *sql = @"select * from form_option where form_id=?";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                           [NSNumber numberWithInt:[DataModel shared].form.form_id]];
        
        NSDictionary *dict;
        NSString *filename;
        
        while ([rs next]) {
            dict = [rs resultDictionary];
            filename = (NSString *) [dict valueForKey:@"imagefile"];
            [results addObject:dict];
        }
        
        self.carouselVC = [[SideScrollVC alloc] initWithData:results];
        
        CGRect carouselFrame = CGRectMake(0, 0, 320, 300);
        self.carouselVC.view.frame = carouselFrame;
        [self.browseView addSubview:self.carouselVC.view];
        
        [self.browseView sendSubviewToBack:self.carouselVC.view];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
}

- (void)updatePageNumberHandler:(NSNotification*)notification
{
    NSString *text = (NSString *) notification.object;
    self.counterLabel.text = text;
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
    
    static NSString *CellIdentifier = @"CCTableCell";
    static NSString *CellNib = @"CCTableViewCell";
    
    CCTableViewCell *cell = (CCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (CCTableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.rowdata = rowData;
        
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
            
            [DataModel shared].contact = [ContactVO readFromDictionary:rowdata];
            
            [DataModel shared].action = kActionEDIT;
            [_delegate gotoNextSlide];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from contact where first_name like '%%%@%%' or last_name like '%%%@%%' limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            [tableData addObject:[rs resultDictionary]];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate = @"select * from contact order by first_name";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            NSLog(@"Result %@", [dict objectForKey:@"name"]);
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
    
}

#pragma mark - Action handlers

- (IBAction)tapCloseButton
{
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}

- (IBAction)tapLeftArrow {
    [self.carouselVC goPrevious];
}
- (IBAction)tapRightArrow {
    [self.carouselVC goNext];
}
@end
