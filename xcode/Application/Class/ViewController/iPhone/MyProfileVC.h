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
#import "BrandUITextField.h"

@interface MyProfileVC : SlideViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate> {
    UIView *bgLayer;
    UserManager *userSvc;
    ContactManager *contactSvc;
    UITextField *_currentField;
    BOOL keyboardIsShown;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;
@property (nonatomic, retain) MBProgressHUD *hud;


@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;

@property (nonatomic, strong) IBOutlet UIView *photoModal;

@property (nonatomic, strong) IBOutlet UIView *editView;
@property (nonatomic, retain) IBOutlet BrandUITextField *tfFirstName;
@property (nonatomic, retain) IBOutlet BrandUITextField *tfLastName;
- (IBAction)tapSaveButton;

- (IBAction)tapBackButton;

- (IBAction)tapPhotoArea;
- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showModal;
- (void) hideModal;

@end
