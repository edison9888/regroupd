//
//  EditContactVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import "EditContactVC.h"
#import "FaxManager.h"

@interface EditContactVC ()

@end

@implementation EditContactVC

static NSString *tf1_default = @"RECIPIENT'S NAME";
static NSString *tf2_default = @"PHONE NUMBER";
static NSString *tf3_default = @"FAX NUMBER";

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
    
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    self.navCaption.text = qtyLeftCaption;
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    self.tf1.delegate = self;
    self.tf2.delegate = self;
    self.tf3.delegate = self;
    self.scrollView.delegate = self;
    
    self.tf2.keyboardType = UIKeyboardTypePhonePad;
    self.tf3.keyboardType = UIKeyboardTypeNumberPad;
    
    NSLog(@"Action %@", [DataModel shared].action);
    if ([[DataModel shared].action isEqualToString:kActionADD]) {
        self.navTitle.text = @"New Contact";
    } else if ([[DataModel shared].action isEqualToString:kActionEDIT]) {
        self.navTitle.text = @"Edit Contact";
        
        self.tf1.text = [[DataModel shared].contactData objectForKey:@"name"];
        self.tf2.text = [[DataModel shared].contactData objectForKey:@"phone"];
        self.tf3.text = [[DataModel shared].contactData objectForKey:@"fax"];
        
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
    NSLog(@"===== %s", __FUNCTION__);
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
            
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}


#pragma mark - Touch Handler

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
    if (isOk) {
        NSLog(@"%s", __FUNCTION__);
        
        if ([[DataModel shared].action isEqualToString:kActionADD]) {
            //  Save data and go back
            [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                NSString *insertSql = @"insert into contact (name, phone, fax) VALUES (?, ?, ?);";
                BOOL success = [db executeUpdate:insertSql,
                                self.tf1.text,
                                self.tf2.text,
                                self.tf3.text
                                ];
                
                if (!success) {
                    NSLog(@"######## SQL Insert failed ###################################");
                } else {
                    NSLog(@"======== SQL INSERT SUCCESS ===================================");
                }
            }];
            // trigger refresh in previous slide
            [_delegate gotoPreviousSlide];
        } else if ([[DataModel shared].action isEqualToString:kActionEDIT]) {
            [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                NSString *key = (NSString *)[[DataModel shared].contactData objectForKey:@"id"];
                NSNumber *contactId = [NSNumber numberWithInt:key.integerValue];
                
                NSString *updateSql = @"update contact set name=?, phone=?, fax=? where id=?;";
                BOOL success = [db executeUpdate:updateSql,
                                self.tf1.text,
                                self.tf2.text,
                                self.tf3.text,
                                contactId
                                ];
                
                if (!success) {
                    NSLog(@"######## SQL Update failed ###################################");
                } else {
                    NSLog(@"======== SQL UPDATE SUCCESS ===================================");
                }
            }];
            // trigger refresh in previous slide
            [_delegate gotoPreviousSlide];
            
        }
    }
    
    
}

- (IBAction)goBack
{
    [_delegate gotoPreviousSlide];
    
}

- (IBAction)tapSendButton
{
    
}

@end
