//
//  RSVPDetailVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "RSVPDetailVC.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"

@interface RSVPDetailVC ()

@end

@implementation RSVPDetailVC

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
    
    CGRect scrollFrame = self.scrollView.frame;
    
    scrollFrame.size.height = [DataModel shared].stageHeight - 30;
    
    
    self.scrollView.frame = scrollFrame;
    self.scrollView.delegate = self;
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    formSvc = [[FormManager alloc] init];

    FormVO *form =[DataModel shared].form;
    NSLog(@"start_time is %@", form.start_time);
    
    self.subjectLabel.text = form.name;
    
    NSDate *dt = [DateTimeUtils readDateFromFriendlyDateTime:form.start_time];
    
    self.dateLabel.text = [DateTimeUtils printDatePartFromDate:dt];
    self.timeLabel.text = [DateTimeUtils printTimePartFromDate:dt];
    self.whatText.text = form.description;
    self.whereText.text = form.location;
    
 
    [self.roundPic.layer setCornerRadius:50.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:1.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *img;
    if (form.imagefile != nil) {
        img = [formSvc loadFormImage:form.imagefile];
        self.roundPic.image = img;
    }

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
            if (filename == nil || filename.length == 0) {
                [dict setValue:@"tesla.jpg" forKey:@"imagefile"];
            }
            [results addObject:dict];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
}


#pragma mark - UITableViewDataSource

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
//        
//        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
//        tableViewHeaderFooterView.textLabel.textColor = [UIColor blueColor];
//    }
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 3;
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
    NSLog(@"%s", __FUNCTION__);
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            
            [DataModel shared].contact = [ContactVO readFromDictionary:rowdata];
            
//            [DataModel shared].action = kActionEDIT;
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
        NSString *sqlTemplate = @"select * from contact where name like '%%%@%%' limit 20";
        
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
        NSString *sqlTemplate = @"select * from contact order by name";
        
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
- (IBAction)tapAnswerButton {
    
}

@end
