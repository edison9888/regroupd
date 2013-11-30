//
//  NewPollVC.m
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "EditPollVC.h"
#import "FormManager.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "UIAlertView+Helper.h"
#import "UIImage+Resize.h"

@interface EditPollVC ()

@end

@implementation EditPollVC

#define kTagPublic     101
#define kTagPrivate    102
#define kTagMultipleYes   103
#define kTagMultipleNo    104
#define kInputFieldInterval 65

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
    navbarHeight = 50;
    
    CGRect scrollFrame = CGRectMake(0, navbarHeight,[DataModel shared].stageWidth, [DataModel shared].stageHeight - navbarHeight);
    self.scrollView.frame = scrollFrame;
    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, 700);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.delegate = self;
    
    SurveyOptionWithPic *surveyOption;
    
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
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
    surveyOption.tag = count;
    surveyOption.index = count;
    surveyOption.input.placeholder = defaultText;
    surveyOption.input.defaultText = defaultText;
    surveyOption.input.returnKeyType = UIReturnKeyNext;
    surveyOption.input.tag = count;
    surveyOption.input.delegate = self;
    [self.scrollView addSubview:surveyOption];
    [surveyOptions addObject:surveyOption];
    
    // OPTION 2 INPUT
    count++;
    ypos += kInputFieldInterval;
    defaultText = [NSString stringWithFormat:placeholderFmt, [formatter stringFromNumber:[NSNumber numberWithInt: count]]];
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
    surveyOption.tag = count;
    surveyOption.index = count;
    surveyOption.input.placeholder = defaultText;
    surveyOption.input.defaultText = defaultText;
    surveyOption.input.returnKeyType = UIReturnKeyNext;
    surveyOption.input.tag = count;
    surveyOption.input.delegate = self;

    [self.scrollView addSubview:surveyOption];
    [surveyOptions addObject:surveyOption];
    
    // OPTION 3 INPUT
    count++;
    ypos += kInputFieldInterval;
    defaultText = [NSString stringWithFormat:placeholderFmt, [formatter stringFromNumber:[NSNumber numberWithInt: count]]];
    optionFrame= CGRectMake(0, ypos, [DataModel shared].stageWidth, 60);
    surveyOption = [[SurveyOptionWithPic alloc] initWithFrame:optionFrame];
    surveyOption.fieldLabel.text = [NSNumber numberWithInt:count].stringValue;
    surveyOption.tag = count;
    surveyOption.index = count;
    surveyOption.input.placeholder = defaultText;
    surveyOption.input.defaultText = defaultText;
    surveyOption.input.returnKeyType = UIReturnKeyNext;
    surveyOption.input.tag = count;
    surveyOption.input.delegate = self;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pollSaveCompleteNotificationHandler:)     name:k_pollSaveCompleteNotification            object:nil];
    
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


#pragma mark - Notification Handlers

- (void)pollSaveCompleteNotificationHandler:(NSNotification*)notification
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSLog(@"===== %s", __FUNCTION__);
    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Poll created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - Keyboard event handlers

/*
 SEE: http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present/2703756#2703756
 */
- (void)keyboardWillHide:(NSNotification *)n
{
    NSLog(@"===== %s", __FUNCTION__);
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self hideKeyboard:keyboardSize];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    NSLog(@"===== %s", __FUNCTION__);
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
    viewFrame.size.height = [DataModel shared].stageHeight - 50;
    
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
        SurveyOptionWithPic *currentOption = [surveyOptions objectAtIndex:optionIndex - 1];
        
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

#pragma mark - UITextField methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    keyboardIsShown = YES;
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    
    // Get next field
    if (textField.tag < surveyOptions.count) {
        SurveyOptionWithPic *currentOption = [surveyOptions objectAtIndex:textField.tag];
        [currentOption.input becomeFirstResponder];

        optionIndex = textField.tag + 1;
        [self updateScrollView];
        
    } else {
        NSLog(@"Last field");
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _currentField = textField;
    optionIndex = textField.tag;
    [self updateScrollView];
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
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
    [self becomeFirstResponder];
    
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

    for (SurveyOptionWithPic* surveyOption in surveyOptions) {
        if (surveyOption.input.text.length == 0) {
            NSLog(@"Empty field: %i", surveyOption.index);
            isOK = NO;
        }
    }

    if (isOK) {
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.hud setLabelText:@"Saving"];

        FormManager *formSvc = [[FormManager alloc] init];
        
        NSString *filename_fmt = @"form_%@-%i_photo.png";

        FormVO *form = [[FormVO alloc] init];
        
        form.system_id = @"";
        
        form.name = self.subjectField.text;
        form.type = FormType_POLL;
        form.status = FormStatus_DRAFT;
        
        __block NSString *imagefile;
        [formSvc apiSaveForm:form callback:^(PFObject *pfForm) {
            NSString *formId = pfForm.objectId;
            int total = surveyOptions.count;
            __block int index = 1;
            for (SurveyOptionWithPic* surveyOption in surveyOptions) {
                FormOptionVO *option;
                
                option = [[FormOptionVO alloc] init];
                
                if (surveyOption.roundPic.image != nil) {
                    imagefile = [NSString stringWithFormat:filename_fmt, formId, index];
                    option.photo = surveyOption.roundPic.image;
                    option.imagefile = imagefile;
                } else {
                    option.photo = nil;
                    option.imagefile = nil;
                }
                
                option.name = surveyOption.input.text;
                option.type = OptionType_TEXT;
                option.status = OptionStatus_DRAFT;
                option.position = index;
                [formSvc apiSaveFormOption:option formId:formId callback:^(PFObject *object) {
                    index++;
                    NSLog(@"Save option %i", index);
                    if (index > total) {
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_pollSaveCompleteNotification object:nil]];
                    }
                    
                }];
            }
            
            
        }];
        
//        int formId = [formSvc saveForm:form];
//        if (formId > 0) {
//            NSLog(@"Form saved with form_id %i", formId);
//
//            for (SurveyOptionWithPic* surveyOption in surveyOptions) {
//                
//                lastId += 1;
//                if (surveyOption.roundPic.image != nil) {
//                    imagefile = [NSString stringWithFormat:filename_fmt, formId, lastId];
//                    [formSvc saveFormImage:surveyOption.roundPic.image withName:imagefile];
//                } else {
//                    imagefile = nil;
//                }
//                
//                option = [[FormOptionVO alloc] init];
//                option.name = surveyOption.input.text;
//                option.form_id = formId;
//                option.type = OptionType_TEXT;
//                option.status = OptionStatus_DRAFT;
//                option.imagefile = imagefile;
//                [formSvc saveOption:option];
//                
//            }
//
//            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Survey created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//        
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
    CGSize resize;
    
    resize = CGSizeMake(kMinimumImageDimension, kMinimumImageDimension);
    
    UIImage *resizeImage = [tmpImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:resize interpolationQuality:kCGInterpolationMedium];
    
    tmpImage = nil;
    
    SurveyOptionWithPic *currentOption = [surveyOptions objectAtIndex:optionIndex - 1];
    
    [currentOption setPhoto:resizeImage];
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
