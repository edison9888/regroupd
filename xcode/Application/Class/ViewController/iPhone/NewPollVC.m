//
//  NewPollVC.m
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "NewPollVC.h"

@interface NewPollVC ()

@end

@implementation NewPollVC

#define kTagPublic     101
#define kTagPrivate    102
#define kTagMultipleYes   103
#define kTagMultipleNo    104

#define kFirstOptionId  1


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

    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];

    // scrollview setup
    navbarHeight = 0;
    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, [DataModel shared].stageHeight - 60);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.delegate = self;
    
    SurveyOptionWithPic *surveyOption;
    
    // Add survey options
    int ypos = 120;
    int count = 0;
    surveyOptions = [[NSMutableArray alloc] init];

    CGRect optionFrame;
    NSString *defaultText = @"Option %@";
    
    count++;
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
//    surveyOption.input.placeholder = [NSString stringWithFormat:defaultText, [NSNumber numberWithInt:count].stringValue];
    surveyOption.tag = count;
    surveyOption.index = count;

    [self.scrollView addSubview:surveyOption];
    [surveyOptions addObject:surveyOption];
    
    count++;
    ypos += 60;
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
    surveyOption.input.placeholder = [NSString stringWithFormat:defaultText, [NSNumber numberWithInt:count].stringValue];
    surveyOption.tag = count;
    surveyOption.index = count;
    
    [self.scrollView addSubview:surveyOption];
    [surveyOptions addObject:surveyOption];
    
    count++;
    ypos += 60;
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
    surveyOption.input.placeholder = [NSString stringWithFormat:defaultText, [NSNumber numberWithInt:count].stringValue];
    surveyOption.tag = count;
    surveyOption.index = count;
    
    [self.scrollView addSubview:surveyOption];
    [surveyOptions addObject:surveyOption];

    CGRect lowerFrame = CGRectMake(0, ypos + 80, self.lowerForm.frame.size.width, self.lowerForm.frame.size.height);
    [self.lowerForm setFrame:lowerFrame];
    
    self.ckPublic.ckLabel.text = @"Public";
    self.ckPublic.tag = kTagPublic;
    [self.ckPublic unselected];
    
    self.ckPrivate.ckLabel.text = @"Private";
    self.ckPrivate.tag = kTagPrivate;
    [self.ckPrivate unselected];
    
    self.ckMultipleYes.ckLabel.text = @"Yes";
    self.ckMultipleYes.tag = kTagMultipleYes;
    [self.ckMultipleYes unselected];
    
    self.ckMultipleNo.ckLabel.text = @"No";
    self.ckMultipleNo.tag = kTagMultipleNo;
    [self.ckMultipleNo unselected];
    
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImagePickerNotificationHandler:)     name:@"showImagePickerNotification"            object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeImagePickerNotificationHandler:)     name:@"closeImagePickerNotification"            object:nil];
    
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
    keyboardIsShown = YES;
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

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        if (keyboardIsShown) {
            [_currentField resignFirstResponder];
            [_currentField endEditing:YES];
        } else {
            
            UIView* view = sender.view;
            CGPoint loc = [sender locationInView:view];
            UIView* subview = [view hitTest:loc withEvent:nil];
            NSLog(@"tag = %i", subview.tag);
            
            
            switch (subview.tag) {
                case kTagPublic:
                    [self.ckPublic selected];
                    [self.ckPrivate unselected];
                    
                    break;
                    
                case kTagPrivate:
                    [self.ckPublic unselected];
                    [self.ckPrivate selected];
                    break;
                    
                case kTagMultipleYes:
                    [self.ckMultipleYes selected];
                    [self.ckMultipleNo unselected];
                    break;
                    
                case kTagMultipleNo:
                    [self.ckMultipleYes unselected];
                    [self.ckMultipleNo selected];
                    break;
                case 666:
                    [self hideModal];
                    break;
                    
            }
            
            
            
        }
    }
}

#pragma mark - Modal

- (void) showModal {
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = 666;
    [self.view addSubview:bgLayer];
    
    
    // Setup photoModal
    
    CGRect modalFrame = self.photoModal.frame;
    int ypos = -modalFrame.size.height;
    int xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    self.photoModal.layer.zPosition = 99;
    self.photoModal.frame = modalFrame;
    [self.view addSubview:self.photoModal];
    

    ypos = ([DataModel shared].stageHeight - modalFrame.size.height) / 2;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.photoModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}

- (void) hideModal {
    
    CGRect modalFrame = self.photoModal.frame;
    float ypos = -modalFrame.size.height;
    modalFrame.origin.y = ypos;
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.photoModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                                                  
                     }];
    
    
}

- (IBAction)modalCameraButton {
    NSLog(@"%s", __FUNCTION__);
    [self hideModal];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (self.imagePickerVC == nil) {
            self.imagePickerVC = [[UIImagePickerController alloc] init];
            self.imagePickerVC.delegate = self;
        }
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
        
    } else {
        if (self.imagePickerVC == nil) {
            self.imagePickerVC = [[UIImagePickerController alloc] init];
            self.imagePickerVC.delegate = self;
        }
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
        
    }
    
}
- (IBAction)modalChooseButton {
    NSLog(@"%s", __FUNCTION__);
    [self hideModal];
    if (self.imagePickerVC == nil) {
        self.imagePickerVC = [[UIImagePickerController alloc] init];
        self.imagePickerVC.delegate = self;
    }
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    
}
- (IBAction)modalCancelButton {
    [self hideModal];
}


#pragma mark - UIImagePicker methods


- (void)showImagePickerNotificationHandler:(NSNotification*)notification
{
    NSNumber *index = (NSNumber *) [notification object];
    photoIndex = index.intValue;
    
    NSLog(@"%s for index %i", __FUNCTION__, photoIndex);
    [self showModal];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)Picker {
    NSLog(@"%s", __FUNCTION__);
	[self dismissViewControllerAnimated:YES completion:nil];
    
    self.imagePickerVC = nil;
}

- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s", __FUNCTION__);
	UIImage *tmpImage = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    SurveyOptionWithPic *currentOption = [surveyOptions objectAtIndex:photoIndex - 1];
    
    [currentOption setPhoto:tmpImage];
//    currentOption.roundPic.image = tmpImage;
    
    // NSLog(@"downsizing image");
//    if (photoView == nil) {
//        photoView = [[UIImageView alloc] initWithFrame:previewFrame];
//        photoView.clipsToBounds = YES;
//        photoView.contentMode = UIViewContentModeScaleAspectFill;
//        
//        [self.view addSubview:photoView];
//    }
//    photoView.image = tmpImage;
    
	[self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerVC = nil;
//    [self setupButtonsForEdit];
    
}


@end
