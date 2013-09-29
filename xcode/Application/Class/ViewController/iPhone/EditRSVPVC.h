//
//  NewPollVC.h
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "SlideViewController.h"
#import "FancyCheckbox.h" 
#import "FancyTextField.h"
#import "BrandUITextField.h"
#import "FancyDateTimeField.h"
#import "BSKeyboardControls.h"

@interface EditRSVPVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, BSKeyboardControlsDelegate> {
    int fieldIndex;
    
    CGPoint  offset; // unused
    UIResponder *_currentFocus;
    UITextField *_currentField;
    
    BOOL keyboardIsShown;
    float keyboardHeight;
    float navbarHeight;
    
    UIView *bgLayer;
    
    int allow_public;
    
}

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;
//@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
//@property (nonatomic, retain) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, retain) IBOutlet UIToolbar* doneToolbar;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIDatePicker *timePicker;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;



@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lowerForm;

@property (nonatomic, strong) IBOutlet UIView *photoHolder;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIButton *pickPhoto;

@property (nonatomic, retain) IBOutlet BrandUITextField *subjectField;
@property (nonatomic, retain) IBOutlet BrandUITextField *whereField;
@property (nonatomic, retain) IBOutlet BrandUITextField *descriptionField;

@property (nonatomic, retain) IBOutlet FancyDateTimeField *tfStartDate;
@property (nonatomic, retain) IBOutlet FancyDateTimeField *tfStartTime;
@property (nonatomic, retain) IBOutlet FancyDateTimeField *tfEndDate;
@property (nonatomic, retain) IBOutlet FancyDateTimeField *tfEndTime;

@property (nonatomic, retain) IBOutlet FancyCheckbox *ckAllowOthersYes;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckAllowOthersNo;

@property (nonatomic, strong) IBOutlet UIView *photoModal;

- (IBAction)tapCancelButton;
- (IBAction)tapDoneButton;

- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (IBAction)tapPickPhoto;
- (IBAction)dismissDatePicker:(id)sender;

- (void) setPhoto:(UIImage *)photo;

- (void) showModal;
- (void) hideModal;


@end
