//
//  MyProfileVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "MyProfileVC.h"
#import "UIImage+Resize.h"

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
    // Do any additional setup after loading the view from its nib.
    
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    CGRect modalFrame = self.photoModal.frame;
    int ypos = -modalFrame.size.height;
    int xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    self.photoModal.layer.zPosition = 99;
    self.photoModal.frame = modalFrame;
    [self.view addSubview:self.photoModal];
    

    [self.roundPic.layer setCornerRadius:66.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:3.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    
    userSvc = [[UserManager alloc] init];
    contactSvc = [[ContactManager alloc] init];
    
    
//    NSString *filename;
//    filename = [NSString stringWithFormat:@"%@.png", [DataModel shared].user.contact_key];
//    img = [userSvc loadPhoto:filename];
    
    
    [contactSvc asyncLoadCachedPhoto:[DataModel shared].user.contact_key callback:^(UIImage *img) {
        if (img == nil) {
            img = [UIImage imageNamed:@"anonymous_user"];
        }
        self.roundPic.image = img;

    }];
//    NSString *nameFormat = @"%@ %@";
//    self.nameLabel.text = [NSString stringWithFormat:nameFormat,
//                           [DataModel shared].user.first_name,
//                           [DataModel shared].user.last_name];

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
    
    self.imagePickerVC = nil;
}

- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s", __FUNCTION__);
    
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
- (IBAction)tapGroupsButton {
    
}
- (IBAction)tapBlockButton {
    
}


@end
