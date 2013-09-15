//
//  ProfileEdit4VC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ProfileEdit4VC.h"
#import "UserVO.h"
#import "FaxManager.h"
#import <CoreGraphics/CoreGraphics.h>

@interface ProfileEdit4VC ()

@end

@implementation ProfileEdit4VC

@synthesize pagedot1, pagedot2, pagedot3, pagedot4, pagedot5;
@synthesize nextButton, backButton;
@synthesize label1;
@synthesize signatureView;
@synthesize signatureZone;

#define kSignatureTag   99

#pragma mark - Standard lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"ProfileEdit4VC";
    
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
    
    CGRect sigframe = CGRectMake(20, 209, 280, 120);
    
    signatureView = [[SignatureView alloc] initWithFrame:sigframe];
    signatureView.tag = kSignatureTag;
    signatureView.layer.zPosition = 5;
    [signatureView setUserInteractionEnabled:NO];
    
    [self.view addSubview:signatureView];

    signatureZone.layer.zPosition = 10;
    
    userSvc = [[UserManager alloc] init];
    
    UIImage *image = [userSvc loadSignature:@"sig_1.png"];
    if (image != nil) {
        signatureView.drawView.image = image;
    }
    
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    
    
//    // Create and initialize a tap gesture
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
//                                             initWithTarget:self action:@selector(singleTap:)];    
//    // Specify that the gesture must be a single tap
//    tapRecognizer.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapRecognizer];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Touch handling

//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
//    
//    
//    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
//    UIView* hitView = [self.view hitTest:locationPoint withEvent:event];
//    NSLog(@"hitView.tag = %i", hitView.tag);
//
//    if (hitView.tag == kSignatureTag) {
//        [[[UIAlertView alloc] initWithTitle:@"Please confirm" message:@"Do you want to add a new signature?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        
//    }
//    
//    
//    
//}
//-(void)singleTap:(UITapGestureRecognizer*)tap
//{
//    NSLog(@"%s", __FUNCTION__);
//    if (UIGestureRecognizerStateEnded == tap.state)
//    {
//        
//        
//    }
//}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        
        
    } else {
        signatureView.drawView.image = [[UIImage alloc] init];
        
        [signatureView setUserInteractionEnabled:YES];
        [signatureZone setUserInteractionEnabled:NO];
        
    }
    
}

#pragma mark - Action handlers

- (IBAction)goNext
{
    BOOL isOk = YES;
    
    // FIXME: Check if signature was created
    [self saveSignatureImage];
    
    if (isOk) {
        [_delegate gotoNextSlide];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Please enter all the required information before proceeding to the next step." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}

- (IBAction)goBack
{
    [_delegate gotoPreviousSlide];
    
}
- (IBAction)tapCancelButton {
    [_delegate gotoSlideWithName:@"ProfileHome" andOverrideTransition:kPresentationTransitionFade];
}
- (IBAction)tapDoneButton {
    BOOL isOk = YES;
    
    [self saveSignatureImage];
    
    if (isOk) {
        [_delegate gotoSlideWithName:@"ProfileHome" andOverrideTransition:kPresentationTransitionFade];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"INFO" message:@"Please enter all the required information before proceeding to the next step." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (IBAction)tapSignatureZone {

    [[[UIAlertView alloc] initWithTitle:@"Please confirm" message:@"Do you want to add a new signature?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil] show];

}

- (void) saveSignatureImage {

    CGRect sigFrame = signatureView.frame;
    NSLog(@"sigFrame %f / %f", sigFrame.size.width, sigFrame.size.height);
    
    UIGraphicsBeginImageContextWithOptions(sigFrame.size,NO,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    signatureView.backgroundColor = [UIColor clearColor];
    signatureView.layer.backgroundColor = [UIColor clearColor].CGColor;
    [signatureView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UserManager *userMgr = [[UserManager alloc] init];
    int userId = [DataModel shared].user.userId;
    NSString *filename = [NSString stringWithFormat:@"sig_%i.png", userId];
    
    NSString *filepath = [userMgr saveSignature:image withName:filename];
    
    NSLog(@"filepath = %@", filepath);

}

@end
