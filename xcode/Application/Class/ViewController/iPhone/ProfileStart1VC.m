//
//  ProfileStart1VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileStart1VC.h"
#import "UserVO.h"
#import "NBPhoneNumberUtil.h"
#import "ContactManager.h"
#import "UserManager.h"

@interface ProfileStart1VC ()

@end

@implementation ProfileStart1VC

@synthesize tf1;
@synthesize nextButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileStart1VC";

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        navbarHeight = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, 400);
    self.scrollView.delegate = self;
    self.scrollView.contentSize = scrollContentSize;

    self.tf1.delegate = self;
    self.tf1.textAlignment = NSTextAlignmentCenter;
    
    self.scrollView.delegate = self;
    [self.tf1 setKeyboardType:UIKeyboardTypePhonePad];
    
    if ([DataModel shared].user != nil) {
        if ([DataModel shared].user.first_name != nil) {
            self.tf1.text = [DataModel shared].user.phone;
        }
    }
    
    CGRect viewframe = self.view.frame;
    NSLog(@"viewframe ypos = %f", viewframe.origin.y);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
    } else {
        viewframe.origin.y=0;
        self.view.frame = viewframe;
        
    }

    
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
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    viewFrame.size.height = [DataModel shared].stageHeight - keyboardSize.height - viewFrame.origin.y;
    
    CGRect targetFrame = self.nextButton.frame;
    targetFrame.origin.y += 20;
    [self.scrollView setFrame:viewFrame];
    [self.scrollView scrollRectToVisible:targetFrame animated:YES];
    keyboardIsShown = YES;
    
}
- (void) hideKeyboard:(CGSize)keyboardSize
{
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height = [DataModel shared].stageHeight - viewFrame.origin.y;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
    
}

#pragma mark - UITextField methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentField = textField;

    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"===== %s", __FUNCTION__);
    switch (textField.tag) {
        case 1:
            return YES;
            break;
                        
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return YES;
}

#pragma mark - Tap Gestures

-(void)singleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        if (keyboardIsShown) {
            [_currentField resignFirstResponder];
            [_currentField endEditing:YES];
        }
    }
}


#pragma mark - Action handlers

- (IBAction)goNext
{
    BOOL isOk = YES;
    if (self.tf1.text.length == 0) {
        isOk = NO;
    }
    if (isOk) {
        
        ContactManager *contactSvc = [[ContactManager alloc] init];
        UserManager *userSvc = [[UserManager alloc] init];
        
        NSString *phoneId = [contactSvc formatPhoneNumberAsE164:self.tf1.text];
        
//        [self readPhoneNumber:self.tf1.text];
        UserVO *user = [[UserVO alloc] init];
        user.phone = phoneId;
        user.username = phoneId;
        [DataModel shared].user = user;

        // TODO: Add country code and normalize
        NSLog(@"phoneId is %@", phoneId);

        [_delegate gotoNextSlide];
        
//        [contactSvc apiSendSMSInviteCode:phoneId callback:^(NSString *code) {
//            NSLog(@"apiSendSMSInviteCode code = %@", code);
//            if (code) {
//                user.password = code;
//                [DataModel shared].user = user;
//                
//                [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"A text message was sent to your phone with a 6-digit verification code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
////                [userSvc apiCreateUser:user callback:^(PFObject *pfUser) {
////                    if (pfUser) {
////                        NSLog(@"Created user with objectId %@", pfUser.objectId);
////                        user.system_id = pfUser.objectId;
////                        
////                        [DataModel shared].user = user;
////                        
////                        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"A text message was sent to your phone with a 6-digit verification code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
////                    } else {
////                        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Unable to create user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
////                        
////                    }
////                }];
//
//            } else {
//                [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Unable to send SMS code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                
//            }
//        }];
        
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Please enter a valid phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate gotoNextSlide];
}



- (NSString *) formatPhoneNumberAsE164:(NSString *)phone {
    NSString *result = nil;
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *aError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phone defaultRegion:@"US" error:&aError];
    
    if (aError == nil) {
        // Should check error
        result = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164
                             error:&aError];
    }
    else {
        NSLog(@"Error : %@", [aError localizedDescription]);
    }
    return result;
    
}

- (void) readPhoneNumber:(NSString *)phone {
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *aError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phone defaultRegion:@"US" error:&aError];
    
    if (aError == nil) {
        // Should check error
        NSLog(@"isValidPhoneNumber ? [%@]", [phoneUtil isValidNumber:myNumber] ? @"YES":@"NO");
        NSLog(@"E164          : %@", [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164
                                                 error:&aError]);
        NSLog(@"INTERNATIONAL : %@", [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL
                                                 error:&aError]);
        NSLog(@"NATIONAL      : %@", [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatNATIONAL
                                                 error:&aError]);
        NSLog(@"RFC3966       : %@", [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatRFC3966
                                                 error:&aError]);
    }
    else {
        NSLog(@"Error : %@", [aError localizedDescription]);
    }
    
    NSLog (@"extractCountryCode [%ld]", [phoneUtil extractCountryCode:@"823213123123"
                                                       nationalNumber:nil]);
    
    NSString *res = nil;
    UInt32 dRes = [phoneUtil extractCountryCode:@"823213123123" nationalNumber:&res];
    
    NSLog (@"extractCountryCode [%lu] [%@]", dRes, res);
}


@end
