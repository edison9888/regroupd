//
//  FaxAgainVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import "FaxAgainVC.h"
#import "MBProgressHUD.h"
#import "EFaxService.h"
#import "OutboundRequest.h"
#import "FaxTemplateView.h"
#import "DateTimeUtils.h"
#import "UserManager.h"
#import "SQLiteDB.h"

@interface FaxAgainVC () {
    FaxTemplateView *faxTemplate;
}

@end

@implementation FaxAgainVC

@synthesize backButton, nextButton;
@synthesize sendButton;

static NSString *tf2_default = @"physician's orders";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    faxSvc = [[FaxManager alloc] init];
    
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    
    self.navTitle.text = [DataModel shared].faxlog.patient_name;
    self.navCaption.text = qtyLeftCaption;

    self.tf2.delegate = self;
    
    self.scrollView.delegate = self;

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    // Create and initialize a tap gesture
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapRecognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faxSuccessNotificationHandler:)
                                                 name:@"faxSuccessNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faxFailureNotificationHandler:)
                                                 name:@"faxFailureNotification"
                                               object:nil];

    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Keyboard event handlers

/*
 SEE: http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present/2703756#2703756
 */
- (void)keyboardWillHide:(NSNotification *)n
{
#ifdef kDEBUG
    NSLog(@"===== %s", __FUNCTION__);
#endif
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self hideKeyboard:keyboardSize];
}

- (void)keyboardWillShow:(NSNotification *)n
{
#ifdef kDEBUG
    NSLog(@"===== %s", __FUNCTION__);
#endif
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self showKeyboard:keyboardSize];
    
}
- (void) showKeyboard:(CGSize)keyboardSize
{
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= (keyboardSize.height - navbarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
    
}
- (void) hideKeyboard:(CGSize)keyboardSize
{
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += (keyboardSize.height - navbarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
    
}


#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
#ifdef kDEBUG
    // NSLog(@"===== %s", __FUNCTION__);
#endif
    _currentFocus = textView;

    switch (textView.tag) {
        case 2:
            if ([textView.text isEqualToString:tf2_default]) {
                [textView setText:@""];
            }
            textView.textColor = [UIColor blackColor];
            break;
    }
    
    CGRect target = CGRectMake(textView.frame.origin.x,
                               textView.frame.origin.y + 30,
                               textView.frame.size.width,
                               textView.frame.size.height);
    
    [self.scrollView scrollRectToVisible:target animated:YES];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    switch (textView.tag) {
        case 2:
            if (textView.text.length == 0) {
                [textView setText:tf2_default];
                textView.textColor = [UIColor whiteColor];
            }
            break;
    }
    
    [_currentFocus resignFirstResponder];
    [textView endEditing:YES];
    
    
}



#pragma mark - Tap Gestures

-(void)singleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        if (keyboardIsShown) {
            [_currentFocus resignFirstResponder];
            
            
        }
    }
}

#pragma mark - Action handlers

- (IBAction)goBack
{
    [_delegate gotoPreviousSlide];
    
}

- (IBAction)tapSend
{
    NSLog(@"%s", __FUNCTION__);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self saveFaxLog:nil];
    [self renderFax];
    [self buildAndSendFax];
    
}
// Temporary action
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    [_delegate gotoSlideWithName:@"RecentHome" andOverrideTransition:kPresentationTransitionFade];
    [DataModel shared].navIndex = 1;
    
    // post notification to switch to new tab (in ViewController)
    NSNotification* switchNavNotification = [NSNotification notificationWithName:@"switchNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:switchNavNotification];

}
- (void) renderFax
{
    
    //    CGRect offscreenFrame = CGRectMake([DataModel shared].stageWidth + 10, 0, 600, 800);
    
    CGRect offscreenFrame = CGRectMake(0, 0, 600, 800);
    CGRect scrollFrame = CGRectMake([DataModel shared].stageWidth + 10, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    
    faxTemplate = [[FaxTemplateView alloc] initWithFrame:offscreenFrame];
    
    UIScrollView *imageScroller = [[UIScrollView alloc] initWithFrame:scrollFrame];
    imageScroller.contentSize = offscreenFrame.size;
    [self.view addSubview:imageScroller];
    [imageScroller addSubview:faxTemplate];
    //    [self.view addSubview:faxTemplate];
    
    faxTemplate.patient.text = [DataModel shared].faxlog.patient_name;
    
    faxTemplate.orderText.text = self.tf2.text;
    NSDate *now = [NSDate date];
    NSString *datetext = [[DateTimeUtils getShortDateFormatter] stringFromDate:now];
    faxTemplate.orderDate.text = datetext;
    
    faxTemplate.rcptName.text = [DataModel shared].contact.name;
    faxTemplate.rcptPhone.text = [DataModel shared].contact.phone;
    faxTemplate.rcptFax.text = [DataModel shared].contact.fax;
    
    faxTemplate.senderName.text = [[DataModel shared].user getFullname];
    faxTemplate.senderPhone.text = [DataModel shared].user.phone;
    faxTemplate.senderFax.text = [DataModel shared].user.fax;
    faxTemplate.company.text = [DataModel shared].user.company;
    faxTemplate.street.text = [DataModel shared].user.address;
    faxTemplate.city.text = [DataModel shared].user.city;
    faxTemplate.state.text = [DataModel shared].user.state;
    faxTemplate.zip.text = [DataModel shared].user.phone;
    
    UserManager *userSvc = [[UserManager alloc] init];
    UIImage *sigImage = [userSvc loadSignature:@"sig_1.png"];
    if (sigImage != nil) {
        faxTemplate.signatureBox.image = sigImage;
    }
    
    //    CGRect rect = [faxTemplate bounds];
    UIGraphicsBeginImageContextWithOptions(offscreenFrame.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [faxTemplate.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    NSData* data = UIImagePNGRepresentation(image);
    
    imageEncoded = [QSStrings encodeBase64WithData:data];

}
- (void) buildAndSendFax
{

    
    if (imageEncoded != nil) {
        OutboundRequest *outboundRequest = [[OutboundRequest alloc] init];
        
        outboundRequest.faxHeader = @"@DATE1 @TIME3 @ROUTETO{26} @RCVRFAX Pg%P/@TPAGES";
        outboundRequest.dispositionEmail = [DataModel shared].user.email;
        outboundRequest.dispositionName = [DataModel shared].user.firstname;
        outboundRequest.recipientName = [DataModel shared].contact.name;
        outboundRequest.recipientFax = [DataModel shared].contact.fax;
        
        File *file = [[File alloc] init];
        file.fileType = @"png";
        file.fileContents = imageEncoded;
        outboundRequest.file = file;
        

        EFaxService *efaxService = [[EFaxService alloc] init];
        
        [efaxService callWebService:outboundRequest];
        
    } else {
        NSLog(@"ERROR>>>>>>>>>>>> imageEncoded is nil!");
    }
}

- (void) saveFaxLog:(NSString *)efaxID
{
    NSLog(@"%s", __FUNCTION__);
    account = [faxSvc loadCurrentAccount:[DataModel shared].user.userId];
    
    
    @try {
        if (account != nil) {
            
            faxlog = [[FaxLogVO alloc] init];
            faxlog.contact_id = [DataModel shared].contact.contactId;
            faxlog.user_id = [DataModel shared].user.userId;
            faxlog.account_id = account.account_id;
            faxlog.fax = [DataModel shared].contact.fax;
            faxlog.patient_name = [DataModel shared].faxlog.patient_name;
            faxlog.message = self.tf2.text;
            faxlog.type = 1;
            faxlog.status = 0;
            faxlog.efax_id = @"";
            [faxSvc createFaxLog:faxlog];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR>>>>>>>>>>>> %@", exception);
    }
}

- (void) handleSuccess:(NSString *)efaxID {
    
    FaxLogVO *lastlog = [faxSvc selectLastLog:[DataModel shared].user.userId];
    
    if (lastlog != nil) {
        lastlog.efax_id = efaxID;
        lastlog.status = 1;
        
        [faxSvc updateFaxLog:lastlog];
        account.qty_left = account.qty_left - 1;
        account.qty_used = account.qty_used + 1;
        [faxSvc updateAccountBalance:account];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Fax sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        
    }
    
}


#pragma mark - Notification handlers
- (void)faxSuccessNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *efaxID = (NSString *) notification.object;
    
    [self handleSuccess:efaxID];
    
    
    
}
- (void)faxFailureNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Fax was not sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    
    
}


@end
