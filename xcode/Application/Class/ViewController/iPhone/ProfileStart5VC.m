//
//  ProfileStart5VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileStart5VC.h"
#import "UserVO.h"
#import <AddressBook/AddressBook.h>

@interface ProfileStart5VC ()

@end

@implementation ProfileStart5VC

@synthesize yesButton, noButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileStart5VC";

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userSvc = [[UserManager alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action handlers

- (IBAction)tapNoButton
{
    // TODO: save permissions
    [self createUser];
}

- (IBAction)tapYesButton
{
    // TODO: save permissions
    [self createUser];
}

- (void) createUser {
    UserVO *user = [DataModel shared].user;
    user.first_name = @"default";

    
    if (userSvc == nil) {
        userSvc = [[UserManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    [userSvc apiCreateUserAndContact:user callback:^(PFObject *pfUser) {
        NSLog(@"Callback response objectId %@", pfUser.objectId);
        user.user_key = pfUser.objectId;
        user.system_id = pfUser.objectId;
        
        [userSvc createUser:user];
        [DataModel shared].user = user;
        
        NSMutableArray *people = [self readAddressBook];
        NSLog(@"Found addressbook contacts to load qty:%i", people.count);
        
        [contactSvc bulkLoadPhonebook:[people copy]];
        
        [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Sign up complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];

    
}
#pragma mark - UIAlert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [DataModel shared].navIndex = 4;
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}

- (NSMutableArray *)readAddressBook {
    NSMutableArray *peopleData = [[NSMutableArray alloc] init];
    
    CFErrorRef err;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    ContactVO *c;
    CFStringRef firstName;
    CFStringRef lastName;
    
    // Only capture users who have mobile phone numbers
    for (int i=0; i<people.count; i++) {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:i];
        
        @try {
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);

            NSString* mobile=nil;
            NSString* mobileLabel;
            for (int i=0; i < ABMultiValueGetCount(phones); i++) {
                //NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                //NSLog(@"%@", phone);
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    continue;
                    
                } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    continue;
                }
            }
            
            if (mobile != nil && mobile.length > 10) {
                c = [[ContactVO alloc] init];
                c.phone = mobile;
                
                firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                c.first_name = (__bridge NSString *)firstName;
                c.last_name = (__bridge NSString *)lastName;
                [peopleData addObject:c];
                
            } else {
                // Ignore contact without mobile phone
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
    }
    if (firstName)
        CFRelease(firstName);
    if (lastName)
        CFRelease(lastName);
    CFRelease(addressBook);
    
    return peopleData;
}


@end
