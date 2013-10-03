//
//  NewPollVC.m
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "EditRSVPVC.h"
#import "FormManager.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "UIAlertView+Helper.h"
#import "DateTimeUtils.h"
//#import "NSDate+Extensions.h"

@interface EditRSVPVC ()

@end

@implementation EditRSVPVC

#define kTagSubject     11
#define kTagLocation    12
#define kTagDescription 13

#define kTagStartDate       101
#define kTagStartTime       102
#define kTagEndDate         103
#define kTagEndTime         104

#define kTagAllowOthersYes   201
#define kTagAllowOthersNo    202

#define kFirstOptionId  1

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 260;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

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

    // photo thumbnail setup
    [self.roundPic.layer setCornerRadius:30.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:1.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    self.photoHolder.hidden = YES;

    // scrollview setup
    navbarHeight = 50;
    
    CGRect scrollFrame = CGRectMake(0, navbarHeight,[DataModel shared].stageWidth, [DataModel shared].stageHeight - navbarHeight);
    self.scrollView.frame = scrollFrame;
    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, 600);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.delegate = self;
    
    
    // Setup text fields
    
    self.subjectField.delegate = self;
    self.whereField.delegate = self;
    self.descriptionField.delegate = self;
    
    // Add survey options

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.timePicker = [[UIDatePicker alloc] init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    
    UIImage *icon_calendar = [UIImage imageNamed:@"icon_calendar_aqua"];
    UIImage *icon_clock = [UIImage imageNamed:@"icon_clock_aqua"];
            
    self.tfStartDate.tag = kTagStartDate;
    self.tfStartDate.text = @"";
    self.tfStartDate.inputView = self.datePicker;
    self.tfStartDate.delegate = self;
    [self.tfStartDate setIcon:icon_calendar];

    self.tfStartTime.tag = kTagStartTime;
    self.tfStartTime.text = @"";
    self.tfStartTime.inputView = self.timePicker;
    self.tfStartTime.delegate = self;
    [self.tfStartTime setIcon:icon_clock];

    self.tfEndDate.tag = kTagEndDate;
    self.tfEndDate.text = @"";
    self.tfEndDate.inputView = self.datePicker;
    self.tfEndDate.delegate = self;
    [self.tfEndDate setIcon:icon_calendar];
    
    self.tfEndTime.tag = kTagEndTime;
    self.tfEndTime.text = @"";
    self.tfEndTime.inputView = self.timePicker;
    self.tfEndTime.delegate = self;
    [self.tfEndTime setIcon:icon_clock];

    allow_public = -1;
    self.ckAllowOthersYes.ckLabel.text = @"Yes";
    self.ckAllowOthersYes.tag = kTagAllowOthersYes;
    [self.ckAllowOthersYes unselected];
    
    self.ckAllowOthersNo.ckLabel.text = @"No";
    self.ckAllowOthersNo.tag = kTagAllowOthersNo;
    [self.ckAllowOthersNo unselected];
    
    NSArray *fields = @[ self.subjectField,
                         self.tfStartDate,
                         self.tfStartTime,
                         self.tfEndDate,
                         self.tfEndTime,
                         self.whereField,
                         self.descriptionField ];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    
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
    viewFrame.size.height += (keyboardSize.height - navbarHeight - 44);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
    
}
//- (void) updateScrollView {
//    NSLog(@"%s tag=%i", __FUNCTION__, fieldIndex);
//    
//    CGRect aRect = self.view.frame;
//    
//    aRect.size.height -= keyboardHeight;
//    CGRect targetFrame = _currentField.frame;
//    
//    targetFrame.origin.y += 40;
//    
////        [self.scrollView setContentOffset:CGPointMake(0.0, currentOption.frame.origin.y-keyboardHeight) animated:YES];
//    if (!CGRectContainsPoint(aRect, targetFrame.origin) ) {
//        [self.scrollView scrollRectToVisible:targetFrame animated:YES];
//    }
//    
//}

#pragma mark - UITextField methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    keyboardIsShown = YES;
    fieldIndex = textField.tag;
        
    _currentField = textField;

    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);

    [textField resignFirstResponder];

    return YES;
}


// SEE: http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    fieldIndex = textField.tag;
    [self.keyboardControls setActiveField:textField];

//    [self updateScrollView];
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    [self.keyboardControls.activeField resignFirstResponder];
//    [textField resignFirstResponder];
//    [textField endEditing:YES];
    
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
//            [_currentField endEditing:YES];
        } else {
            
            UIView* view = sender.view;
            CGPoint loc = [sender locationInView:view];
            UIView* subview = [view hitTest:loc withEvent:nil];
            NSLog(@"tag = %i", subview.tag);
            
            
            switch (subview.tag) {
                case kTagStartDate:
                    
                    break;
                    
                case kTagStartTime:

                    break;
                    
                case kTagEndDate:
                    
                    break;
                    
                case kTagEndTime:
                    
                    break;
                    
                case kTagAllowOthersYes:
                    allow_public = 1;
                    [self.ckAllowOthersYes selected];
                    [self.ckAllowOthersNo unselected];
                    break;
                    
                case kTagAllowOthersNo:
                    allow_public = 0;
                    [self.ckAllowOthersYes unselected];
                    [self.ckAllowOthersNo selected];
                    
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
    NSMutableArray *errorIds = [[NSMutableArray alloc] init];
    
    if (self.subjectField.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagSubject]];
    }
    if (self.whereField.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagLocation]];
    }
    if (self.descriptionField.text.length == 0) {
        [errorIds addObject:[NSNumber numberWithInt:kTagDescription]];
        isOK = NO;
    }
    if (self.tfStartDate.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagStartDate]];
    }
    if (self.tfStartTime.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagStartTime]];
    }
    if (self.tfEndDate.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagEndDate]];
    }
    if (self.tfEndTime.text.length == 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagEndTime]];
    }
//    if (allow_public < 0) {
//        isOK = NO;
//        [errorIds addObject:[NSNumber numberWithInt:kTagAllowOthersYes]];
//    }

    if (isOK) {
        // Read date fields and combine
        NSString *dtFormat = @"%@ %@";
        NSString *start_time = [NSString stringWithFormat:dtFormat, self.tfStartDate, self.tfStartTime];
        NSString *end_time = [NSString stringWithFormat:dtFormat, self.tfEndDate, self.tfEndTime];
        NSLog(@"start date = %@", start_time);
        NSLog(@"end date = %@", end_time);
        
//        NSDate *date1 = [DateTimeUtils dateFromDBDateString:start_time];
//        NSDate *date2 = [DateTimeUtils dateFromDBDateString:end_time];
//        
//        // TODO: Convert back to db format
//        start_time = [DateTimeUtils dbDateStampFromDate:date1];
//        end_time = [DateTimeUtils dbDateStampFromDate:date2];
        
        FormManager *formSvc = [[FormManager alloc] init];
        FormVO *form = [[FormVO alloc] init];
        
        form.system_id = @"";
        
        form.name = self.subjectField.text;
        form.location = self.whereField.text;
        form.description = self.descriptionField.text;
        form.start_time = start_time;
        form.end_time = end_time;
        
        form.type = FormType_RSVP;
        form.status = FormStatus_DRAFT;
        
        int formId = [formSvc saveForm:form];
        if (formId > 0) {
            NSLog(@"Form saved with form_id %i", formId);
            
//            for (FormOptionVO *formOption in formOptions) {
//                formOption.form_id = formId;
//                [formSvc saveOption:formOption];
//            }
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Survey created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } else {
        // Data not complete. 
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please complete all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

#pragma mark Keyboard Controls Delegate

- (void)keyboardControlsBeforeMove:(BSKeyboardControls *)keyboardControls currentField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    NSLog(@"%s at field %i", __FUNCTION__, fieldIndex);
    
    NSDate *pickDate;
    switch (fieldIndex) {
            
        case kTagStartDate:
            pickDate = self.datePicker.date;
            
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            break;
            
        case kTagStartTime:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            
            break;
            
        case kTagEndDate:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            
            break;
            
        case kTagEndTime:
            
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            break;
    }
    
}


- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    
//    UIView *active = keyboardControls.activeField;
////    CGRect aRect = self.view.frame;    
////    aRect.size.height -= keyboardHeight;
//
//    CGRect targetFrame = active.frame;
//    targetFrame.origin.y -= keyboardHeight;
//    
//    [self.scrollView scrollRectToVisible:targetFrame animated:YES];
}


- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls
{
    NSLog(@"%s at field %i", __FUNCTION__, fieldIndex);
    
    NSDate *pickDate;
    switch (fieldIndex) {
            
        case kTagStartDate:
            pickDate = self.datePicker.date;
            
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            break;
            
        case kTagStartTime:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            
            break;
            
        case kTagEndDate:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            
            break;
            
        case kTagEndTime:
            
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            break;
    }
    
    [_currentField resignFirstResponder];
    
//    [self.scrollView scrollRectToVisible:self.view.frame animated:YES];
    
}

#pragma mark - picker actions

-(IBAction)dismissDatePicker:(id)sender {
    NSDate *pickDate = self.datePicker.date;
    switch (fieldIndex) {
            
        case kTagStartDate:
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            break;
            
        case kTagStartTime:
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            break;
            
        case kTagEndDate:
            _currentField.text = [DateTimeUtils dbDateStampFromDate:pickDate];
            break;
            
        case kTagEndTime:
            _currentField.text = [DateTimeUtils simpleTimeLabelFromDate:pickDate];
            break;
    }
    [_currentField resignFirstResponder];
}


- (IBAction)tapPickPhoto {
    NSLog(@"%s", __FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification
                                                            notificationWithName:@"showImagePickerNotification"
                                                            object:nil]];
    
}
- (void) setPhoto:(UIImage *)photo {
    NSLog(@"%s", __FUNCTION__);
    self.photoHolder.hidden = NO;
    self.roundPic.image = photo;
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate gotoSlideWithName:@"FormsHome"];
    
}

#pragma mark - UIImagePicker methods


- (void)showImagePickerNotificationHandler:(NSNotification*)notification
{
    NSNumber *index = (NSNumber *) [notification object];
    fieldIndex = index.intValue;
    
    NSLog(@"%s for index %i", __FUNCTION__, fieldIndex);
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
    
    [self setPhoto:tmpImage];
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
