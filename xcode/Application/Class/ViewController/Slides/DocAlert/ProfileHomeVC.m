//
//  ProfileHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileHomeVC.h"
#import "UserManager.h"
#import "UserVO.h"
#import "FaxManager.h"
#import "FaxAccountVO.h"

@interface ProfileHomeVC ()

@end


@implementation ProfileHomeVC

@synthesize fullname, company, title;
@synthesize address1, address2, phone, navCaption;
@synthesize signatureView;

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
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    self.navCaption.text = qtyLeftCaption;

    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    UserManager *userSvc = [[UserManager alloc] init];
    UserVO *user = [userSvc lookupDefaultUser];
    [DataModel shared].user = user;
    
    NSString *name = nil;
    
    if (user.middlename == nil || user.middlename.length == 0) {
        name = [NSString stringWithFormat:@"%@ %@", user.firstname, user.lastname];
    } else {
        name = [NSString stringWithFormat:@"%@ %@ %@", user.firstname, user.middlename, user.lastname];
    }
    self.fullname.text = name;
    self.company.text = user.company;
    self.title.text = user.title;
    self.address1.text = user.address;
    
    NSString *location = [NSString stringWithFormat:@"%@, %@ %@", user.city, user.state, user.zip];
    self.address2.text = location;
    self.phone.text = user.phone;
    
    UIImage *image = [userSvc loadSignature:@"sig_1.png"];
    if (image != nil) {
        signatureView.image = image;
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action handlers


- (IBAction)tapEditButton
{
    [_delegate gotoNextSlide];
    
}


@end
