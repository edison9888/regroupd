//
//  ContactsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ContactsHomeVC.h"
#import "ContactTableViewCell.h"
#import "UIColor+ColorWithHex.h"

#define kStatusAvailable @"Available"
#define kNameFormat @"%@ %@"

@interface ContactsHomeVC ()

@end

@implementation ContactsHomeVC

@synthesize availableContacts;
@synthesize groupsData;
//@synthesize addressBookData;
@synthesize otherContacts;

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
    
    self.availableContacts =[[NSMutableArray alloc]init];
    self.groupsData =[[NSMutableArray alloc]init];
    self.otherContacts =[[NSMutableArray alloc]init];
    
//    [self populateFromAddressBook];
//    self.contactsData =[[NSMutableArray alloc]init];
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    [self preparePhonebook];
//    [self performSearch:@""];
    
//    [self listMyContacts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) preparePhonebook {
    
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    [contactSvc purgePhonebook];
    NSMutableArray *people = [contactSvc readAddressBook];
    NSLog(@"Found addressbook contacts to load qty:%i", people.count);
    
    [contactSvc bulkLoadPhonebook:[people copy]];

    NSMutableArray *others = [contactSvc listPhonebookByStatus:0];
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    NSDictionary *dict;
    NSString *phoneId;
    for (int i=0; i<others.count; i++) {
        dict = (NSDictionary *) [others objectAtIndex:i];
        phoneId = (NSString *)[dict objectForKey:@"phone"];
        [numbers addObject:phoneId];
    }
    NSLog(@"numbers %@", numbers);
    
    [contactSvc apiLookupContactsByPhoneNumbers:numbers callback:^(NSArray *contacts) {
        NSLog(@"Callback response count %i", contacts.count);
        if (contacts) {
            [contactSvc updatePhonebookWithContacts:contacts];
        }
        [self performSearch:@""];
    }];
    
}
- (void) listMyContacts {
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    isLoading = YES;
    [contactSvc apiListUserContacts:nil callback:^(NSArray *contacts) {
        NSLog(@"Callback response count %i", contacts.count);
        if (contacts) {
            self.availableContacts = [contacts mutableCopy];
            isLoading = NO;
            [self.theTableView reloadData];
        }
    }];
    
}
#pragma mark - UITableViewDataSource

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    switch (section) {
//            
//        case 0:
//            title = @"Available Contacts";
//            break;
//
//        case 1:
//            title = @"Groups";
//            break;
//
//        case 2:
//            title = @"Invite to Regroupd";
//            break;
//            
//        default:
//            break;
//    }
//    return title;
////    return _rowsInSection[section].count ? _sections[section] : nil;
//}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
            
        case 0:
            title = @"Available Contacts";
            break;
            
        case 1:
            title = @"Groups";
            break;
            
        case 2:
            title = @"Invite to Regroupd";
            break;
            
        default:
            break;
    }
    CGRect headerFrame = CGRectMake(0, 0, [DataModel shared].stageWidth, 30);
    
    UIView* customView = [[UIView alloc] initWithFrame:headerFrame];
    if(section==0 || section==1  || section==2)
    {
        customView.backgroundColor = [UIColor colorWithHexValue:0xd6dde1];
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        [headerLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:14]];
        headerLabel.frame = CGRectMake(10, 2, 300, 20);
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = title;
        
        [customView addSubview:headerLabel];
    }
    
    
    
    return customView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.availableContacts.count == 0) {
            return 1;
        } else {
            return [self.availableContacts count];
        }
    } else if (section == 1) {
        if (self.groupsData.count == 0) {
            return 1;
        } else {
            return [self.groupsData count];
        }
    } else if (section == 2) {
        return self.otherContacts.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ContactTableCell";
    static NSString *CellNib = @"ContactTableViewCell";
    
    if (indexPath.section == 0) {
        
        // TODO: replace this with generic UITableViewCell for performance
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (ContactTableViewCell *)[nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            
            if (availableContacts.count > 0) {
                NSDictionary *rowData = (NSDictionary *) [availableContacts objectAtIndex:indexPath.row];
                cell.titleLabel.text = [NSString stringWithFormat:kNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
                
                cell.statusLabel.text = kStatusAvailable;
                
            } else {
                cell.titleLabel.text = @"No contacts yet";
                cell.statusLabel.text = @"";
            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        return cell;
        
    } else if  (indexPath.section == 1) {
        // Groups
        
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (ContactTableViewCell *)[nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            cell.titleLabel.text = @"No groups yet";
            cell.statusLabel.text = @"";
//            if (groupsData.count > 0) {
//                ContactVO *contact = (ContactVO *) [groupsData objectAtIndex:indexPath.row];
//                cell.titleLabel.text = [contact fullname];
//                
//                cell.statusLabel.text = kStatusAvailable;
//                
//            } else {
//                cell.titleLabel.text = @"No contacts yet";
//                cell.statusLabel.text = @"";
//            }
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }

        return cell;
    } else if (indexPath.section == 2) {
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        @try {
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
                cell = (ContactTableViewCell *)[nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            
            NSDictionary *rowData = (NSDictionary *) [otherContacts objectAtIndex:indexPath.row];
            cell.titleLabel.text = [NSString stringWithFormat:kNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
            
            cell.statusLabel.text = @"";
            
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        return cell;
        
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
            NSDictionary *rowdata = [availableContacts objectAtIndex:indexPath.row];
            
            [DataModel shared].contact = [ContactVO readFromDictionary:rowdata];
            [_delegate gotoSlideWithName:@"ContactInfo"];
            
            
//            [DataModel shared].action = kActionEDIT;
//            [_delegate gotoNextSlide];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from phonebook where first_name like '%%%@%%' or last_name like '%%%@%%' limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [availableContacts removeAllObjects];
        
        while ([rs next]) {
            [availableContacts addObject:[rs resultDictionary]];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate;
        sqlTemplate = @"select * from phonebook where status=%i order by last_name";
        
        isLoading = YES;
        int status;
        NSString *sql;

        status = 1;
        sql = [NSString stringWithFormat:sqlTemplate, status];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [availableContacts removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            [availableContacts addObject:dict];
        }
        
        status = 0;
        sql = [NSString stringWithFormat:sqlTemplate, status];
        
        rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [otherContacts removeAllObjects];
        
        while ([rs next]) {
            
            NSDictionary *dict =[rs resultDictionary];
            [otherContacts addObject:dict];
        }
        NSLog(@"otherContacts %i", otherContacts.count);
        
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
    
}

#pragma mark - Action handlers

- (IBAction)tapAddButton
{
//    //    BOOL isOk = YES;
//    NSNotification* showMaskNotification = [NSNotification notificationWithName:@"showMaskNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:showMaskNotification];
    
    [self showModal];
    
}

- (IBAction)tapEditButton
{
    
}

- (IBAction)tapNewContactButton {
    ABNewPersonViewController *newContactVC = [[ABNewPersonViewController alloc] init];
    
    newContactVC.newPersonViewDelegate = self;
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    
    UINavigationController *newNavigationController = [[UINavigationController alloc]
                                                       initWithRootViewController:newContactVC];
    
    [self presentViewController:newNavigationController animated:YES completion:nil];
    
    
}
- (IBAction)tapNewGroupButton {
    [DataModel shared].action = kActionADD;
    [_delegate gotoSlideWithName:@"EditGroup" returnPath:@"ContactsHome"];
}
- (IBAction)tapCancelButton {
    [self hideModal];
}


- (void) showModal {
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = 666;
    [self.view addSubview:bgLayer];
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height;
    float xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    NSLog(@"modal at %f, %f", xpos, ypos);
    self.addModal.layer.zPosition = 99;
    self.addModal.frame = modalFrame;
    [self.view addSubview:self.addModal];
    
    ypos = ([DataModel shared].stageHeight - modalFrame.size.height) / 2;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}

- (void) hideModal {
    
    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height - 40;
    modalFrame.origin.y = ypos;
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                         
                         NSNotification* hideMaskNotification = [NSNotification notificationWithName:@"hideMaskNotification" object:nil];
                         [[NSNotificationCenter defaultCenter] postNotification:hideMaskNotification];
                         
                     }];
    
    
}

#pragma mark ABNewPersonViewControllerDelegate methods

// Dismisses the new-person view controller.

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person

{
    NSLog(@"%s", __FUNCTION__);
    [self hideModal];
    [self dismissViewControllerAnimated:YES completion:NULL];

    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];

    
    @try {
        if (person != NULL) {
            ContactVO *contact = [self readContactFromABPerson:person];
            
            
            // TODO: Check if phone number is set
            if (contact.phone != nil && contact.phone.length > 0) {
                
                NSLog(@"phone number = %@", contact.phone);
                
                NSString *phoneId = [self makePhoneId:contact.phone];
                NSLog(@"phoneId = %@", phoneId);
                contact.phone = phoneId;
                
                if (contactSvc == nil) {
                    contactSvc = [[ContactManager alloc] init];
                }
                
                [contactSvc apiSaveContact:contact callback:^(PFObject *pfContact) {
                    NSLog(@"Callback response objectId %@", pfContact.objectId);
                    contact.system_id = pfContact.objectId;
                    [contactSvc saveContact:contact];
                    
                    [contactSvc apiSaveUserContact:contact callback:^(NSString *objectId) {
                        NSLog(@"apiSaveUserContact callback: response objectId %@", pfContact.objectId);
                        
                        [self listMyContacts];
                    }];
//                    [self performSearch:@""];
                }];
                
            } else {
                NSLog(@"Phone number missing");
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"#####ERROR###### %@", exception);
//
    }
    
}

- (NSString *) makePhoneId:(NSString *)originalString {
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return strippedString;
}


- (ContactVO *) readContactFromABPerson:(ABRecordRef)person
{
    ContactVO* c = [[ContactVO alloc] init];
    
    ABRecordID abRecordID = ABRecordGetRecordID(person);
    NSNumber *recordId = [NSNumber numberWithInt:abRecordID];
    
    NSLog(@"RecordId = %@", recordId);

    if (recordId > 0) {
        CFErrorRef err;
        ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, &err);
        __block BOOL accessGranted = NO;
        
        if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //        dispatch_release(sema);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted)
        {
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            //            ABMultiValueRef profiles = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
            //            CFIndex multiCount = ABMultiValueGetCount(profiles);
            //            for (CFIndex i=0; i<multiCount; i++) {
            //                NSDictionary* profile = ( NSDictionary*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(profiles, i));
            //                NSLog(@"Profile: %@", profile);
            //                c.facebook_id=[profile objectForKey:@"identifier"];
            //            }
            //            CFRelease(profiles);
            NSString *phoneNumber;
            if(phones)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, 0);
                CFRelease(phones);
                phoneNumber = (__bridge NSString *)phoneNumberRef;
                c.phone=phoneNumber;
            }
            if (ABPersonHasImageData(person))
            {
                UIImage *image = [UIImage imageWithData:(NSData *)CFBridgingRelease(ABPersonCopyImageData(person))];
                if(image) {
                    //                    p.imagen=image;
                }
            } else  {
                //                p.imagen=[UIImage imageNamed:@"profile-default-sm.png"];
            }
            CFStringRef email = ABMultiValueCopyValueAtIndex(emails, 0);
            CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            c.first_name = (__bridge NSString *)firstName;
            c.last_name = (__bridge NSString *)lastName;
            
            if (firstName)
                CFRelease(firstName);
            if (lastName)
                CFRelease(lastName);
            if(email)
                CFRelease(email);
            CFRelease(emails);
        }
        CFRelease(ab);
        return c;
        
    } else {
        return nil;
    }
    
}



@end
