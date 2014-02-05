//
//  PollDetailVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "PollDetailVC.h"
#import "SQLiteDB.h"
#import "ParseUtils.h"
#import <QuartzCore/QuartzCore.h>

#define kPageCounter @"%@ / %@"
#define kResponseCaption @"%i/%i people chose this"

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
    chatSvc = [[ChatManager alloc] init];
    contactSvc = [[ContactManager alloc] init];
    allResponses = [[NSMutableArray alloc] init];
    contactKeys = [[NSMutableArray alloc] init];
    
    self.subjectLabel.text = [DataModel shared].form.name;
    self.optionTitle.text = @"";
    self.responsesLabel.text = @"";
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    [self.theTableView setSeparatorColor:[UIColor grayColor]];
//    [self.theTableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateNotificationHandler:)     name:@"pageUpdateNotification"            object:nil];
    
    
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
    contactTotal = 0;
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
            
            [contactSvc lookupContactsFromPhonebook:contactKeys];
            
            [formSvc apiCountFormContacts:[DataModel shared].form.system_id excluding:[DataModel shared].user.contact_key callback:^(int rowcount) {
                contactTotal = rowcount;
                [self loadFormData];
            }];
//            [chatSvc apiListChatForms:nil formKey:[DataModel shared].form.system_id callback:^(NSArray *results) {
//                __block int index = 0;
//                int total = results.count;
//                if (total == 0) {
//                    [self loadFormData];
//                } else {
//                    
//                    for (PFObject *result in results) {
//                        PFObject *pfChat = result[@"chat"];
//                        [pfChat fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                            if (pfChat[@"contact_keys"]) {
//                                NSArray *keys = pfChat[@"contact_keys"];
//                                contactTotal += keys.count - 1;
//                            }
//                            index ++;
//                            if (index == total) {
//                                [self loadFormData];
//                            }
//                        }];
//                    }
//                }
//                
//            }];
        }];
        
    }];
    
}
- (void) loadFormData {
    @try {
        
        
        
        [formSvc apiListFormOptions:[DataModel shared].form.system_id callback:^(NSArray *results) {
            
            NSLog(@"Found form options for form %@ count=%i", [DataModel shared].form.system_id, results.count);
            
            if (results.count > 0) {
                dataArray = [[NSMutableArray alloc] initWithCapacity:results.count];
                NSMutableDictionary *dict;
                optionKeys = [[NSMutableArray alloc] init];
                
                for (PFObject *result in results) {
                    dict = [ParseUtils readFormOptionDictFromPFObject:result];
                    [dataArray addObject:dict];
                    [optionKeys addObject:[dict objectForKey:@"system_id"]];
                    // Set currentKey to filter table results
                }
                self.carouselVC = [[SideScrollVC alloc] initWithData:dataArray];
                
                CGRect carouselFrame = CGRectMake(0, 0, 320, 300);
                self.carouselVC.view.frame = carouselFrame;
                [self.browseView addSubview:self.carouselVC.view];
                
                [self.browseView sendSubviewToBack:self.carouselVC.view];
                
                
                currentKey = [optionKeys objectAtIndex:0];
                [self filterResponsesByOption:currentKey];
            }
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

- (void)filterResponsesByOption:(NSString *)optionKey
{
    NSLog(@"%s", __FUNCTION__);
    [self.tableData removeAllObjects];

    if (allResponses.count > 0) {
        for (FormResponseVO *response in allResponses) {
            if ([response.option_key isEqualToString:optionKey]) {
//                if ([response.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
//                    
//                } else
                if ([[DataModel shared].contactCache objectForKey:response.contact_key]) {
                    response.contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:response.contact_key];
                }
                [self.tableData addObject:response];
            }
        }
        NSString *caption = [NSString stringWithFormat:kResponseCaption, self.tableData.count, contactTotal];
        self.responsesLabel.text = caption;
        
    } else {
        self.responsesLabel.text = @"No responses yet";
//        self.starRatingLabel.text = @"";
    }

    [self.theTableView reloadData];
}

//- (void) loadFormOptions {
//    
//    @try {
//        
//        NSMutableArray *results = [[NSMutableArray alloc] init];
//        
//        NSString *sql = @"select * from form_option where form_id=?";
//        
//        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
//                           [NSNumber numberWithInt:[DataModel shared].form.form_id]];
//        
//        NSDictionary *dict;
//        NSString *filename;
//        
//        while ([rs next]) {
//            dict = [rs resultDictionary];
//            filename = (NSString *) [dict valueForKey:@"imagefile"];
//            [results addObject:dict];
//        }
//        
//        self.carouselVC = [[SideScrollVC alloc] initWithData:results];
//        
//        CGRect carouselFrame = CGRectMake(0, 0, 320, 300);
//        self.carouselVC.view.frame = carouselFrame;
//        [self.browseView addSubview:self.carouselVC.view];
//        
//        [self.browseView sendSubviewToBack:self.carouselVC.view];
//        
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@", exception);
//    }
//    
//    
//}

- (void)pageUpdateNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    if (notification.object) {
        NSNumber *pageIndex = (NSNumber *) notification.object;
        NSString *pageCounter = [NSString stringWithFormat:kPageCounter,
                                 [NSNumber numberWithInt:pageIndex.intValue + 1],
                                 [NSNumber numberWithInt:optionKeys.count]];
        self.counterLabel.text = pageCounter;
        currentKey = [optionKeys objectAtIndex:pageIndex.intValue];
        [self filterResponsesByOption:currentKey];

        NSMutableDictionary *pageData = (NSMutableDictionary *) [dataArray objectAtIndex:pageIndex.intValue];
        self.optionTitle.text = (NSString *) [pageData objectForKey:@"name"];
    }
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
    
    static NSString *CellIdentifier = @"PollResponseCell";
    static NSString *CellNib = @"PollResponseCell";
    
    PollResponseCell *cell = (PollResponseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (PollResponseCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            [cell.roundPic.layer setCornerRadius:23.0f];
            [cell.roundPic.layer setMasksToBounds:YES];
            [cell.roundPic.layer setBorderWidth:1.0f];
            [cell.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
            cell.roundPic.clipsToBounds = YES;
            cell.roundPic.contentMode = UIViewContentModeScaleAspectFill;
        }
        FormResponseVO *response = (FormResponseVO *) [tableData objectAtIndex:indexPath.row];
        if ([response.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
            cell.titleLabel.text = @"Me";
        } else if ([[DataModel shared].phonebookCache objectForKey:response.contact_key]) {
            ContactVO *pbcontact = [[DataModel shared].phonebookCache objectForKey:response.contact_key];
            cell.titleLabel.text = pbcontact.fullname;
        } else {
            cell.titleLabel.text = response.contact.phone;
        }
//        cell.titleLabel.text = response.contact.fullname;
        
        cell.roundPic.image = [DataModel shared].anonymousImage;
        
        cell.roundPic.file = response.contact.pfPhoto;
        [cell.roundPic loadInBackground];
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    //    @try {
    //        if (indexPath != nil) {
    //            NSLog(@"Selected row %i", indexPath.row);
    //
    //            selectedIndex = indexPath.row;
    //            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
    //
    //            [DataModel shared].contact = [ContactVO readFromDictionary:rowdata];
    //
    //            [DataModel shared].action = kActionEDIT;
    //            [_delegate gotoNextSlide];
    //
    //        }
    //    } @catch (NSException * e) {
    //        NSLog(@"Exception: %@", e);
    //    }
    //
    
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
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        [DataModel shared].action = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_delegate gotoSlideWithName:@"FormsHome"];
    }
    
}

- (IBAction)tapLeftArrow {
    [self.carouselVC goPrevious];
}
- (IBAction)tapRightArrow {
    [self.carouselVC goNext];
}
@end
