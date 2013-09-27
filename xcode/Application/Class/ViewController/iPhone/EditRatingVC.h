//
//  EditRatingVC.h
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "SlideViewController.h"
#import "FancyCheckbox.h" 
#import "FancyTextField.h"
#import "BrandUITextField.h"
#import "SurveyOptionWidget.h"
#import "ExpandingTextView.h"
#import "FancyTextView.h"

@interface EditRatingVC : SlideViewController<UIScrollViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    int optionIndex;
    ExpandingTextView *expInput;
    FancyTextView *fancyInput;
    CGPoint  offset; // unused
    UIResponder *_currentFocus;
    
    BOOL keyboardIsShown;
    float keyboardHeight;
    float navbarHeight;
    NSMutableArray *surveyOptions;
    UIView *bgLayer;
    
    float inputHeight;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lowerForm;

@property (nonatomic, retain) IBOutlet BrandUITextField *subjectField;

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
