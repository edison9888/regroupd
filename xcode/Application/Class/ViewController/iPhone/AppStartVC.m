//
//  AppStartVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "AppStartVC.h"
#import "UserManager.h"

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
    PFUser *u = [PFUser currentUser];
    NSLog(@"Current user is %@, %@", u.username, u.objectId);
    
    if (u.objectId != nil && u.objectId.length > 0) {
        [DataModel shared].navIndex = 3;
        [_delegate gotoSlideWithName:@"FormsHome"];
        
    } else {
        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    }
    
//    UserManager *userService = [[UserManager alloc] init];
//    
//    UserVO *user = [userService lookupDefaultUser];
//    
//    
//    [DataModel shared].user = user;
//
//    if (user == nil) {
////        [DataModel shared].navIndex = 1;
////        [_delegate gotoSlideWithName:@"GroupsHome"];
//        [_delegate gotoSlideWithName:@"ProfileStart1"];
//        
//    } else {
//        [DataModel shared].navIndex = 3;
//        [_delegate gotoSlideWithName:@"FormsHome"];
//        
//    }
    
}

@end
