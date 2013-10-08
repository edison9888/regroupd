//
//  NewPollVC.m
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "ChatVC.h"
#import "UIAlertView+Helper.h"
#import "DateTimeUtils.h"
//#import "NSDate+Extensions.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIColor+ColorWithHex.h"


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

#define kTagAttachModalBG 666
#define kTagPhotoModalBG  667

#define kAlphaDisabled  0.8f

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
    self.inputField.delegate = self;
    self.unattachButton.hidden = YES;
    hasAttachment = NO;
    attachmentType = FormType_POLL;
    
    
    chatSvc = [[ChatManager alloc] init];
    
    // Setup table view
    
    CGRect scrollFrame = self.bubbleTable.frame;
    scrollFrame.size.height = [DataModel shared].stageHeight - kChatBarHeight;
    NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
    self.bubbleTable.frame = scrollFrame;
    self.bubbleTable.backgroundColor = [UIColor colorWithHexValue:kChatBGGrey andAlpha:1.0];
    
    CGRect chatFrame = self.chatBar.frame;
    chatFrame.origin.y = [DataModel shared].stageHeight - kChatBarHeight;
    self.chatBar.frame = chatFrame;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImagePickerNotificationHandler:)     name:@"showImagePickerNotification"            object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

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
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"===== %s", __FUNCTION__);
    
    [textView endEditing:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    //    NSLog(@"%s tag=%i", __FUNCTION__, textView.tag);
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if( [text isEqualToString:[text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]] ) {
        return YES;
    } else {
//        NSLog(@"Return key event");
        
        if (textView.text.length > 0) {
            NSBubbleData *sayBubble = [NSBubbleData dataWithText:self.inputField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            [bubbleData addObject:sayBubble];
            [self.bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
            self.inputField.text = @"";
        }
        return NO;
        
    }
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
        
        CGRect frame = self.chatBar.frame;
        frame.origin.y -= kbSize.height;
        self.chatBar.frame = frame;
        
        frame = self.bubbleTable.frame;
        frame.size.height -= kbSize.height + kChatBarHeight;
        
        self.bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"%s", __FUNCTION__);
    keyboardIsShown = NO;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    kbSize.height += kChatBarHeight;
    
    [UIView animateWithDuration:0.1f animations:^{
        
        CGRect frame = self.bubbleTable.frame;
        frame.size.height += kbSize.height;
        self.bubbleTable.frame = frame;

        frame = self.chatBar.frame;
        frame.origin.y += kbSize.height;
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
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                                                  
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


#pragma mark IBActions
- (IBAction)tapCancelButton {
    [_delegate gotoSlideWithName:@"ChatsHome"];
    
}
- (IBAction)tapClearButton {
    NSLog(@"%s", __FUNCTION__);
    
}
- (IBAction)tapAttachButton {
    NSLog(@"%s", __FUNCTION__);
    [self showAttachModal];
    
}
- (IBAction)tapSendButton {
    NSLog(@"%s", __FUNCTION__);
    if (self.inputField.text.length > 0) {
        self.bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:self.inputField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        [bubbleData addObject:sayBubble];
        [self.bubbleTable reloadData];
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
        self.inputField.text = @"";
    }
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
    [self showAttachModal];

    //    [self setupButtonsForEdit];
    
}

#pragma mark - Tap Gestures

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        if (keyboardIsShown) {
            [self.inputField resignFirstResponder];
            [self.inputField endEditing:YES];
            
        } else {
            
            UIView* view = sender.view;
            CGPoint loc = [sender locationInView:view];
            UIView* subview = [view hitTest:loc withEvent:nil];
            CGPoint subloc = [sender locationInView:subview];
            NSLog(@"hit tag = %i at point %f / %f", subview.tag, subloc.x, subloc.y);
            
            switch (subview.tag) {
                case kTagAttachModalBG:
                    [self hideAttachModal];
                    break;
                case kTagPhotoModalBG:
                    [self hidePhotoModal];
                    break;
                    
                    
            }
        }
    }
}

#pragma mark - Hotspot Actions

- (void) setupModalHotspots {
    
    if (hasAttachment) {
        [self.attachPhotoHotspot removeTarget:self action:@selector(tapPhotoHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachPollHotspot removeTarget:self action:@selector(tapPollHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRatingHotspot removeTarget:self action:@selector(tapRatingHotspot:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachRSVPHotspot removeTarget:self action:@selector(tapRSVPHotspot:) forControlEvents:UIControlEventTouchUpInside];

        switch (attachmentType) {
            case 0:
                self.attachPhotoLabel.text = @"Image Attached";
                self.attachPhotoLabel.alpha = kAlphaDisabled;
                self.attachPhotoIcon.alpha = kAlphaDisabled;
                
                break;
            case FormType_POLL:
                self.attachPollLabel.text = @"Poll Attached";
                self.attachPollLabel.alpha = kAlphaDisabled;
                self.attachPollIcon.alpha = kAlphaDisabled;
                
                break;
            case FormType_RATING:
                self.attachPhotoLabel.text = @"Rating Attached";
                
                break;
                
            case FormType_RSVP:
                self.attachPhotoLabel.text = @"RSVP Attached";

                break;
            default:
                break;
        }
    } else {
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
    [self hideAttachModal];
}
- (void) tapRatingHotspot:(id)sender {
    [self hideAttachModal];
}
- (void) tapRSVPHotspot:(id)sender {
    [self hideAttachModal];
}
- (void) tapCancelHotspot:(id)sender {
    self.cancelHotspot.highlighted = YES;
    self.cancelHotspot.backgroundColor = [UIColor grayColor];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.cancelHotspot.highlighted = NO;
        self.cancelHotspot.backgroundColor = [UIColor clearColor];
    });
    [self hideAttachModal];
}


@end
