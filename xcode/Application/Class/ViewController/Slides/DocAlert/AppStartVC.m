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
    
    UserManager *userService = [[UserManager alloc] init];
    
    UserVO *user = [userService lookupDefaultUser];
    
    
    
    if (user == nil) {
//        [DataModel shared].navIndex = 1;
//        [_delegate gotoSlideWithName:@"GroupsHome"];
        [DataModel shared].navIndex = 3;
        [_delegate gotoSlideWithName:@"FormsHome"];
        
    } else {
        
        [DataModel shared].navIndex = 3;
        [_delegate gotoSlideWithName:@"FormsHome"];
    }
    
}

@end
