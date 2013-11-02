//
//  ProfileStart5VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUILabel.h"
#import "UserManager.h"
#import "ContactManager.h"

@interface ProfileStart5VC : SlideViewController<UIAlertViewDelegate>
{
    CGPoint  offset;
    UserManager *userSvc;
    ContactManager *contactSvc;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

- (IBAction)tapYesButton;
- (IBAction)tapNoButton;

@end
