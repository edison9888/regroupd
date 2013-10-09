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
#import "UIBubbleTableViewDataSource.h"
#import "FormSelectorVC.h"
//#import ""

#import "ChatManager.h"
#import "ChatVO.h"
#import "ChatMessageVO.h"
#import "FormVO.h"

@interface ChatVC : SlideViewController<UIBubbleTableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
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
    
    ChatManager *chatSvc;
    
    BOOL hasAttachment;
    int attachmentType;
    UIImage *attachedPhoto;
    NSString *formTitle;
}

@property (nonatomic, retain) NSMutableArray *bubbleData;

@property (nonatomic, retain) UIImagePickerController* imagePickerVC;
@property (nonatomic, retain) FormSelectorVC* formSelectorVC;

@property (nonatomic, retain) IBOutlet BrandUILabel *navTitle;
@property (nonatomic, strong) IBOutlet UIBubbleTableView *bubbleTable;

@property (nonatomic, strong) IBOutlet UIView *chatBar;
@property (nonatomic, strong) IBOutlet UIButton *attachButton;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet FancyTextView *inputField;

@property (nonatomic, strong) IBOutlet UIView *attachModal;
@property (nonatomic, strong) IBOutlet UIView *photoModal;

@property (nonatomic, strong) IBOutlet UIView *plusIconsView;
@property (nonatomic, retain) IBOutlet BrandUILabel *attachPhotoLabel;
@property (nonatomic, retain) IBOutlet BrandUILabel *attachPollLabel;
@property (nonatomic, retain) IBOutlet BrandUILabel *attachRatingLabel;
@property (nonatomic, retain) IBOutlet BrandUILabel *attachRSVPLabel;

@property (nonatomic, retain) IBOutlet UIImageView *attachPhotoIcon;
@property (nonatomic, retain) IBOutlet UIImageView *attachPollIcon;
@property (nonatomic, retain) IBOutlet UIImageView *attachRatingIcon;
@property (nonatomic, retain) IBOutlet UIImageView *attachRSVPIcon;

@property (nonatomic, strong) IBOutlet UIButton *attachPhotoHotspot;
@property (nonatomic, strong) IBOutlet UIButton *attachPollHotspot;
@property (nonatomic, strong) IBOutlet UIButton *attachRatingHotspot;
@property (nonatomic, strong) IBOutlet UIButton *attachRSVPHotspot;
@property (nonatomic, strong) IBOutlet UIButton *cancelHotspot;

@property (nonatomic, strong) IBOutlet UIButton *detachButton;


- (IBAction)tapCancelButton;
- (IBAction)tapClearButton;
- (IBAction)tapAttachButton;
- (IBAction)tapSendButton;
- (IBAction)tapDetachButton;

- (IBAction)modalCameraButton;
- (IBAction)modalChooseButton;
- (IBAction)modalCancelButton;

- (void) showAttachModal;
- (void) hideAttachModal;

- (void) showFormSelector;
- (void) hideFormSelector;

- (void) setupModalHotspots;


@end
