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
        
        [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Sign up complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];

    
}
#pragma mark - UIAlert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [DataModel shared].navIndex = 4;
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}



@end
