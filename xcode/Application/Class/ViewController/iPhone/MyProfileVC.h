//
//  MyProfileVC.h
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
#import "BrandUIButton.h"

@interface MyProfileVC : SlideViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIView *bgLayer;
    UserManager *userSvc;
    ContactManager *contactSvc;

}
@property (nonatomic, retain) UIImagePickerController* imagePickerVC;
@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUIButton *messageButton;
@property (nonatomic, strong) IBOutlet BrandUIButton *phoneButton;

@property (nonatomic, strong) IBOutlet UIView *photoModal;

- (IBAction)tapBackButton;
- (IBAction)tapMessageButton;
- (IBAction)tapPhoneButton;
- (IBAction)tapGroupsButton;
- (IBAction)tapBlockButton;

- (IBAction)tapPhotoArea;
- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showModal;
- (void) hideModal;

@end
