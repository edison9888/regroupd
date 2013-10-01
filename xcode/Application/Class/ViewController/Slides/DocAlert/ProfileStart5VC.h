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

@interface ProfileStart5VC : SlideViewController<UIAlertViewDelegate>
{
    CGPoint  offset;
    UserManager *userSvc;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

- (IBAction)tapYesButton;
- (IBAction)tapNoButton;

@end
