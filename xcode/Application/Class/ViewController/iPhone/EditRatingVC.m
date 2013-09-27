//
//  EditRatingVC.m
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "EditRatingVC.h"
#import "FormManager.h"
#import "FormVO.h"
#import "FormOptionVO.h"

@interface EditRatingVC ()

@end

@implementation EditRatingVC

#define kTagPublic     101
#define kTagPrivate    102
#define kInputFieldInterval 65

#define kFirstOptionId  1
#define kMinInputHeight 40
#define kMaxInputHeight 120


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
    navbarHeight = 50;
    inputHeight = 0;
    
    CGRect scrollFrame = CGRectMake(0, navbarHeight,[DataModel shared].stageWidth, [DataModel shared].stageHeight - navbarHeight);
    self.scrollView.frame = scrollFrame;
    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, 600);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.delegate = self;
    
//    SurveyOptionWidget *surveyOption;
    
    // Add survey options
    int ypos = 120;
    int count = 0;
    surveyOptions = [[NSMutableArray alloc] init];

    CGRect optionFrame;
    NSString *placeholderFmt = @"Option %@";
    NSString *defaultText;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterSpellOutStyle];
    
    // OPTION 1 INPUT
    count++;
    defaultText = [NSString stringWithFormat:placeholderFmt, [formatter stringFromNumber:[NSNumber numberWithInt: count]]];
    optionFrame= CGRectMake(10, ypos, 236, kMinInputHeight);
    
    fancyInput = [[FancyTextView alloc] initWithFrame:optionFrame];
    //set the parent view
    fancyInput.delegate = self;
    fancyInput.tag = count;
    [fancyInput setNumLabel:@"3"];
    [fancyInput setPlaceholder:defaultText];
    
    [fancyInput scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    [self.scrollView addSubview:fancyInput];

//    expInput = [[ExpandingTextView alloc] initWithFrame:optionFrame];
//    //set the parent view
//    expInput.parentView = self.view;
//    expInput.delegate = self;
//    expInput.tag = count;
//    [expInput setPlaceholder:defaultText];
//    [self.scrollView addSubview:expInput];
    
    self.lowerForm.hidden = YES;
//    CGRect lowerFrame = CGRectMake(0, ypos + 80, self.lowerForm.frame.size.width, self.lowerForm.frame.size.height);
//    [self.lowerForm setFrame:lowerFrame];
//    
//    self.ckPublic.ckLabel.text = @"Public";
//    self.ckPublic.tag = kTagPublic;
//    [self.ckPublic unselected];
//    
//    self.ckPrivate.ckLabel.text = @"Private";
//    self.ckPrivate.tag = kTagPrivate;
//    [self.ckPrivate unselected];
    
    
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
    keyboardHeight = keyboardSize.height;
    
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
- (void) updateScrollView {
    NSLog(@"%s tag=%i", __FUNCTION__, optionIndex);
    
    if (optionIndex > 0 && optionIndex <= surveyOptions.count) {
        SurveyOptionWidget *currentOption = [surveyOptions objectAtIndex:optionIndex - 1];
        
        CGRect aRect = self.view.frame;
        
        aRect.size.height -= keyboardHeight;
        CGRect targetFrame = currentOption.frame;
        
        targetFrame.origin.y -= 40;
        
//        [self.scrollView setContentOffset:CGPointMake(0.0, currentOption.frame.origin.y-keyboardHeight) animated:YES];
        if (!CGRectContainsPoint(aRect, targetFrame.origin) ) {
            [self.scrollView scrollRectToVisible:targetFrame animated:YES];
        }
        
    }
    
}

#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"===== %s", __FUNCTION__);
    _currentFocus = textView;
    optionIndex = textView.tag;
    [self updateScrollView];
    
//    CGRect target = CGRectMake(textView.frame.origin.x,
//                               textView.frame.origin.y + 30,
//                               textView.frame.size.width,
//                               textView.frame.size.height);
//    
//    [self.scrollView scrollRectToVisible:target animated:YES];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"===== %s", __FUNCTION__);
    [_currentFocus resignFirstResponder];
    [textView endEditing:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
//    textView.bounds.size.height
    
    float newsize = fancyInput.contentSize.height;
    if (inputHeight != newsize ) {
        NSLog(@"textView height is now %f", newsize);
        inputHeight = newsize;
        if (inputHeight < kMaxInputHeight) {
            CGRect fancyFrame = CGRectMake(fancyInput.frame.origin.x,
                                           fancyInput.frame.origin.y,
                                           fancyInput.frame.size.width,
                                           inputHeight + 5);
            fancyInput.frame = fancyFrame;
            
        }
    }

    //    float newsize = expInput.contentSize.height;
//    if (inputHeight != newsize ) {
//        NSLog(@"textView height is now %f", newsize);
//        inputHeight = newsize;
//        if (inputHeight < kMaxInputHeight) {
//            CGRect expFrame = CGRectMake(expInput.frame.origin.x,
//                                          expInput.frame.origin.y,
//                                          expInput.frame.size.width,
//                                          inputHeight + 5);
//            expInput.frame = expFrame;
//            
//        }
//    }
    
}

//
//#pragma mark - UITextField methods
//
//-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
//    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
//    keyboardIsShown = YES;
//    
//    
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
//        
//    return YES;
//}
//
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    //    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    
//    return YES;
//}
//

#pragma mark - Tap Gestures 

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        if (keyboardIsShown) {
            [_currentFocus resignFirstResponder];
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
    float ypos = -modalFrame.size.height - 40;
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

- (IBAction)tapCancelButton {
    [_delegate gotoSlideWithName:@"FormsHome"];
}
- (IBAction)tapDoneButton {
    NSLog(@"%s", __FUNCTION__);

    BOOL isOK = YES;
    
    if (self.subjectField.text.length == 0) {
        isOK = NO;
    }

    NSMutableArray *formOptions = [[NSMutableArray alloc] init];
    FormOptionVO *option;
    for (SurveyOptionWidget* surveyOption in surveyOptions) {
        if (surveyOption.input.text.length == 0) {
            NSLog(@"Empty field: %i", surveyOption.index);
            isOK = NO;
        } else {
            option = [[FormOptionVO alloc] init];
            option.name = surveyOption.input.text;
            option.type = OptionType_TEXT;
            option.status = OptionStatus_DRAFT;
            [formOptions addObject:option];
        }
    }

    if (isOK) {
        FormManager *formSvc = [[FormManager alloc] init];
        FormVO *form = [[FormVO alloc] init];
        
        form.system_id = @"";
        
        form.name = self.subjectField.text;
        form.type = FormType_RATING;
        form.status = FormStatus_DRAFT;
        
        int formId = [formSvc saveForm:form];
        if (formId > 0) {
            NSLog(@"Form saved with form_id %i", formId);
            
            for (FormOptionVO *formOption in formOptions) {
                formOption.form_id = formId;
                [formSvc saveOption:formOption];
            }
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Survey created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } else {
        NSLog(@"Data fields not complete");
        
    }


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

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}

#pragma mark - UIImagePicker methods


- (void)showImagePickerNotificationHandler:(NSNotification*)notification
{
    NSNumber *index = (NSNumber *) [notification object];
    optionIndex = index.intValue;
    
    NSLog(@"%s for index %i", __FUNCTION__, optionIndex);
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
    
    SurveyOptionWidget *currentOption = [surveyOptions objectAtIndex:optionIndex - 1];
    
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