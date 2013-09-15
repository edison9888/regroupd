//
//  NewFaxEdit1VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"
#import "FaxManager.h"
#import "FaxAccountVO.h"

@interface NewFaxEdit1VC : SlideViewController<UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate> {
    UIResponder *_currentFocus;
    BOOL keyboardIsShown;
    int navbarHeight;
    NSString *imageEncoded;
    FaxManager *faxSvc;
    FaxAccountVO *account;
    FaxLogVO *faxlog;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet UITextView *tf2;

@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)goBack;
- (IBAction)goNext;

- (IBAction)tapSend;

- (void) renderFax;
- (void) buildAndSendFax;
- (void) saveFaxLog:(NSString *)efaxID;
- (void) handleSuccess:(NSString *)efaxID;

@end
