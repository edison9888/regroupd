//
//  ProfileStart5VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "MBProgressHUD.h"

#import "UserManager.h"
#import "ContactManager.h"
#import "BrandUILabel.h"

@interface ProfileStart5VC : SlideViewController<UIAlertViewDelegate>
{
    CGPoint  offset;
    UserManager *userSvc;
    ContactManager *contactSvc;
}

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

- (IBAction)tapYesButton;
- (IBAction)tapNoButton;

@end
