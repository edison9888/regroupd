//
//  ProfileStart4VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileStart4VC.h"
#import "UserVO.h"

@interface ProfileStart4VC ()

@end

@implementation ProfileStart4VC

@synthesize yesButton, noButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileStart4VC";

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action handlers

- (IBAction)tapNoButton
{
    [_delegate gotoNextSlide];
}

- (IBAction)tapYesButton
{
    [_delegate gotoNextSlide];
}

@end
