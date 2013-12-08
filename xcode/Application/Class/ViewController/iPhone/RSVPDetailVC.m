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
#import "ParseUtils.h"
#import "RSVPResponseCell.h"

#import "UIColor+ColorWithHex.h"

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
    contactSvc = [[ContactManager alloc] init];
    chatSvc = [[ChatManager alloc] init];
    
    FormVO *form =[DataModel shared].form;
    NSLog(@"start_time is %@", form.start_time);
    
    self.subjectLabel.text = form.name;
    
    //    NSDate *dt = [DateTimeUtils readDateFromFriendlyDateTime:form.start_time];
    
    self.dateLabel.text = [DateTimeUtils printDatePartFromDate:form.eventStartsAt];
    self.timeLabel.text = [DateTimeUtils printTimePartFromDate:form.eventStartsAt];
    self.whatText.text = form.details;
    self.whereText.text = form.location;
    
    
    [self.roundPic.layer setCornerRadius:50.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:1.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    
    if (form.pfPhoto) {
        self.roundPic.file = form.pfPhoto;
        [self.roundPic loadInBackground];
    }
    
    CGRect footerFrame = self.footerView.frame;
    self.footerView.hidden = YES;
    CGRect tableFrame = self.theTableView.frame;
    tableFrame.origin.y = footerFrame.origin.y;
    tableFrame.size.height = [DataModel shared].stageHeight - tableFrame.origin.y;
    self.theTableView.frame = tableFrame;
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
//    [self preloadFormData];
//    [self performSearch:@""];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    isLoading = YES;
    [self preloadFormData];
    
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

- (void) preloadFormData {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading"];

    contactTotal = 0;
    allResponses = [[NSMutableArray alloc] init];
    
    contactKeys = [[NSMutableArray alloc] init];
    
    [formSvc apiListFormResponses:[DataModel shared].form.system_id contactKey:nil callback:^(NSArray *results) {
        FormResponseVO *response;
        for (PFObject *pfResponse in results) {
            response = [FormResponseVO readFromPFObject:pfResponse];
            
            if (![contactKeys containsObject:response.contact_key]) {
                [contactKeys addObject:response.contact_key];
            }
            NSLog(@"Response: optionKey %@ contactKey %@", response.option_key, response.contact_key);
            [allResponses addObject:response];
            
        }
        
        if ([DataModel shared].form.counter.intValue != results.count) {
            NSLog(@"Form response counter out of sync. Counter %i vs actual %i",[DataModel shared].form.counter.intValue, results.count );
            NSLog(@"FIXING COUNTER NOW. Runs in background.");
            [formSvc apiUpdateFormCounter:[DataModel shared].form.system_id withCount:[NSNumber numberWithInt:results.count]];
        }
        
        [contactSvc apiLookupContacts:[contactKeys copy] callback:^(NSArray *results) {
            
            [contactSvc lookupContactsFromPhonebook:[contactKeys copy]];
            
            [chatSvc apiListChatForms:nil formKey:[DataModel shared].form.system_id callback:^(NSArray *results) {
                __block int index = 0;
                int total = results.count;
                if (total == 0) {
                    [self loadFormData];
                } else {
                    
                    for (PFObject *result in results) {
                        PFObject *pfChat = result[@"chat"];
                        [pfChat fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (pfChat[@"contact_keys"]) {
                                NSArray *keys = pfChat[@"contact_keys"];
                                contactTotal += keys.count - 1;
                            }
                            index ++;
                            if (index == total) {
                                [self loadFormData];
                            }
                        }];
                    }
                }
                
            }];
        }];
        
    }];
    
}
- (void) loadFormData {
    @try {
        
        
        
        [formSvc apiListFormOptions:[DataModel shared].form.system_id callback:^(NSArray *results) {
            
            NSLog(@"Found form options for form %@ count=%i", [DataModel shared].form.system_id, results.count);
            
            if (results.count > 0) {
                dataArray = [[NSMutableArray alloc] initWithCapacity:results.count];
                FormOptionVO *option;
                optionKeys = [[NSMutableArray alloc] init];
                
                for (PFObject *result in results) {
                    option = [FormOptionVO readFromPFObject:result];
                    option.responses = [[NSMutableArray alloc] init];
                    [dataArray addObject:option];
                    [optionKeys addObject:option.system_id];
                    // Set currentKey to filter table results
                }
                option = [[FormOptionVO alloc] init];
                option.system_id = kResponseWaiting;
                option.name = @"Waiting";
                option.responses = [[NSMutableArray alloc] init];
                [optionKeys addObject:option.system_id];
                
                [dataArray addObject:option];
                
            }
            [self groupResponsesByOption];
            /*
             Need to display:
             -- how many responses received out of total chat contacts
             --
             */
        }];
        
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
}

- (void)groupResponsesByOption
{
    NSLog(@"%s", __FUNCTION__);
    //    [self.tableData removeAllObjects];
    for (FormResponseVO *response in allResponses) {
        
        int pointer = [optionKeys indexOfObject:response.option_key];
        if ([[DataModel shared].contactCache objectForKey:response.contact_key]) {
            response.contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:response.contact_key];
        }
        
        if (pointer > -1) {
            [((FormOptionVO *)[dataArray objectAtIndex:pointer]).responses addObject:response];
            
        }
    }
    isLoading = NO;
    [MBProgressHUD hideHUDForView:self.view animated:NO];

    [self.theTableView reloadData];
}

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
        
        //        self.carouselVC = [[SideScrollVC alloc] initWithData:results];
        //
        //        CGRect carouselFrame = CGRectMake(0, 0, 320, 300);
        //        self.carouselVC.view.frame = carouselFrame;
        //        [self.browseView addSubview:self.carouselVC.view];
        //
        //        [self.browseView sendSubviewToBack:self.carouselVC.view];
        
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    FormOptionVO *option = (FormOptionVO *)[dataArray objectAtIndex:section];
    
    //    return [self headerViewWithTitle:letter];
    NSString *heading = @"";
    switch (section) {
        case 0:
            heading = @"Going";
            break;
        case 1:
            heading = @"Might go";
            break;
        case 2:
            heading = @"Not going";
            break;
        case 3:
            heading = @"Waiting for response";
            break;
            
            
    }
    return [self headerViewWithTitle:heading];
    
}


- (UIView *)headerViewWithTitle:(NSString *)title {
    UIView * sectionHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    sectionHeaderView.backgroundColor = [UIColor colorWithHexValue:0x0d7dac];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"Raleway-Bold" size:17];
    headerLabel.frame = CGRectMake(14, 5, 308, 20);
    headerLabel.textAlignment = NSTextAlignmentCenter;
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    FormOptionVO *option = (FormOptionVO *) [dataArray objectAtIndex:section];
    if (option && option.responses.count > 0) {
        return option.responses.count;
    } else {
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FormOptionVO *option = (FormOptionVO *) [dataArray objectAtIndex:indexPath.section];
    
    if (isLoading) {
        // TODO: add spinner
    }
    if (option && option.responses.count > 0) {
        static NSString *CellIdentifier = @"RSVPResponseCell";
        
        static NSString *CellNib = @"RSVPResponseCell";
        
        RSVPResponseCell *cell = (RSVPResponseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (RSVPResponseCell *)[nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                [cell.roundPic.layer setCornerRadius:23.0f];
                [cell.roundPic.layer setMasksToBounds:YES];
                [cell.roundPic.layer setBorderWidth:1.0f];
                [cell.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
                cell.roundPic.clipsToBounds = YES;
                cell.roundPic.contentMode = UIViewContentModeScaleAspectFill;
            }
            
            
            FormResponseVO *response = [option.responses objectAtIndex:indexPath.row];
            ContactVO *contact = (ContactVO *)[[DataModel shared].phonebookCache objectForKey:response.contact_key];
            if (contact) {
                cell.titleLabel.text = contact.fullname;
                
            } else {
                cell.titleLabel.text = response.contact_key;
            }
            contact = (ContactVO *)[[DataModel shared].contactCache objectForKey:response.contact_key];

            cell.roundPic.file = contact.pfPhoto;
            [cell.roundPic loadInBackground];

        } @catch (NSException * e) {
            NSLog(@"Contact data: Exception: %@", e);
        }
        
        return cell;
    } else {
        static NSString *emptyCellIdentifier = @"EmptyResponseCell";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
        @try {
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellIdentifier];
                cell.frame = CGRectMake(0, 0, 320, 57);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
                cell.textLabel.textColor = [UIColor colorWithHexValue:0x111111];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.backgroundColor = [UIColor whiteColor];
                
            }
            
            cell.textLabel.text = @"None";
            
        } @catch (NSException * e) {
            NSLog(@"No data: Exception: %@", e);
        }
        return cell;
        
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
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
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        [DataModel shared].action = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_delegate gotoSlideWithName:@"FormsHome"];
    }
    
}
- (IBAction)tapAnswerButton {
    
}

@end
