//
//  ProfileEdit2VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileEdit2VC.h"
#import "FaxManager.h"
#import "UserVO.h"

@interface ProfileEdit2VC ()

@end

@implementation ProfileEdit2VC

@synthesize tf1, tf2, tf3, tf4;
@synthesize pagedot1, pagedot2, pagedot3, pagedot4, pagedot5;
@synthesize nextButton, backButton;

static NSString *tf1_default = @"MEDICAL INSTITUTION";
static NSString *tf2_default = @"POSITION";
static NSString *tf3_default = @"PHONE NUMBER";
static NSString *tf4_default = @"FAX NUMBER";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileEdit2VC";
    
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
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    self.navCaption.text = qtyLeftCaption;

    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
   
    CGSize scrollContentSize = CGSizeMake(320, 520);
    self.scrollView.contentSize = scrollContentSize;
    
    self.tf1.delegate = self;
    self.tf2.delegate = self;
    self.tf3.delegate = self;
    self.tf4.delegate = self;
    self.scrollView.delegate = self;

    if ([DataModel shared].user.company != nil) {
        self.tf1.text = [DataModel shared].user.company;
    }
    if ([DataModel shared].user.title != nil) {
        self.tf2.text = [DataModel shared].user.title;
    }
    if ([DataModel shared].user.phone != nil) {
        self.tf3.text = [DataModel shared].user.phone;
    }
    if ([DataModel shared].user.fax != nil) {
        self.tf4.text = [DataModel shared].user.fax;
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
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    
    _currentField = textField;
    switch (textField.tag) {
        case 1:
            
            if ([textField.text isEqualToString:tf1_default]) {
                textField.text = nil;
            }
            break;
            
        case 2:
            if ([textField.text isEqualToString:tf2_default]) {
                textField.text = nil;
            }
            break;
            
        case 3:
            if ([textField.text isEqualToString:tf3_default]) {
                textField.text = nil;
            }
            break;
        case 4:
            if ([textField.text isEqualToString:tf4_default]) {
                textField.text = nil;
            }
            break;
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    [textField resignFirstResponder];
    [textField endEditing:YES];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"===== %s", __FUNCTION__);
    switch (textField.tag) {
        case 1:
            
            if ([textField.text length]==0) {
                textField.text = tf1_default;
            }
            return YES;
            break;
            
        case 2:
            if ([textField.text length]==0) {
                textField.text = tf2_default;
            }
            return YES;
            break;
            
        case 3:
            if ([textField.text length]==0) {
                textField.text = tf3_default;
            }
            return YES;
            break;
        case 4:
            if ([textField.text length]==0) {
                textField.text = tf4_default;
            }
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
    if (self.tf1.text.length == 0 || [self.tf1.text isEqualToString:tf1_default]) {
        isOk = NO;
    }
    if (self.tf2.text.length == 0 || [self.tf2.text isEqualToString:tf2_default]) {
        isOk = NO;
    }
    if (self.tf3.text.length == 0 || [self.tf3.text isEqualToString:tf3_default]) {
        isOk = NO;
    }
    if (self.tf4.text.length == 0 || [self.tf4.text isEqualToString:tf4_default]) {
        isOk = NO;
    }
    if (isOk) {
        [DataModel shared].user.company = self.tf1.text;
        [DataModel shared].user.title = self.tf2.text;
        [DataModel shared].user.phone = self.tf3.text;
        [DataModel shared].user.fax = self.tf4.text;
        
        [_delegate gotoNextSlide];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Please enter all the required information before proceeding to the next step." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)goBack
{
    // Save any partially completed data
    if (self.tf1.text.length > 0 && ![self.tf1.text isEqualToString:tf1_default]) {
        [DataModel shared].user.company = self.tf1.text;
    }
    if (self.tf2.text.length > 0 && ![self.tf2.text isEqualToString:tf2_default]) {
        [DataModel shared].user.title = self.tf2.text;
    }
    if (self.tf3.text.length > 0 && ![self.tf3.text isEqualToString:tf3_default]) {
        [DataModel shared].user.phone = self.tf3.text;
    }
    if (self.tf4.text.length > 0 && ![self.tf4.text isEqualToString:tf4_default]) {
        [DataModel shared].user.fax = self.tf4.text;
    }
    [_delegate gotoPreviousSlide];
    
}

- (IBAction)tapCancelButton {
    [_delegate gotoSlideWithName:@"ProfileHome" andOverrideTransition:kPresentationTransitionFade];
}
- (IBAction)tapDoneButton {
    BOOL isOk = YES;
    if (self.tf1.text.length == 0 || [self.tf1.text isEqualToString:tf1_default]) {
        isOk = NO;
    }
    if (self.tf2.text.length == 0 || [self.tf2.text isEqualToString:tf2_default]) {
        isOk = NO;
    }
    if (self.tf3.text.length == 0 || [self.tf3.text isEqualToString:tf3_default]) {
        isOk = NO;
    }
    if (self.tf4.text.length == 0 || [self.tf4.text isEqualToString:tf4_default]) {
        isOk = NO;
    }
    if (isOk) {
        [DataModel shared].user.company = self.tf1.text;
        [DataModel shared].user.title = self.tf2.text;
        [DataModel shared].user.phone = self.tf3.text;
        [DataModel shared].user.fax = self.tf4.text;

        // UPDATE DB
        
        [_delegate gotoSlideWithName:@"ProfileHome" andOverrideTransition:kPresentationTransitionFade];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Please enter all the required information before proceeding to the next step." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

}


@end
