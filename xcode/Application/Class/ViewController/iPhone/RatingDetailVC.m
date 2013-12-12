//
//  RatingDetailVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "RatingDetailVC.h"
#import "SQLiteDB.h"

#import "ParseUtils.h"
#import "UIColor+ColorWithHex.h"
#import "NSString+NumberFormat.h"

#define kPageCounter @"%@ / %@"
#define kResponseCaption @"Average rating: %@"

@interface RatingDetailVC ()

@end

@implementation RatingDetailVC

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
    recipientKeySet = [[NSMutableSet alloc] init];
    
    self.subjectLabel.text = [DataModel shared].form.name;
    self.responsesLabel.text = @"";
    self.optionTitle.text = @"";
    
    if (self.totalRatingSlider == nil) {
        CGRect sliderFrame = self.responsesLabel.frame;
        sliderFrame.origin.y -= 40;
        sliderFrame.origin.x = 18;
        sliderFrame.size.width = 240;
        sliderFrame.size.height = 20;
        self.totalRatingSlider = [[RatingMeterSlider alloc] initWithFrame:sliderFrame];
        [self.totalRatingSlider setSliderColor:[UIColor colorWithHexValue:kSelectedColor]];
        [self.totalRatingSlider setDotColor:[UIColor colorWithHexValue:kDotColor]];
        [self.view addSubview:self.totalRatingSlider];
    }

    self.totalRatingSlider.hidden = YES;
    self.starRatingBG.hidden = YES;
    self.starRatingLabel.hidden = YES;
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    [self.theTableView setSeparatorColor:[UIColor grayColor]];
    [self.theTableView setSeparatorInset:UIEdgeInsetsZero];

    self.tableData =[[NSMutableArray alloc]init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateNotificationHandler:)     name:@"pageUpdateNotification"            object:nil];
        

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
            
//            NSLog(@"Lookup contacts found %@", results);
            
            [contactSvc lookupContactsFromPhonebook:contactKeys];
            
            
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
                                
                                for (NSString *k in keys) {
                                    if (![k isEqualToString:[DataModel shared].user.contact_key]) {
                                        [recipientKeySet addObject:k];
                                    }
                                }
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
        
        
        contactTotal = recipientKeySet.count;
        
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
        }];
        
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
}


- (void)filterResponsesByOption:(NSString *)optionKey
{
    NSLog(@"%s", __FUNCTION__);
    
    double ratingTotal = 0;
    
    [self.tableData removeAllObjects];
    
    if (allResponses.count > 0) {
        for (FormResponseVO *response in allResponses) {
            if ([response.option_key isEqualToString:optionKey]) {
                if ([[DataModel shared].contactCache objectForKey:response.contact_key]) {
                    response.contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:response.contact_key];
                }
                if (response.rating) {
                    ratingTotal += response.rating.floatValue;
                }
                [self.tableData addObject:response];
            }
        }
        double avgRating = ratingTotal / (double) self.tableData.count;
        NSString *avgRatingText = [NSString formatDoubleWithMaxDecimals:avgRating minDecimals:1 maxDecimals:1];
        
        NSLog(@"Rating total is %f with avg %@", ratingTotal, avgRatingText);
        NSString *caption = [NSString stringWithFormat:kResponseCaption, avgRatingText];
        self.responsesLabel.text = caption;
        [self.totalRatingSlider setRatingBar:(float) avgRating];
        avgRatingText = [NSString formatDoubleWithMaxDecimals:avgRating minDecimals:0 maxDecimals:0];
        self.starRatingLabel.text = avgRatingText;
        
    } else {
        self.responsesLabel.text = @"No responses yet";
        self.starRatingLabel.text = @"";
        [self.totalRatingSlider setRatingBar:0];
    }
    
    self.totalRatingSlider.hidden = NO;
    self.starRatingBG.hidden = NO;
    self.starRatingLabel.hidden = NO;

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
            if (filename == nil || filename.length == 0) {
                [dict setValue:@"tesla.jpg" forKey:@"imagefile"];
            }
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

#pragma mark - Notifications

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
        
        
        NSMutableDictionary *pageData = (NSMutableDictionary *) [dataArray objectAtIndex:pageIndex.intValue];
        self.optionTitle.text = (NSString *) [pageData objectForKey:@"name"];
        
        [self filterResponsesByOption:currentKey];
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
    NSLog(@"%s", __FUNCTION__);
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"RatingResponseCell";
    static NSString *CellNib = @"RatingResponseCell";
    
    RatingResponseCell *cell = (RatingResponseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (RatingResponseCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        FormResponseVO *response = (FormResponseVO *) [tableData objectAtIndex:indexPath.row];
        
        
        
        [cell.ratingSlider setRatingBar:response.rating.floatValue];

        cell.roundPic.image = [DataModel shared].anonymousImage;
        
        cell.roundPic.file = response.contact.pfPhoto;
        [cell.roundPic loadInBackground];
        if ([response.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
            cell.titleLabel.text = @"Me";
        } else if ([[DataModel shared].contactCache objectForKey:response.contact_key]) {
            ContactVO *pbcontact = [[DataModel shared].contactCache objectForKey:response.contact_key];
            cell.titleLabel.text = pbcontact.fullname;
        } else {
            cell.titleLabel.text = response.contact.phone;
        }
        NSString *ratingText = [NSString formatDoubleWithMaxDecimals:[response.rating doubleValue]
                                                         minDecimals:0 maxDecimals:0];
        cell.ratingLabel.text = ratingText;
        
//
//        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
//        cell.rowdata = rowData;
        
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

- (IBAction)tapLeftArrow {
    [self.carouselVC goPrevious];
}
- (IBAction)tapRightArrow {
    [self.carouselVC goNext];
}
@end
