//
//  MyProfileVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "MyProfileVC.h"
#import "UIImage+Resize.h"

#define kTagScrollView  99
#define kTagNameLabel   101
#define kTagBGLayer     666

@interface MyProfileVC ()

@end

@implementation MyProfileVC

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
//    CGRect frame = self.view.frame;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGRect frame = self.view.frame;
        frame.size.height += 20;
        self.view.frame = frame;
    }

    CGRect scrollFrame = self.scrollView.frame;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        scrollFrame.origin.y += 20;
    }
    scrollFrame.size.height = [DataModel shared].stageHeight;
    self.scrollView.frame = scrollFrame;
    CGSize scrollContentSize = CGSizeMake(320, 400);
    self.scrollView.contentSize = scrollContentSize;
    
    self.scrollView.delegate = self;
    self.tfFirstName.delegate = self;
    self.tfLastName.delegate = self;

    keyboardIsShown = NO;
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    CGRect modalFrame = self.photoModal.frame;
    int ypos = -modalFrame.size.height;
    int xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    self.photoModal.layer.zPosition = 99;
    self.photoModal.frame = modalFrame;
    [self.scrollView addSubview:self.photoModal];
    

    [self.roundPic.layer setCornerRadius:66.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:3.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    
    
    userSvc = [[UserManager alloc] init];
    contactSvc = [[ContactManager alloc] init];
    
    if ([DataModel shared].myContact.first_name.length == 0 && [DataModel shared].myContact.last_name.length == 0 ) {
        [self showEditView];
    } else {
        NSString *fullname = [DataModel shared].myContact.fullname;
        self.nameLabel.text = fullname;

    }
    [contactSvc asyncLoadCachedPhoto:[DataModel shared].user.contact_key callback:^(UIImage *img) {
        if (img == nil) {
            img = [UIImage imageNamed:@"anonymous_user"];
        }
        self.roundPic.image = img;

    }];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapRecognizer];
    
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

- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height = [DataModel shared].stageHeight - keyboardSize.height - viewFrame.origin.y;
    
    CGRect targetFrame = self.editView.frame;
//    targetFrame.origin.y += targetFrame.size.height;

    self.scrollView.frame = viewFrame;
//    self.scrollView.contentSize = CGSizeMake([DataModel shared].stageWidth, self.saveButton.frame.origin.y + 50);
    [self.scrollView scrollRectToVisible:targetFrame animated:YES];

    keyboardIsShown = YES;
    
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
    return YES;
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
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Saving"];

	UIImage *tmpImage = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"Original size %f, %f", tmpImage.size.width, tmpImage.size.height);
    //    float aspectRatio = tmpImage.size.width / tmpImage.size.height;
    //    if (aspectRatio >= 1) {
    //        resize = CGSizeMake(aspectRatio * kMinimumImageDimension, kMinimumImageDimension);
    //    } else {
    //        resize = CGSizeMake(kMinimumImageDimension, aspectRatio * kMinimumImageDimension);
    //    }
    //    UIImage *resizeImage = [tmpImage resizedImage:resize interpolationQuality:kCGInterpolationDefault];
    CGSize resize;
    
    resize = CGSizeMake(kMinimumImageDimension, kMinimumImageDimension);
    
    UIImage *resizeImage = [tmpImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:resize interpolationQuality:kCGInterpolationMedium];
    // FIXME: downsize image
    self.roundPic.image = resizeImage;
    tmpImage = nil;
    
    NSLog(@"Original size %f, %f", resizeImage.size.width, resizeImage.size.height);
    if (userSvc == nil) {
        userSvc = [[UserManager alloc] init];
    }
    NSString *filename;
    filename = [NSString stringWithFormat:@"%@.png", [DataModel shared].user.contact_key];
    [userSvc savePhoto:resizeImage filename:filename callback:^(NSString *imageUrl) {
        if (imageUrl != nil) {
            [DataModel shared].user.photoUrl = imageUrl;
        } else {
            
        }
        [MBProgressHUD hideHUDForView:self.view animated:NO];

    }];
    
    
	[self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerVC = nil;
    //    [self setupButtonsForEdit];
    
}


#pragma mark - IBActions

- (IBAction)tapBackButton {
    [_delegate goBack];
    
}

- (IBAction)tapPhotoArea {
    [self showModal];
}
- (IBAction)tapMessageButton {
    
}
- (IBAction)tapPhoneButton {
    
}
- (IBAction)tapSaveButton {
    
    [_currentField resignFirstResponder];
    BOOL isOk = YES;
    if (self.tfFirstName.text.length == 0) {
        isOk = NO;
    }
    if (self.tfLastName.text.length == 0) {
        isOk = NO;
    }
    if (isOk) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.hud setLabelText:@"Saving"];
        
        [DataModel shared].myContact.first_name = self.tfFirstName.text;
        [DataModel shared].myContact.last_name = self.tfLastName.text;
        self.nameLabel.text = [DataModel shared].myContact.fullname;
        [contactSvc apiSaveContact:[DataModel shared].myContact callback:^(PFObject *pfContact) {
            
            [self hideEditView];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
        }];
        
        
    }
}

#pragma mark - Touch Gestures

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        UIView* view = sender.view;
        CGPoint loc = [sender locationInView:view];
        UIView* subview = [view hitTest:loc withEvent:nil];
        NSLog(@"tag = %i", subview.tag);
        
        switch (subview.tag) {
            case kTagScrollView:
                if (keyboardIsShown) {
                    [_currentField resignFirstResponder];
                    keyboardIsShown = NO;

                }
                break;
            case kTagNameLabel:
                [self showEditView];
                break;
        }
    }
}

- (void) showEditView
{
    if(![self.editView isDescendantOfView:[self view]]) {
        CGRect editFrame = self.editView.frame;
        editFrame.origin.y = self.nameLabel.frame.origin.y - 5;
        editFrame.origin.x = 0;
        
        self.editView.frame = editFrame;
        
        self.tfFirstName.text = [DataModel shared].myContact.first_name;
        self.tfLastName.text = [DataModel shared].myContact.last_name;
        
        [self.scrollView addSubview:self.editView];
    }

}
- (void) hideEditView
{
    [self.editView removeFromSuperview];
    
}

@end
