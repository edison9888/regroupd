//
//  ProfileEdit4VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"
#import "SignatureView.h"
#import "UserManager.h"

@interface ProfileEdit4VC : SlideViewController<UIAlertViewDelegate>
{
    IBOutlet UIImageView *pagedot1;
    IBOutlet UIImageView *pagedot2;
    IBOutlet UIImageView *pagedot3;
    IBOutlet UIImageView *pagedot4;
    IBOutlet UIImageView *pagedot5;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *signatureZone;
    
    IBOutlet UILabel *label1;
    
    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
    
    UserManager *userSvc;
    
}

@property (nonatomic, retain) SignatureView *signatureView;

@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIImageView *pagedot1;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot2;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot3;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot4;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot5;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) IBOutlet UILabel *label1;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *signatureZone;



- (IBAction)tapCancelButton;
- (IBAction)tapDoneButton;

- (IBAction)tapSignatureZone;

- (IBAction)goBack;
- (IBAction)goNext;

- (void) saveSignatureImage;

@end
