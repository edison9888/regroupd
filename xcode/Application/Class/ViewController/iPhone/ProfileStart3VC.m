//
//  ProfileStart3VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileStart3VC.h"
#import "UserVO.h"

@interface ProfileStart3VC ()

@end

@implementation ProfileStart3VC

@synthesize yesButton, noButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileStart3VC";

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGRect frame = self.view.frame;
        frame.size.height += 20;
        self.view.frame = frame;
    }

    
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
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Access_Contacts];

    [_delegate gotoNextSlide];
}

- (IBAction)tapYesButton
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Access_Contacts];
    [_delegate gotoNextSlide];
}

@end
