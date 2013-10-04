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
#import "FancyTextView.h"

#import "BrandUITextField.h"

@interface ChatVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
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
    
}

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet BrandUILabel *navTitle;

@property (nonatomic, strong) IBOutlet UIView *chatBar;
@property (nonatomic, strong) IBOutlet UIButton *attachButton;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet FancyTextView *inputField;


- (IBAction)tapCancelButton;
- (IBAction)tapClearButton;
- (IBAction)tapAttachButton;
- (IBAction)tapSendButton;

- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showModal;
- (void) hideModal;


@end