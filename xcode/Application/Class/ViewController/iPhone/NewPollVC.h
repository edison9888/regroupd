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
#import "SurveyOptionWithPic.h"

@interface NewPollVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    int photoIndex;
    
    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
    NSMutableArray *surveyOptions;
    UIView *bgLayer;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lowerForm;

@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPublic;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPrivate;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleYes;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleNo;

@property (nonatomic, strong) IBOutlet UIView *photoModal;

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;

- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showModal;
- (void) hideModal;


@end
