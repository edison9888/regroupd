//
//  NewPollVC.h
//  Re:group'd
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
#import "FormManager.h"

@interface EditRSVPVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, BSKeyboardControlsDelegate> {

    FormManager *formSvc;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;

    int fieldIndex;
    
    CGPoint  offset; // unused
    UIResponder *_currentFocus;
    UITextField *_currentField;
    
    BOOL keyboardIsShown;
    float keyboardHeight;
    float navbarHeight;
    
    UIView *bgLayer;
    
    int allow_public;
    
//    NEW SCROLLER
    CGFloat animatedDistance;
    UIImage *formImage;
    
    NSArray *fieldTags;
    BOOL canSave;
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

@property (nonatomic, strong) IBOutlet UIButton *doneButtonTop;
@property (nonatomic, strong) IBOutlet UIButton *doneButtonEnd;

@property (nonatomic, retain) IBOutlet FancyTextField *subjectField;
@property (nonatomic, retain) IBOutlet FancyTextField *whereField;
@property (nonatomic, retain) IBOutlet FancyTextField *descriptionField;

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
//- (IBAction)dismissDatePicker:(id)sender;

- (void) setPhoto:(UIImage *)photo;

- (void) showModal;
- (void) hideModal;


@end
