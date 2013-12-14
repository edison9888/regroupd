//
//  NewPollVC.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "EditRSVPVC.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "UIAlertView+Helper.h"
#import "DateTimeUtils.h"
#import "UIImage+Resize.h"
#import "UIColor+ColorWithHex.h"

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
    canSave = YES;

    formSvc = [[FormManager alloc] init];
    
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
    CGSize scrollContentSize = CGSizeMake([DataModel shared].stageWidth, 800);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.delegate = self;
    
    
    // Setup text fields
    
    self.subjectField.delegate = self;
    
    self.whereField.delegate = self;
    self.descriptionField.delegate = self;
    
    self.subjectField.textAlignment = NSTextAlignmentLeft;
    self.whereField.textAlignment = NSTextAlignmentLeft;
    self.descriptionField.textAlignment = NSTextAlignmentLeft;

    // Add survey options

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.timePicker = [[UIDatePicker alloc] init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.minuteInterval = 15;
    
    self.tfStartDate.tag = kTagStartDate;
    self.tfStartDate.text = @"";
    self.tfStartDate.inputView = self.datePicker;
    self.tfStartDate.delegate = self;

    self.tfStartTime.tag = kTagStartTime;
    self.tfStartTime.text = @"";
    self.tfStartTime.inputView = self.timePicker;
    self.tfStartTime.delegate = self;

    self.tfEndDate.tag = kTagEndDate;
    self.tfEndDate.text = @"";
    self.tfEndDate.inputView = self.datePicker;
    self.tfEndDate.delegate = self;
    
    self.tfEndTime.tag = kTagEndTime;
    self.tfEndTime.text = @"";
    self.tfEndTime.inputView = self.timePicker;
    self.tfEndTime.delegate = self;

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

    [self.keyboardControls setSegmentedControlTintControl:[UIColor colorWithHexValue:0x999999]];
    
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
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formSaveCompleteNotificationHandler:)     name:k_formSaveCompleteNotification            object:nil];
    
    
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.datePicker.date = [self getRoundedDate:[NSDate date]];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:kSimpleTimeFormat];
    
    
    fieldTags = @[@kTagSubject, @kTagLocation, @kTagDescription, @kTagStartDate, @kTagStartTime, @kTagEndDate, @kTagEndTime];
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

- (void)formSaveCompleteNotificationHandler:(NSNotification*)notification
{
    NSLog(@"===== %s", __FUNCTION__);
    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"RSVP created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    viewFrame.size.height = [DataModel shared].stageHeight - 44;
    
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

#pragma mark - Date Picker and Date methods

- (void) timePickerValueChanged:(id)sender{
    NSLog(@"%s fieldIndex=%i", __FUNCTION__, fieldIndex);
    _currentField.text = [DateTimeUtils printTimePartFromDate:self.timePicker.date];
}
- (void) datePickerValueChanged:(id)sender{
    NSLog(@"%s fieldIndex=%i", __FUNCTION__, fieldIndex);
    _currentField.text = [DateTimeUtils printDatePartFromDate:self.datePicker.date];

//    switch (fieldIndex) {
//        case kTagStartDate:
//            
//            self.tfStartDate.text = [DateTimeUtils printDatePartFromDate:self.datePicker.date];
//            break;
//            
//        case kTagStartTime:
//            
//            self.tfStartTime.text = [DateTimeUtils printTimePartFromDate:self.datePicker.date];
//            break;
//            
//        case kTagEndDate:
//            
//            self.tfEndDate.text = [DateTimeUtils printDatePartFromDate:self.datePicker.date];
//            break;
//            
//        case kTagEndTime:
//            
//            self.tfEndTime.text = [DateTimeUtils printTimePartFromDate:self.datePicker.date];
//            break;
//            
//    }

}

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
    FancyTextField *fancyField;
    
    if (textField.tag >= kTagSubject && textField.tag <= kTagEndTime) {
        // FINISH THIS: deactivate all fields and set current one as active
        for (NSNumber *fieldTag in fieldTags) {
//            NSLog(@"fieldTag %@", fieldTag);
            fancyField = (FancyTextField *)[self.view viewWithTag:fieldTag.integerValue];
            [fancyField setDefaultStyle];
        }
    }
    fancyField = (FancyTextField *)[self.view viewWithTag:textField.tag];
    [fancyField setActiveStyle:nil];
    
    
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
    if (allow_public < 0) {
        isOK = NO;
        [errorIds addObject:[NSNumber numberWithInt:kTagAllowOthersYes]];
    }
    
    if (isOK) {
//        FormManager *formSvc = [[FormManager alloc] init];


        // Read date fields and combine
        NSString *dtFormat = @"%@ %@";
        NSString *start_time = [NSString stringWithFormat:dtFormat, self.tfStartDate.text, self.tfStartTime.text];
        NSString *end_time = [NSString stringWithFormat:dtFormat, self.tfEndDate.text, self.tfEndTime.text];
        NSLog(@"start date = %@", start_time);
        NSLog(@"end date = %@", end_time);
        
        NSDate *date1 = [DateTimeUtils readDateFromFriendlyDateTime:start_time];
        NSDate *date2 = [DateTimeUtils readDateFromFriendlyDateTime:end_time];
        
        NSLog(@"starts at %@", date1);
        NSLog(@"ends at %@", date2);
//
//        // TODO: Convert back to db format
//        start_time = [DateTimeUtils dbDateStampFromDate:date1];
//        end_time = [DateTimeUtils dbDateStampFromDate:date2];
        
        if (date1 != nil && date2 != nil) {
            self.doneButtonTop.enabled = NO;
            self.doneButtonEnd.enabled = NO;
            if (canSave) {
                canSave = NO;
                FormVO *form = [[FormVO alloc] init];
                
                form.system_id = @"";
                form.name = self.subjectField.text;
                form.location = self.whereField.text;
                form.details = self.descriptionField.text;
                //        form.start_time = start_time;
                //        form.end_time = end_time;
                form.type = FormType_RSVP;
                form.status = FormStatus_DRAFT;
                form.allow_share = [NSNumber numberWithInt:allow_public];
                
                form.eventStartsAt = date1;
                form.eventEndsAt = date2;
                form.photo = formImage;
                
                [formSvc apiSaveForm:form callback:^(PFObject *pfForm) {
                    NSString *formId = pfForm.objectId;
                    
                    NSArray *answers = @[kResponseYes, kResponseMaybe, kResponseNo];
                    
                    for (int i=1; i<=answers.count; i++) {
                        
                        FormOptionVO *option;
                        
                        option = [[FormOptionVO alloc] init];
                        
                        option.name =[answers objectAtIndex:i-1];
                        option.position = i;
                        
                        [formSvc apiSaveFormOption:option formId:formId callback:^(PFObject *object) {
                            NSLog(@"Save option %i", i + 1);
                            if (i == answers.count) {
                                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_formSaveCompleteNotification object:nil]];
                            }
                            
                        }];
                    }
                    
                }];
                
                
            }

            
        } else {
            NSLog(@"Date conversion failed: %@ -- %@", start_time, end_time);
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
    if (_currentField.text.length == 0) {
        switch (fieldIndex) {
                
            case kTagStartDate:
                pickDate = self.datePicker.date;
                
                _currentField.text = [DateTimeUtils printDatePartFromDate:pickDate];
                if (self.tfEndDate.text.length == 0) {
                    self.tfEndDate.text = _currentField.text;
                    
                }
                break;
                
            case kTagStartTime:
                pickDate = self.datePicker.date;
                _currentField.text = [DateTimeUtils printTimePartFromDate:pickDate];
                if (self.tfEndTime.text.length == 0) {
                    self.tfEndTime.text = _currentField.text;
                }
                
                break;
                
            case kTagEndDate:
                pickDate = self.datePicker.date;
                _currentField.text = [DateTimeUtils printDatePartFromDate:pickDate];
                
                break;
                
            case kTagEndTime:
                
                pickDate = self.datePicker.date;
                _currentField.text = [DateTimeUtils printTimePartFromDate:pickDate];
                break;
        }
    }
    
}


- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    
}


- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls
{
    NSLog(@"%s at field %i", __FUNCTION__, fieldIndex);
    
    NSDate *pickDate;
    switch (fieldIndex) {
            
        case kTagStartDate:
            pickDate = self.datePicker.date;
            
            _currentField.text = [DateTimeUtils printDatePartFromDate:pickDate];
            break;
            
        case kTagStartTime:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils printTimePartFromDate:pickDate];
            
            break;
            
        case kTagEndDate:
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils printDatePartFromDate:pickDate];            
            break;
            
        case kTagEndTime:
            
            pickDate = self.datePicker.date;
            _currentField.text = [DateTimeUtils printTimePartFromDate:pickDate];
            break;
    }
    
    [_currentField resignFirstResponder];
    
//    [self.scrollView scrollRectToVisible:self.view.frame animated:YES];
    
}

#pragma mark - picker actions

-(NSDate *)getRoundedDate:(NSDate *)inDate
{
    NSInteger minuteInterval = 15;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:inDate];
    NSInteger minutes = [dateComponents minute];
    
    float minutesF = [[NSNumber numberWithInteger:minutes] floatValue];
    float minuteIntervalF = [[NSNumber numberWithInteger:minuteInterval] floatValue];
    
    // Determine whether to add 0 or the minuteInterval to time found by rounding down
    NSInteger roundingAmount = (fmodf(minutesF, minuteIntervalF)) > minuteIntervalF/2.0 ? minuteInterval : 0;
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded + roundingAmount - minutes) sinceDate:inDate];
    
    return roundedDate;
}



- (IBAction)tapPickPhoto {
    NSLog(@"%s", __FUNCTION__);
    [_currentField resignFirstResponder];
    
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.imagePickerVC = nil;
}

- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s", __FUNCTION__);
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

	UIImage *tmpImage = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    CGSize resize;
    
    resize = CGSizeMake(kMinimumImageDimension, kMinimumImageDimension);
    
    formImage = [tmpImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:resize interpolationQuality:kCGInterpolationMedium];
    
    tmpImage = nil;
    
    [self setPhoto:formImage];
    
	[self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerVC = nil;
//    [self setupButtonsForEdit];
    
}


@end
