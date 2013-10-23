//
//  ProfileStart5VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileStart5VC.h"
#import "UserVO.h"

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
    UserVO *user = [[UserVO alloc] init];
    user.first_name = @"default";
    [userSvc createUser:user];
    [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Sign up complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    
    [DataModel shared].navIndex = 4;
    [_delegate gotoSlideWithName:@"FormsHome" andOverrideTransition:kPresentationTransitionDown];
}

- (IBAction)tapYesButton
{
    UserVO *user = [DataModel shared].user;
    user.first_name = @"default";
    
    NSString *objectId = [userSvc apiSaveUser:user];
    if (objectId != nil) {
        NSLog(@"Saved user %@, with objectId %@", user.username, objectId);
        user.user_key = objectId;
        user.system_id = objectId;
        [userSvc createUser:user];
        [DataModel shared].user = user;
        
        [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Sign up complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    } else {
        NSLog(@"objectId is null.");
    }

}

#pragma mark - UIAlert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [DataModel shared].navIndex = 4;
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}


@end
