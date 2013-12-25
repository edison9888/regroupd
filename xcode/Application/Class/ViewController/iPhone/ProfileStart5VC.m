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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}




#pragma mark - Action handlers

- (IBAction)tapNoButton
{
    // TODO: save permissions
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Notifications_Enabled];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Notifications_Show_Preview];
    [self createUser];
}

- (IBAction)tapYesButton
{
    // TODO: save permissions
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Notifications_Enabled];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Notifications_Show_Preview];
    
    [self createUser];
}

- (void) createUser {
    self.yesButton.enabled = NO;
    self.noButton.enabled = NO;
    
    UserVO *user = [DataModel shared].user;
    user.first_name = @"default";

    
    if (userSvc == nil) {
        userSvc = [[UserManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading"];

    [userSvc apiCreateUserAndContact:user callback:^(PFObject *pfUser, PFObject *pfContact) {
        NSLog(@"Callback response objectId %@", pfUser.objectId);
        user.user_key = pfUser.objectId;
        user.system_id = pfUser.objectId;
        
        UserVO *match = [userSvc lookupUser:user.user_key];
        
        if (match == nil) {
            [userSvc createUser:user];
        }
        [DataModel shared].user = user;
        [DataModel shared].user.contact_key = pfContact.objectId;
        
        ContactVO *contact = [ContactVO readFromPFObject:pfContact];
        [DataModel shared].myContact = contact;

        [self preparePhonebook];
    }];

    
}

- (void) preparePhonebook {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading..."];
    
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
    
    [self batchLookupContactsByPhoneNumbers:numbers];
    
    
    //    [contactSvc apiLookupContactsByPhoneNumbers:numbers callback:^(NSArray *contacts) {
    ////        NSLog(@"Callback response count %i", contacts.count);
    //        if (contacts) {
    //            [contactSvc updatePhonebookWithContacts:contacts];
    //        }
    //        [self performSearch:@""];
    //    }];
    
}
// http://stackoverflow.com/questions/6852012/what-is-an-easy-way-to-break-an-nsarray-with-4000-objects-in-it-into-multiple-a
- (void) batchLookupContactsByPhoneNumbers:(NSMutableArray *)srcArray {
    NSMutableArray *arrayOfArrays = [NSMutableArray array];
    
    int itemsRemaining = [srcArray count];
    int j = 0;
    
    while(j < [srcArray count]) {
        NSRange range = NSMakeRange(j, MIN(50, itemsRemaining));
        NSArray *subarray = [srcArray subarrayWithRange:range];
        [arrayOfArrays addObject:subarray];
        itemsRemaining-=range.length;
        j+=range.length;
    }
    NSLog(@"Total srcArray size %i", srcArray.count);
    if (srcArray.count > 0) {
        for (int i=0; i<arrayOfArrays.count; i++) {
            NSLog(@"batchLookupContactsByPhoneNumbers %i", i);
            NSArray *numbers = (NSArray *) [arrayOfArrays objectAtIndex:i];
            [contactSvc apiLookupContactsByPhoneNumbers:numbers callback:^(NSArray *contacts) {
                //        NSLog(@"Callback response count %i", contacts.count);
                if (contacts) {
                    [contactSvc updatePhonebookWithContacts:contacts];
                }
                if (i+1 == arrayOfArrays.count) {
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                    [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Sign up complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    
                }
            }];
            
        }
        
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
    }

}

#pragma mark - UIAlert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [DataModel shared].navIndex = 4;
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}



@end
