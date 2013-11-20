//
//  ChatsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ChatsHomeVC.h"
#import "ChatVO.h"

@interface ChatsHomeVC ()

@end

@implementation ChatsHomeVC

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
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    fetchCount = 0;
    [self listMyChats];
    
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
    NSLog(@"%s", __FUNCTION__);
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"ChatTableCell";
    static NSString *CellNib = @"ChatTableViewCell";
    
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (ChatTableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        ChatVO *rowData = (ChatVO *) [tableData objectAtIndex:indexPath.row];
        cell.rowdata = rowData;
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (NSDictionary *) readPFObjectAsDictionary:(PFObject *) data {
    NSArray * allKeys = [data allKeys];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in allKeys) {
        
        [dict setObject:[data objectForKey:key] forKey:key];
        
    }
    return dict;
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
            
            [DataModel shared].chat = (ChatVO *)[tableData objectAtIndex:indexPath.row];
            
            [_delegate gotoSlideWithName:@"Chat"];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}

- (void)listMyChats
{
    NSLog(@"%s", __FUNCTION__);
    self.tableData =[[NSMutableArray alloc]init];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading"];
    [self.hud setDimBackground:YES];

    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    
    [chatSvc apiListChats:[DataModel shared].user.contact_key callback:^(NSArray *results) {
        fetchCount++;
        NSLog(@"apiListChats response count %i", results.count);
        ChatVO *chat;
        if (results.count == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self.theTableView reloadData];
            return;
        }
        for (PFObject* result in results) {
            NSMutableArray *namesArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *namesMap = [[NSMutableDictionary alloc] init];
            unknownContactKeys = [[NSMutableArray alloc] init];
//            data = [DataModel readPFObjectAsDictionary:result];
            chat = [ChatVO readFromPFObject:result];
            
            NSArray *keys = [result objectForKey:@"contact_keys"];
            NSLog(@"contact keys = %@", keys);
            NSString *name;
            NSMutableDictionary *resultMap = [contactSvc lookupContactsFromPhonebook:keys];
            ContactVO *contact = nil;
            for (NSString *key in keys ) {
                if (![key isEqualToString:[DataModel shared].user.contact_key]) {
                    if ([resultMap objectForKey:key] == nil) {
                        // Unlikely result
                        [unknownContactKeys addObject:key];
                    } else if ([resultMap objectForKey:key] == [NSNull null]) {
                        // Null object indicates not in phonebook
                        [unknownContactKeys addObject:key];
                    } else {
                        contact = (ContactVO *) [resultMap objectForKey:key];
                        if (contact.first_name != nil && contact.last_name != nil) {
                            name = contact.fullname;                            
                            [namesArray addObject:name];
                            [namesMap setObject:name forKey:contact.system_id];
                        } else if (contact.phone != nil) {
                            name = contact.phone;
                            [namesArray addObject:name];
                            [namesMap setObject:name forKey:contact.system_id];
                        } else {
                            // This is unlikely. Contact results are from address book
                            NSLog(@"Unexpected condition: contact has no name or phone");
                            [unknownContactKeys addObject:key];
                        }
                        
                    }
                }
            }
//            for (ContactVO *contact in contacts) {
//            }
            NSString *names = [namesArray componentsJoinedByString:@", "];
            chat.names = names;
            isLoading = NO;

            chat.namesMap = namesMap;
            [tableData addObject:chat];
            
            
            // Finish lookup for unknown contacts and reload when done.
            if (unknownContactKeys.count > 0) {
                if (fetchCount <= 2) {
                    [self lookupUnknownContacts];
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                    [self.theTableView reloadData];
                }
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [self.theTableView reloadData];
                
            }

        }
    }];
}

- (void) lookupUnknownContacts {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Unknown contacts %@", unknownContactKeys);
    [contactSvc apiLookupContacts:unknownContactKeys callback:^(NSArray *results) {
        [self listMyChats];
    }];
}

#pragma mark - Action handlers

- (IBAction)tapAddButton
{
    //    BOOL isOk = YES;
    [DataModel shared].action = kActionADD;
    [_delegate gotoNextSlide];
    
}

- (IBAction)tapEditButton
{
    
}
@end
