//
//  EditRatingVC.h
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
#import "SurveyOptionWidget.h"
#import "FancyTextView.h"

@interface EditRatingVC : SlideViewController<UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    int optionIndex;
    FancyTextView *fancyInput;
    CGPoint  offset; // unused
    UIResponder *_currentFocus;

    int fieldIndex;

    BOOL keyboardIsShown;
    float keyboardHeight;
    float navbarHeight;
    NSMutableArray *surveyOptions;
    UIView *bgLayer;
    
    float inputHeight;
    NSArray *textViewTags;
    
}

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lowerForm;

@property (nonatomic, retain) IBOutlet FancyTextField *subjectField;

@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPublic;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPrivate;

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
