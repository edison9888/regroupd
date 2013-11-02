//
//  AppStartVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "AppStartVC.h"
#import "UserManager.h"
#import "ContactManager.h"

@interface AppStartVC ()

@end

@implementation AppStartVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (IS_IPHONE_5) {
        nibNameOrNil = @"AppStartVC_5";
    } else {
        nibNameOrNil = @"AppStartVC";
    }

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
    
//    TODO: determine if user needs to create profile
    [self performSelector:@selector(startNewProfile) withObject:nil afterDelay:3];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void) startNewProfile
{
    NSLog(@"%s", __FUNCTION__);
    __block BOOL hasAccount = NO;

    UserManager *userSvc = [[UserManager alloc] init];
    UserVO *user = [userSvc lookupDefaultUser];
    PFUser *u;
    
    if (user == nil) {
        // TODO: Attempt to login
        [_delegate gotoSlideWithName:@"ProfileStart1"];

    } else if ([PFUser currentUser] == nil) {
        // db user is not nil.  Try to login
        NSLog(@"db user does not exist");
        
//        u = [PFUser logInWithUsername:user.username password:user.password];
        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    } else if ([PFUser currentUser] != nil) {
        
        [DataModel shared].user = user;
        
        u = [PFUser currentUser];
        NSLog(@"Current user is %@, %@", u.username, u.objectId);
        [userSvc apiLookupContactForUser:u callback:^(PFObject *pfContact) {
            if (pfContact != nil) {
                NSLog(@"Valid user is %@, user_key=%@, contact_key=%@", u.username, u.objectId, pfContact.objectId);
                [DataModel shared].user.contact_key = pfContact.objectId;
                [DataModel shared].navIndex = 3;
                [_delegate gotoSlideWithName:@"FormsHome"];
                hasAccount = YES;
            } else {
                NSLog(@"No contact for user");
                [_delegate gotoSlideWithName:@"ProfileStart1"];
            }
        }];
        
    } else {
        // No-op. Condition not possible
//        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    }
        
}

@end
