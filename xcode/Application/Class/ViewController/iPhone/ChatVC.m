//
//  ChatVC
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "ChatVC.h"
#import "DataModel.h"
#import "Constants.h"

#import "UIAlertView+Helper.h"
#import "DateTimeUtils.h"
#import "EmbedPollWidget.h"
#import "EmbedRatingWidget.h"
#import "EmbedRSVPWidget.h"

#import "FormManager.h"
//#import "NSDate+Extensions.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIColor+ColorWithHex.h"

#define kMinInputHeight 40
#define kMaxInputHeight 93


@interface ChatVC ()
{
//    IBOutlet UIBubbleTableView *bubbleTable;
    
    NSMutableArray *bubbleData;
}

@end

@implementation ChatVC

@synthesize bubbleData;
@synthesize bubbleTable;

#define kFirstOptionId  1
#define kScrollViewTop 50
#define kChatBarHeight 50

#define kMinDrawerPull    50
#define kMaxDrawerPull    130

#define kTagTopDrawer   13
#define kTagSendButton   33
#define kTagAttachModalBG 666
#define kTagPhotoModalBG  667
#define kTagFormModalBG  668

#define kAlphaDisabled  0.8f

#define kAttachPhotoIcon    @"icon_attach_photo"
#define kAttachPollIcon     @"icon_attach_poll"
#define kAttachRatingIcon   @"icon_attach_rating"
#define kAttachRSVPIcon     @"icon_attach_rsvp"

#define kAttachPhotoIconAqua    @"icon_attach_photo_aqua"
#define kAttachPollIconAqua     @"icon_attach_poll_aqua"
#define kAttachRatingIconAqua   @"icon_attach_rating_aqua"
#define kAttachRSVPIconAqua     @"icon_attach_rsvp_aqua"

#define kAttachPlusIcon     @"chat_attach_plus"

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
    inputHeight = 0;
    theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];

    self.inputField.delegate = self;
    self.detachButton.hidden = YES;
    hasAttachment = NO;
    attachmentType = FormType_POLL;
    
    chatSvc = [[ChatManager alloc] init];
    
    
    // Setup table view
    
    CGRect scrollFrame = self.bubbleTable.frame;
    scrollFrame.size.height -= kChatBarHeight;
    NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
    
    self.bubbleTable.frame = scrollFrame;
    self.bubbleTable.backgroundColor = [UIColor colorWithHexValue:kChatBGGrey andAlpha:1.0];
    self.bubbleTable.userInteractionEnabled = YES;
    
    chatFrame = self.chatBar.frame;
    chatFrame.origin.y = [DataModel shared].stageHeight - kChatBarHeight;
    self.chatBar.frame = chatFrame;
    
    inputFrame = self.inputField.frame;
    [self.inputField setContentInset:UIEdgeInsetsMake(0.0, 4.0, 0.0, -10.0)];

    
    NSBubbleData *heyBubble = [NSBubbleData dataWithText:@"Hey, halloween is soon" date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];

    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"maserati.jpg"] date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
    photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    
    NSBubbleData *replyBubble = [NSBubbleData dataWithText:@"Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?" date:[NSDate dateWithTimeIntervalSinceNow:-5] type:BubbleTypeMine];
    replyBubble.avatar = nil;
    
    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, photoBubble, replyBubble, nil];
    self.bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    self.bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    self.bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
//    self.bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    [self.bubbleTable reloadData];
    
    // Keyboard events
    // Setup notifications
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFormSelectorNotificationHandler:)     name:@"hideFormSelectorNotification"            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImagePickerNotificationHandler:)     name:@"showImagePickerNotification"            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];


    // Create and initialize a tap gesture
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    /*
     
     http://stackoverflow.com/questions/6672677/how-to-use-uipangesturerecognizer-to-move-object-iphone-ipad
     
     */
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(handlePull:)];
    
    // Specify that the gesture must be a single tap
    [panRecognizer setMinimumNumberOfTouches:1];
    
    panRecognizer.cancelsTouchesInView = YES;
    [self.topDrawer addGestureRecognizer:panRecognizer];

//    UILongPressGestureRecognizer *touchDrag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
//    touchDrag.numberOfTapsRequired=1;
//    touchDrag.minimumPressDuration=0.0;
//    touchDrag.delegate = self;
//    [self.view addGestureRecognizer:touchDrag];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}


#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"===== %s", __FUNCTION__);
    inputHeight = textView.frame.size.height;

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"===== %s", __FUNCTION__);
    
    [textView endEditing:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    //    NSLog(@"%s tag=%i", __FUNCTION__, textView.tag);
    
    float vshift = 0;
    
//    CGSize estSize = [self determineSize:textView.text constrainedToSize:self.inputField.frame.size];
//    textView.attributedText =  [[NSMutableAttributedString alloc] initWithString:textView.text];
    CGSize estSize;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        estSize = [textView sizeThatFits:textView.frame.size];
    } else {
        estSize = textView.contentSize;
    }
    
    float newsize = estSize.height;
    
    NSLog(@"inputHeight %f // newsize %f", inputHeight, newsize);
    
    if (inputHeight != newsize ) {
        NSLog(@"textView height is now %f", newsize);
        vshift = newsize - inputHeight;
        
        inputHeight = newsize;
        if (inputHeight < kMaxInputHeight) {
            CGRect frame = self.inputField.frame;
            frame.size.height = newsize;
            self.inputField.frame = frame;
            
//            self.inputField.frame = CGRectMake(self.inputField.frame.origin.x,
//                                           self.inputField.frame.origin.y,
//                                           self.inputField.frame.size.width,
//                                           newsize);
//            self.inputField.frame = inputFrame;

            frame = self.chatBar.frame;
            
            frame.size.height += vshift;
            frame.origin.y -= vshift;
            self.chatBar.frame = frame;

        } else {
//            [textView scr]
        }
    }
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if( [text isEqualToString:[text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]] ) {
        return YES;

    } else {
        NSLog(@"Return key event");
        [self insertMessageInChat];
        
        return NO;
        
    }
}

- (CGSize)determineSize:(NSString *)text constrainedToSize:(CGSize)size
{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:theFont}
                                          context:nil];
        return frame.size;
    } else {
        return [text sizeWithFont:theFont constrainedToSize:size];
    }
}
- (CGFloat)textViewHeightForAttributedText:(NSAttributedString*)text andWidth:(CGFloat)width
{
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
//    NSLog(@"%s", __FUNCTION__);
    keyboardIsShown = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    kbSize.height += kChatBarHeight;
//    NSLog(@"Keyboard height is %f", kbSize.height)
    
    [UIView animateWithDuration:0.1f animations:^{
        
        chatFrameWithKeyboard = self.chatBar.frame;
        chatFrameWithKeyboard.origin.y -= kbSize.height;
        
        self.chatBar.frame = chatFrameWithKeyboard;
        
        CGRect frame = self.bubbleTable.frame;
        frame.size.height -= kbSize.height + kChatBarHeight;
        
        self.bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"%s", __FUNCTION__);
    keyboardIsShown = NO;
    
    [UIView animateWithDuration:0.1f animations:^{

        CGRect frame = self.bubbleTable.frame;
        frame.size.height = [DataModel shared].stageHeight - kChatBarHeight - kScrollViewTop;
//        frame.size.height += kbSize.height + kChatBarHeight;
        self.bubbleTable.frame = frame;

        frame = self.chatBar.frame;
        frame.origin.y = [DataModel shared].stageHeight - kChatBarHeight;
        self.chatBar.frame = frame;
        
    }];
}

#pragma mark - Actions

#pragma mark - Modal

- (void) showAttachModal {
    [self becomeFirstResponder];
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.4;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = kTagAttachModalBG;
    [self.view addSubview:bgLayer];
    
    // Setup modal state
    [self setupModalHotspots];

    // Setup attachModal
    
    CGRect modalFrame = self.attachModal.frame;
    int ypos = [DataModel shared].stageHeight + 10;
    int xpos = 0;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    self.attachModal.layer.zPosition = 99;
    self.attachModal.frame = modalFrame;
    [self.view addSubview:self.attachModal];
    

    ypos = ([DataModel shared].stageHeight - modalFrame.size.height);
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.attachModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
    
}

- (void) hideAttachModal {
    
    if (bgLayer != nil) {
        [bgLayer removeFromSuperview];
        bgLayer = nil;
    }
    
    CGRect modalFrame = self.attachModal.frame;
    int ypos = [DataModel shared].stageHeight + 10;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.attachModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){                                                  
                     }];
    
    
}

- (void) showPhotoModal {
    [self becomeFirstResponder];
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = kTagPhotoModalBG;
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

- (void) hidePhotoModal {
    
    if (bgLayer != nil) {
        [bgLayer removeFromSuperview];
        bgLayer = nil;
    }

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

- (void) showFormSelector {
    
    
//    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
//    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
//    bgLayer.backgroundColor = [UIColor grayColor];
//    bgLayer.alpha = 0.8;
//    bgLayer.layer.zPosition = 8;
//    bgLayer.tag = kTagFormModalBG;
//    [self.view addSubview:bgLayer];

    
    self.formSelectorVC = [[FormSelectorVC alloc] initWithNibName:@"FormSelectorVC" bundle:nil];
    CGRect panelFrame = self.formSelectorVC.view.frame;
    panelFrame.origin.y = [DataModel shared].stageHeight + 10;
    
    self.formSelectorVC.view.frame = panelFrame;
    self.formSelectorVC.view.layer.zPosition = 99;
    
    [self.view addSubview:self.formSelectorVC.view];
    
    self.formSelectorVC.titleLabel.text = formTitle;
//    [self.view bringSubviewToFront:self.formSelectorVC.view];
    
    float ypos = ([DataModel shared].stageHeight - panelFrame.size.height);
    panelFrame.origin.y = ypos;
    [self.formSelectorVC becomeFirstResponder];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.formSelectorVC.view.frame = panelFrame;
                     }
                     completion:^(BOOL finished){
                         // nothing
                     }];

}
- (void) hideFormSelector {
    if (bgLayer != nil) {
        [bgLayer removeFromSuperview];
        bgLayer = nil;
    }
    
    CGRect modalFrame = self.formSelectorVC.view.frame;
    int ypos = [DataModel shared].stageHeight + 10;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.formSelectorVC.view.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];


}




#pragma mark IBActions
- (IBAction)tapCancelButton {
    [_delegate gotoSlideWithName:@"ChatsHome"];
    
}
- (IBAction)tapClearButton {
    NSLog(@"%s", __FUNCTION__);
    
}
- (IBAction)tapAttachButton {
    NSLog(@"%s", __FUNCTION__);
    
    [self.inputField resignFirstResponder];
    [self showAttachModal];
    
}
- (IBAction)tapSendButton {
    NSLog(@"%s", __FUNCTION__);
    [self insertMessageInChat];
}
- (IBAction)tapDetachButton {
    // ADD WARNING ALERT
    hasAttachment = NO;
    attachmentType = -1;
    attachedPhoto = nil;
    
    [self hideAttachModal];
    [self.attachButton setImage:[UIImage imageNamed:kAttachPlusIcon] forState:UIControlStateNormal];
    [self.attachButton setSelected:NO];
    
}


- (IBAction)modalCameraButton {
    NSLog(@"%s", __FUNCTION__);
    [self hideAttachModal];
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
    [self hideAttachModal];
    if (self.imagePickerVC == nil) {
        self.imagePickerVC = [[UIImagePickerController alloc] init];
        self.imagePickerVC.delegate = self;
    }
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    
}
- (IBAction)modalCancelButton {
    [self hidePhotoModal];
}


#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_delegate gotoSlideWithName:@"ChatHome"];
    
}

#pragma mark - UIImagePicker methods


- (void)showImagePickerNotificationHandler:(NSNotification*)notification
{
    NSNumber *index = (NSNumber *) [notification object];
    fieldIndex = index.intValue;
    
    NSLog(@"%s for index %i", __FUNCTION__, fieldIndex);
    [self showAttachModal];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)Picker {
    NSLog(@"%s", __FUNCTION__);
	[self dismissViewControllerAnimated:YES completion:nil];
    
    self.imagePickerVC = nil;
    attachedPhoto = nil;
    
}

- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s", __FUNCTION__);
	attachedPhoto = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    attachmentType = 0;
    hasAttachment = YES;
    
	[self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerVC = nil;

    [self hidePhotoModal];
    
//    self.attachButton.imageView.image = [UIImage imageNamed:kAttachPhotoIcon];
    [self.attachButton setImage:[UIImage imageNamed:kAttachPhotoIconAqua] forState:UIControlStateNormal];
//    [self.attachButton setImage:[UIImage imageNamed:kAttachPhotoIconAqua] forState:UIControlStateSelected];
    
 
    //    [self setupButtonsForEdit];
    
}

#pragma mark - Tap Gestures
-(void)handleDrag:(UILongPressGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    UIView* view = sender.view;
    CGPoint loc = [sender locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    CGPoint subloc = [sender locationInView:subview];
    NSLog(@"hit tag = %i at point %f / %f", subview.tag, subloc.x, subloc.y);
    
    
   
}

- (void)handlePull:(UIPanGestureRecognizer *)sender {
    
    // SEE http://www.raywenderlich.com/6567/uigesturerecognizer-tutorial-in-ios-5-pinches-pans-and-more
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [sender velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(sender.view.center.x,
                                         sender.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), kMaxDrawerPull);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            sender.view.center = finalPoint;
        } completion:nil];
        
    } else {
        CGPoint translation = [sender translationInView:self.view];
        
        // Height of blue tab is 20px so use 10 as offset from center
        if (sender.view.center.y - 10 + translation.y <= kMaxDrawerPull &&
            sender.view.center.y - 10 + translation.y >= kMinDrawerPull) {
            sender.view.center = CGPointMake(sender.view.center.x,
                                             sender.view.center.y + translation.y);
            
        } else if (sender.view.center.y - 10 + translation.y > kMaxDrawerPull) {
            sender.view.center = CGPointMake(sender.view.center.x,
                                             kMaxDrawerPull - 10);
        } else if (sender.view.center.y - 10 + translation.y < kMinDrawerPull) {
            sender.view.center = CGPointMake(sender.view.center.x,
                                             kMinDrawerPull - 10);
        }
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        
    }

}
-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        UIView* view = sender.view;
        CGPoint loc = [sender locationInView:view];
        UIView* subview = [view hitTest:loc withEvent:nil];
        CGPoint subloc = [sender locationInView:subview];
        NSLog(@"hit tag = %i at point %f / %f", subview.tag, subloc.x, subloc.y);

        if (keyboardIsShown && subview.tag != kTagSendButton) {
            [self.inputField resignFirstResponder];
            [self.inputField endEditing:YES];
            
        } else {
            
            
            switch (subview.tag) {
                case kTagAttachModalBG:
                    [self hideAttachModal];
                    break;
                case kTagPhotoModalBG:
                    [self hidePhotoModal];
                    break;
                case kTagFormModalBG:
                    [self hideFormSelector];
                    break;
                    
            }
        }
    }
}

#pragma mark - Hotspot Actions

- (void) setupModalHotspots {
    
    if (hasAttachment) {
        self.plusIconsView.hidden = YES;
        [self.attachPhotoHotspot removeTarget:self action:@selector(tapPhotoHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachPollHotspot removeTarget:self action:@selector(tapPollHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRatingHotspot removeTarget:self action:@selector(tapRatingHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRSVPHotspot removeTarget:self action:@selector(tapRSVPHotspot:) forControlEvents:UIControlEventTouchUpInside];

        CGRect xframe = self.detachButton.frame;
        
        switch (attachmentType) {
            case 0:
                self.attachPhotoLabel.text = @"Image Attached";
                self.attachPhotoLabel.alpha = kAlphaDisabled;
                self.attachPhotoIcon.alpha = kAlphaDisabled;
                
                xframe.origin.y = self.attachPhotoLabel.frame.origin.y;
                self.detachButton.frame = xframe;
                self.detachButton.hidden = NO;
                
                
                break;
            case FormType_POLL:
                self.attachPollLabel.text = @"Poll Attached";
                self.attachPollLabel.alpha = kAlphaDisabled;
                self.attachPollIcon.alpha = kAlphaDisabled;
                
                xframe.origin.y = self.attachPollLabel.frame.origin.y;
                self.detachButton.frame = xframe;
                self.detachButton.hidden = NO;
                
                break;
            case FormType_RATING:
                self.attachRatingLabel.text = @"Rating Attached";

                self.attachRatingLabel.alpha = kAlphaDisabled;
                self.attachRatingLabel.alpha = kAlphaDisabled;
                
                xframe.origin.y = self.attachRatingLabel.frame.origin.y;
                self.detachButton.frame = xframe;
                self.detachButton.hidden = NO;
                
                break;
                
            case FormType_RSVP:
                self.attachRSVPLabel.text = @"RSVP Attached";
                self.attachRSVPLabel.alpha = kAlphaDisabled;
                self.attachRSVPIcon.alpha = kAlphaDisabled;
                
                xframe.origin.y = self.attachRSVPLabel.frame.origin.y;
                self.detachButton.frame = xframe;
                self.detachButton.hidden = NO;

                break;
            default:
                break;
        }
    } else {
        self.plusIconsView.hidden = NO;
        self.detachButton.hidden = YES;
        
        self.attachPhotoLabel.text = @"Attach Image";
        self.attachPollLabel.text = @"Add Poll";
        self.attachRatingLabel.text = @"Add Rating";
        self.attachRSVPLabel.text = @"Add RSVP";
        
        self.attachPhotoLabel.alpha = 1.0;
        self.attachPhotoIcon.alpha = 1.0;
        self.attachPollLabel.alpha = 1.0;
        self.attachPollIcon.alpha = 1.0;
        self.attachRatingLabel.alpha = 1.0;
        self.attachRatingIcon.alpha = 1.0;
        self.attachRSVPLabel.alpha = 1.0;
        self.attachRSVPIcon.alpha = 1.0;

        [self.attachPhotoHotspot addTarget:self action:@selector(tapPhotoHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachPollHotspot addTarget:self action:@selector(tapPollHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRatingHotspot addTarget:self action:@selector(tapRatingHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRSVPHotspot addTarget:self action:@selector(tapRSVPHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelHotspot addTarget:self action:@selector(tapCancelHotspot:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}


- (void) tapPhotoHotspot:(id)sender {
    [self hideAttachModal];
    [self showPhotoModal];
}
- (void) tapPollHotspot:(id)sender {
    [DataModel shared].formType = FormType_POLL;
    formTitle = self.attachPollLabel.text;
    [self hideAttachModal];
    
    [self showFormSelector];
    
}
- (void) tapRatingHotspot:(id)sender {
    [DataModel shared].formType = FormType_RATING;
    formTitle = self.attachRatingLabel.text;
    
    [self hideAttachModal];

    [self showFormSelector];

}
- (void) tapRSVPHotspot:(id)sender {
    [DataModel shared].formType = FormType_RSVP;
    formTitle = self.attachRSVPLabel.text;
    
    [self hideAttachModal];

    [self showFormSelector];

}
- (void) tapCancelHotspot:(id)sender {
    self.cancelHotspot.highlighted = YES;
//    self.cancelHotspot.backgroundColor = [UIColor grayColor];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.cancelHotspot.highlighted = NO;
//        self.cancelHotspot.backgroundColor = [UIColor clearColor];
    });
    [self hideAttachModal];
}

#pragma mark - Notifications

- (void)hideFormSelectorNotificationHandler:(NSNotification*)notification
{
    if (notification.object != nil) {
        attachedForm = (FormVO *) notification.object;
        attachmentType = attachedForm.type;
        hasAttachment = YES;
        NSLog(@"Form pick: %@", attachedForm.name);


        switch (attachmentType) {
            case FormType_POLL:
            {
                [self.attachButton setImage:[UIImage imageNamed:kAttachPollIconAqua] forState:UIControlStateNormal];
                break;
            }
            case FormType_RATING:
                [self.attachButton setImage:[UIImage imageNamed:kAttachRatingIconAqua] forState:UIControlStateNormal];
                break;
            case FormType_RSVP:
                [self.attachButton setImage:[UIImage imageNamed:kAttachRSVPIconAqua] forState:UIControlStateNormal];
                break;
        }
        
        
    }
    
    [self hideFormSelector];
}

- (void) insertMessageInChat {
//    [self.bubbleTable becomeFirstResponder];
    
    if (self.inputField.text.length > 0) {
        self.bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:self.inputField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        [bubbleData addObject:sayBubble];
        [self.bubbleTable reloadData];
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
        self.inputField.text = @"";
        
        // Reset frame of chat and input
        self.inputField.frame = inputFrame;
        self.chatBar.frame = chatFrameWithKeyboard;
    }
    // Insert attachment if present. Reset inputs when done
    if (hasAttachment) {

        if (attachedForm != nil) {
            FormManager *formSvc = [[FormManager alloc] init];
            
            NSMutableArray *formOptions = [formSvc listFormOptions:attachedForm.form_id];
            
            //        UIView *embedForm;
            NSBubbleData *formBubble;
            CGRect embedFrame = CGRectMake(0, 0, 240, 300);
            
            switch (attachmentType) {
                case FormType_POLL:
                {
                    EmbedPollWidget *embedWidget = [[EmbedPollWidget alloc] initWithFrame:embedFrame andOptions:formOptions isOwner:NO];
                    embedWidget.subjectLabel.text = attachedForm.name;
                    embedWidget.userInteractionEnabled = YES;
                    embedWidget.tag = 199;
                    
                    NSLog(@"widget height = %f", embedWidget.dynamicHeight);
                    embedFrame.size.height = embedWidget.dynamicHeight;
                    embedWidget.frame = embedFrame;
                    
                    formBubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine insets:UIEdgeInsetsMake(5, 5, 5, 5)];
                    
                    // FIXME: use user avatar image
                    formBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                    break;
                }
                case FormType_RATING:
                {
                    EmbedRatingWidget *embedWidget = [[EmbedRatingWidget alloc] initWithFrame:embedFrame andOptions:formOptions isOwner:NO];
                    embedWidget.subjectLabel.text = attachedForm.name;
                    embedWidget.userInteractionEnabled = YES;
                    embedWidget.tag = 299;
                    
                    NSLog(@"widget height = %f", embedWidget.dynamicHeight);
                    embedFrame.size.height = embedWidget.dynamicHeight;
                    embedWidget.frame = embedFrame;
                    
                    formBubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine insets:UIEdgeInsetsMake(5, 3, 5, 5)];
                    
                    // FIXME: use user avatar image
                    formBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                    
                    break;
                    
                }
                case FormType_RSVP:
                {
                    EmbedRSVPWidget *embedWidget = [[EmbedRSVPWidget alloc] initWithFrame:embedFrame andOptions:formOptions isOwner:NO];
//                    embedWidget.subjectLabel.text = attachedForm.name;
                    embedWidget.whatText.text = attachedForm.description;
                    embedWidget.whereText.text = attachedForm.location;
                    
                    NSDate *dt = [DateTimeUtils readDateFromFriendlyDateTime:attachedForm.start_time];
                
                    embedWidget.dateLabel.text = [DateTimeUtils printDatePartFromDate:dt];
                    embedWidget.timeLabel.text = [DateTimeUtils printTimePartFromDate:dt];
                    embedWidget.whatText.text = attachedForm.description;
                    embedWidget.whereText.text = attachedForm.location;
                    
                    UIImage *img;
                    if (attachedForm.imagefile != nil) {
                        img = [formSvc loadFormImage:attachedForm.imagefile];
                        embedWidget.roundPic.image = img;
                    }
                    
                    embedWidget.userInteractionEnabled = YES;
                    embedWidget.tag = 399;
                    
                    NSLog(@"widget height = %f", embedWidget.dynamicHeight);
                    embedFrame.size.height = embedWidget.dynamicHeight;
                    embedWidget.frame = embedFrame;
                    
                    formBubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine insets:UIEdgeInsetsMake(5, 3, 5, 5)];
                    
                    // FIXME: use user avatar image
                    formBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
                    

                    break;
                }
            }
            
            [bubbleData addObject:formBubble];
            [self.bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
            
        } else if (attachedPhoto != nil && attachmentType == 0) {
            NSBubbleData *photoBubble = [NSBubbleData dataWithImage:attachedPhoto date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            
            // FIXME: use user avatar image
            photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
            
            [bubbleData addObject:photoBubble];
            [self.bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
        }
        CGRect scrollFrame = self.bubbleTable.frame;
        scrollFrame.size.height = [DataModel shared].stageHeight - kChatBarHeight - kScrollViewTop;
        NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
        
        self.bubbleTable.frame = scrollFrame;

        hasAttachment = NO;
        attachedPhoto = nil;
        attachedForm = nil;
        [self.attachButton setImage:[UIImage imageNamed:kAttachPlusIcon] forState:UIControlStateNormal];
    }
}
- (void) resetChatUI {
    
}

@end
