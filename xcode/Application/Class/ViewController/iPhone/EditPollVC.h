//
//  NewPollVC.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "SlideViewController.h"

#import "MBProgressHUD.h"

#import "FancyCheckbox.h" 
#import "FancyTextField.h"

#import "BrandUITextField.h"
#import "SurveyOptionWithPic.h"

@interface EditPollVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    int optionIndex;
    
    CGPoint  offset; // unused
    
    UITextField *_currentField;
    BOOL keyboardIsShown;
    float keyboardHeight;
    float navbarHeight;
    NSMutableArray *surveyOptions;
    UIView *bgLayer;
}

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lowerForm;

@property (nonatomic, retain) IBOutlet FancyTextField *subjectField;

@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPublic;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPrivate;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleYes;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleNo;

@property (nonatomic, strong) IBOutlet UIView *photoModal;

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;

- (IBAction)tapCancelButton;
- (IBAction)tapDoneButton;

- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showModal;
- (void) hideModal;


@end
