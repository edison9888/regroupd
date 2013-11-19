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
#import "ChatMessageWidget.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIColor+ColorWithHex.h"

#define kMinInputHeight 40
#define kMaxInputHeight 93


@interface ChatVC ()
{
    //    IBOutlet UIBubbleTableView *bubbleTable;
    
    NSMutableArray *tableDataSource;
}

@end

@implementation ChatVC

@synthesize tableDataSource;
@synthesize bubbleTable;

#define kFirstOptionId  1
#define kScrollViewTop 50
#define kChatBarHeight 50

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
    
    chatId = [DataModel shared].chat.system_id;
    
    if ([DataModel shared].chat.names != nil && [DataModel shared].chat.names.length > 0) {
        self.navTitle.text = [DataModel shared].chat.names;
        
    }
    
    msgTimeFormat = [[NSDateFormatter alloc] init];
    [msgTimeFormat setDateFormat:@"hh:mm"];
    
    
    inputHeight = 0;
    theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];
    
    self.inputField.delegate = self;
    self.detachButton.hidden = YES;
    hasAttachment = NO;
    attachmentType = FormType_POLL;
    
    chatSvc = [[ChatManager alloc] init];
    contactSvc = [[ContactManager alloc] init];
    formSvc = [[FormManager alloc] init];
    
    // Setup table view
    
    CGRect scrollFrame = self.bubbleTable.frame;
    scrollFrame.size.height = [DataModel shared].stageHeight - kChatBarHeight - kScrollViewTop;
    self.bubbleTable.frame = scrollFrame;
    self.bubbleTable.backgroundColor = [UIColor colorWithHexValue:kChatBGGrey andAlpha:1.0];
    self.bubbleTable.userInteractionEnabled = YES;
    
    
    chatFrame = self.chatBar.frame;
    chatFrame.origin.y = [DataModel shared].stageHeight - kChatBarHeight;
    self.chatBar.frame = chatFrame;
    
    inputFrame = self.inputField.frame;
    [self.inputField setContentInset:UIEdgeInsetsMake(0.0, 4.0, 0.0, -10.0)];
    
    
    // Keyboard events
    // Setup notifications
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideFormSelectorNotificationHandler:)     name:@"hideFormSelectorNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImagePickerNotificationHandler:)     name:@"showImagePickerNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImagePickerNotificationHandler:)     name:@"showImagePickerNotification"
                                               object:nil];
    
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
    
    drawerMinTop = self.topDrawer.frame.origin.y;
    drawerMaxTop = 0;
    
    [self loadChatMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadChatMessages
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading"];
    [self.hud setDimBackground:YES];
    
    // Setup chat bubble config
    
    self.bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    self.bubbleTable.snapInterval = 86400;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    self.bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    //    self.bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessagesLoadedHandler:) name:k_chatMessagesLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatContactsLoadedHandler:) name:k_chatContactsLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatPushNotificationHandler:) name:k_chatPushNotificationReceived object:nil];
    
    if ([DataModel shared].chat != nil) {
        // Auto subscribe user to push notifications for this chat objectId
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[DataModel shared].chat.system_id forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        NSLog(@"Fetch chat by objectId %@", [DataModel shared].chat.system_id);
        [chatSvc apiListChatForms:[DataModel shared].chat.system_id callback:^(NSArray *results) {
            // Each result is a ChatFormDB object with relational values: form and chat
            formCache = [[NSMutableDictionary alloc]init];
            __block int index=0;
            int total = results.count;
            
            if (results.count > 0) {
                for (PFObject *result in results) {
                    if (result[@"form"]) {
                        PFObject *pfForm = result[@"form"];
                        NSLog(@">>>>>>>>>>>>>> Found form %@", pfForm.objectId);
                        
                        [formSvc apiLoadForm:pfForm.objectId fetchAll:YES callback:^(FormVO *form) {
                            if (form) {
                                [formCache setObject:form forKey:pfForm.objectId];
                            }
                            
                            index++;
                            if (index==total) {
                                [chatSvc asyncListChatMessages:[DataModel shared].chat.system_id];
                            }
                        }];
                    }
                }
                
            } else {
                
                [chatSvc asyncListChatMessages:[DataModel shared].chat.system_id];
                
            }
        }];
        
        
    }
    
    
    
}

#pragma mark - Notifications
- (void)chatMessagesLoadedHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    @try {
        if (notification.object != nil) {
            ChatVO *theChat = (ChatVO *) notification.object;
            
            tableDataSource = [[NSMutableArray alloc] init];
            self.imageMap = [[NSMutableDictionary alloc] initWithCapacity:theChat.contact_keys.count];
            
            
            int keycount = theChat.contact_keys.count;
            __block int counter = 0;
            //            theChat.contactMap.ke
            for (NSString *key in theChat.contact_keys) {
                
                [contactSvc asyncLoadCachedPhoto:key callback:^(UIImage *img) {
                    if (img) {
                        NSLog(@"Setting image for key %@", key);
                        [self.imageMap setObject:img forKey:key];
                    } else {
                        NSLog(@"No image for key %@", key);
                    }
                    counter++;
                    if (counter == keycount) {
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_chatContactsLoaded object:theChat]];
                        //                            [self.bubbleTable reloadData];
                    }
                }];
            }
            
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"########### Exception %@", exception);
    }
    
    
}
- (void)chatContactsLoadedHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    NSBubbleData *bubble;
    if (notification.object) {
        ChatVO *theChat = (ChatVO *) notification.object;
        int index = 0;
//        for (ChatMessageVO* msg in theChat.messages) {
//            index++;
//            NSLog(@"%i grouped message %@", index, msg.message);
//            if (msg.form_key == nil) {
//                bubble = [self buildMessageBubble:msg];
//                
//            } else {
//                bubble = [self buildMessageWidget:msg];
//            }
//            if (bubble == nil) {
//                NSLog(@"bubble is nil");
//            } else {
//                [tableDataSource addObject:bubble];
//            }
//        }

        
        NSMutableArray *groupedMessages = [self consolidateChatMessages:theChat.messages];
        NSLog(@"Grouped messages count %i", groupedMessages.count);
        for (ChatMessageVO* msg in groupedMessages) {
            index++;
            NSLog(@"%i grouped message %@", index, msg.message);
            if (msg.form_key == nil) {
                bubble = [self buildMessageBubble:msg];
                
            } else {
                bubble = [self buildMessageWidget:msg];
            }
            if (bubble == nil) {
                NSLog(@"bubble is nil");
            } else {
                [tableDataSource addObject:bubble];
            }
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSLog(@"Ready to reload table");
    [self.bubbleTable reloadData];
    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    
    
}
- (void)chatPushNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    if (notification.object) {
        ChatMessageVO *msg = (ChatMessageVO *) notification.object;
        
        if ([msg.chat_key isEqualToString:chatId]) {
            
            [chatSvc asyncListChatMessages:[DataModel shared].chat.system_id];
            
            
        } else {
            NSLog(@"Message for another chat %@", msg.chat_key);
        }
    }
    
}

#pragma mark - private helper methods

- (NSMutableArray *) consolidateChatMessages:(NSMutableArray *)messages {
    int index = 0;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    // need array as list of keys
    NSMutableDictionary *dialogueMap = [[NSMutableDictionary alloc] init];
    ChatMessageVO *lastMessage;
    NSString *lastKey = @"";
    //    NSString *msgtext;
    //    ChatMessageVO *longMsg;
    
    NSString *currentText;
    NSNumber *countKey;
    if (messages.count > 0) {
        /*
         capture message text if same speaker.
         Q: are messages losing createdAt date?
         
         Remove whitespace
         
         */
        for (ChatMessageVO *msg in messages) {
            countKey = [NSNumber numberWithInt:index];
            if (msg.pfPhoto != nil) {
                
                lastMessage.message = currentText;
                [dialogueMap setObject:lastMessage forKey:countKey];
                //                [(ChatMessageVO *)[dialogueMap objectForKey:countKey]].message = currentText;
                lastMessage = msg;
                index++;
            } else if (msg.form_key != nil) {
                // Embedded form.
                lastMessage.message = currentText;
                [dialogueMap setObject:lastMessage forKey:countKey];
                //                [(ChatMessageVO *)[dialogueMap objectForKey:countKey]].message = currentText;
                lastMessage = msg;
                index++;
                
            } else if ([msg.contact_key isEqualToString:lastKey]) {
                // continue with last speaker
                NSString *addText = nil;
                
                if (msg.message == nil) {
                    addText = @"";
                } else {
                    addText = msg.message;
                }
                currentText = [[currentText stringByAppendingString:@"\n"] stringByAppendingString:addText];
                
            } else {
                // new speaker. saved currentText for last person
                // If lastKey == "", then initialize lastMessage
                if ([lastKey isEqualToString:@""]) {
                    // First pass. initialize lastMessage
                    lastMessage = msg;
                    currentText = msg.message;
                    
                } else {
                    //                ChatMessageVO *theMsg = (ChatMessageVO *)[dialogueMap objectForKey:countKey];
                    //                NSLog(@"currentText = %@", currentText);
                    lastMessage.message = currentText;
                    [dialogueMap setObject:lastMessage forKey:countKey];
                    //                [(ChatMessageVO *)[dialogueMap objectForKey:countKey]].message = currentText;
                    lastMessage = msg;
                    currentText = msg.message;
                    index++;
                }
                lastKey = msg.contact_key;
                
            }
            
        }
        lastMessage.message = currentText;
        [dialogueMap setObject:lastMessage forKey:countKey];
    }
    //    NSLog(@"currentText = %@", currentText);
    
    for (int i=0;i<dialogueMap.count; i++) {
        NSNumber *indexKey = [NSNumber numberWithInt:i];
        ChatMessageVO *aMsg = (ChatMessageVO *)[dialogueMap objectForKey:indexKey];
        [results addObject:aMsg];
    }
    
    return results;
}

- (NSBubbleData *) buildMessageBubble:(ChatMessageVO *)msg {
    CGRect msgFrame = CGRectMake(0, 0, 240, 80);
    NSBubbleData *bubble;
    //    UIImage *img = nil;
    NSString *timeValue;
    NSString *nameValue;
    UIEdgeInsets viewInset;
    if ([msg.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
        if (msg.pfPhoto == nil) {
            viewInset = UIEdgeInsetsMake(2, 5, 2, 5);
        } else {
            viewInset = UIEdgeInsetsMake(5, 5, 5, 5);
        }
        // my message
        ChatMessageWidget *msgView = [[ChatMessageWidget alloc] initWithFrame:msgFrame message:msg isOwner:YES];
        msgView.tag = 188;
        
        NSLog(@"widget height = %f", msgView.dynamicHeight);
        msgFrame.size.height = msgView.dynamicHeight;
        msgView.frame = msgFrame;
        msgView.timeLabel.text = [msgTimeFormat stringFromDate:msg.createdAt];
        
        //        bubble = [NSBubbleData dataWithView:msgView date:msg.createdAt type:BubbleTypeMine insets:UIEdgeInsetsMake(2, 5, 2, 5)];
        bubble = [NSBubbleData dataWithView:msgView date:msg.createdAt type:BubbleTypeMine insets:viewInset];
        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
    } else {
        // someone else
        if (msg.pfPhoto == nil) {
            viewInset = UIEdgeInsetsMake(2, 10, 2, 0);
        } else {
            viewInset = UIEdgeInsetsMake(5, 10, 5, 0);
        }
        
        nameValue = (NSString *) [[DataModel shared].chat.namesMap objectForKey:msg.contact_key];
        
        ChatMessageWidget *msgView = [[ChatMessageWidget alloc] initWithFrame:msgFrame message:msg isOwner:NO];
        msgView.tag = 188;
        
        NSLog(@"widget height = %f", msgView.dynamicHeight);
        msgFrame.size.height = msgView.dynamicHeight;
        msgView.frame = msgFrame;
        msgView.nameLabel.text = nameValue;
        
        timeValue = [msgTimeFormat stringFromDate:msg.createdAt];
        msgView.timeLabel.text = timeValue;
        
        //        bubble = [NSBubbleData dataWithView:msgView date:msg.createdAt type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(2, 10, 2, 0)];
        bubble = [NSBubbleData dataWithView:msgView date:msg.createdAt type:BubbleTypeSomeoneElse insets:viewInset];
        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
    }
    return bubble;
}

- (NSBubbleData *) buildMessageWidget:(ChatMessageVO *)msg {
    CGRect msgFrame;
    NSBubbleData *bubble;
    NSString *timeValue;
    NSString *nameValue;
    
    // @@@@@@@@@@@@@@@@@@@@@ RESUME HERE @@@@@@@@@@@@@@@@@@@@@@@@@@@@
    // GET form_key and lookup in formCache
    FormVO *theForm = [formCache objectForKey:msg.form_key];
    if (theForm == nil) {
        NSLog(@"Cache lookup failed!!! >>>>>>>>>>>> %@", msg.form_key);
        return nil;
    }
    NSBubbleType whoType;
    BOOL isOwner;
    UIEdgeInsets viewInset;
    
    if ([msg.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
        msgFrame = CGRectMake(0, 0, 240, 80);
        whoType = BubbleTypeMine;
        isOwner = YES;
        viewInset = UIEdgeInsetsMake(5, 2, 5, 8);
        nameValue = @"Me";
    } else {
        msgFrame = CGRectMake(0, 0, 240, 80);
        whoType = BubbleTypeSomeoneElse;
        isOwner = NO;
        viewInset = UIEdgeInsetsMake(5, 15, 5, -5);
        nameValue = (NSString *) [[DataModel shared].chat.namesMap objectForKey:msg.contact_key];
    }
    
    timeValue = [msgTimeFormat stringFromDate:msg.createdAt];
    
    if (theForm.type == FormType_POLL) {
        EmbedPollWidget *embedWidget = [[EmbedPollWidget alloc] initWithFrame:msgFrame andOptions:theForm.options isOwner:isOwner];
        embedWidget.subjectLabel.text = theForm.name;
        embedWidget.userInteractionEnabled = YES;
        embedWidget.tag = 199;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:whoType insets:viewInset];
        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        return bubble;
        
    } else if (theForm.type == FormType_RATING) {
        EmbedRatingWidget *embedWidget = [[EmbedRatingWidget alloc] initWithFrame:msgFrame andOptions:theForm.options isOwner:isOwner];
        embedWidget.subjectLabel.text = theForm.name;
        embedWidget.userInteractionEnabled = YES;
        embedWidget.tag = 299;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:whoType insets:viewInset];
        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        return bubble;
        
    } else if (theForm.type == FormType_RSVP) {
        EmbedRSVPWidget *embedWidget = [[EmbedRSVPWidget alloc] initWithFrame:msgFrame andOptions:theForm.options isOwner:isOwner];
        //                    embedWidget.subjectLabel.text = attachedForm.name;
        
        NSDate *dt = [DateTimeUtils readDateFromFriendlyDateTime:theForm.start_time];
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        embedWidget.eventDateLabel.text = [DateTimeUtils printDatePartFromDate:dt];
        embedWidget.eventTimeLabel.text = [DateTimeUtils printTimePartFromDate:dt];
        embedWidget.whatText.text = theForm.description;
        embedWidget.whereText.text = theForm.location;
        
        if (theForm.pfPhoto != nil) {
            embedWidget.roundPic.file = theForm.pfPhoto;
            [embedWidget.roundPic loadInBackground];
        }
        
        embedWidget.userInteractionEnabled = YES;
        embedWidget.tag = 399;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:whoType insets:viewInset];
        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        return bubble;
        
    }
    return nil;
}
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
        
        if (formSvc == nil) {
            formSvc = [[FormManager alloc] init];
        }
        [formSvc apiListFormOptions:attachedForm.system_id callback:^(NSArray *results) {
            attachedForm.options = [[NSMutableArray alloc] initWithCapacity:results.count];
            FormOptionVO *option;
            
            for (PFObject *result in results) {
                option = [FormOptionVO readFromPFObject:result];
                [attachedForm.options addObject:option];
            }
            [self hideFormSelector];
        }];
        
    } else {
        [self hideFormSelector];
        
    }
    
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    NSLog(@"rowsForBubbleTable %i", [tableDataSource count]);
    return [tableDataSource count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    NSLog(@"bubbleTableView dataForRow %i",row);
    return [tableDataSource objectAtIndex:row];
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
    
    //    NSLog(@"inputHeight %f // newsize %f", inputHeight, newsize);
    
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
    
    //    if( [text isEqualToString:[text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]] ) {
    //        return YES;
    //
    //    } else {
    //        NSLog(@"Return key event");
    //        [self insertMessageInChat];
    //
    //        return NO;
    //
    //    }
    return YES;
}

//- (CGSize)determineSize:(NSString *)text constrainedToSize:(CGSize)size
//{
//
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        CGRect frame = [text boundingRectWithSize:size
//                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
//                                       attributes:@{NSFontAttributeName:theFont}
//                                          context:nil];
//        return frame.size;
//    } else {
//        return [text sizeWithFont:theFont constrainedToSize:size];
//    }
//}
//- (CGFloat)textViewHeightForAttributedText:(NSAttributedString*)text andWidth:(CGFloat)width
//{
//    UITextView *calculationView = [[UITextView alloc] init];
//    [calculationView setAttributedText:text];
//    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
//    return size.height;
//}


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
        //        frame.size.height = chatFrameWithKeyboard.origin.y - kChatBarHeight - kScrollViewTop;
        frame.size.height -= kbSize.height;
        
        self.bubbleTable.frame = frame;
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
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
    [chatSvc asyncListChatMessages:[DataModel shared].chat.system_id];
    
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

- (void)handlePull:(UIPanGestureRecognizer *)sender {
    
    // SEE http://www.raywenderlich.com/6567/uigesturerecognizer-tutorial-in-ios-5-pinches-pans-and-more
    CGPoint translation = [sender translationInView:self.view];
    float ypos = sender.view.center.y - (sender.view.frame.size.height / 2);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint targetPoint;
        if (ypos - drawerMinTop < drawerMaxTop - ypos) {
            // Slide back up
            targetPoint = CGPointMake(sender.view.center.x, drawerMinTop + (sender.view.frame.size.height / 2));
            
        } else {
            targetPoint = CGPointMake(sender.view.center.x, drawerMaxTop + (sender.view.frame.size.height / 2));
            // Slide back down
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            sender.view.center = targetPoint;
        } completion:nil];
        
    } else {
        // Height of blue tab is 20px so use 10 as offset from center
        
        if (ypos + translation.y >= drawerMinTop && ypos + translation.y <= drawerMaxTop) {
            sender.view.center = CGPointMake(sender.view.center.x,
                                             sender.view.center.y + translation.y);
        }
    }
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    //    }
    
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

#pragma mark - Chat message handling

- (void) insertMessageInChat {
    //    [self.bubbleTable becomeFirstResponder];
    if (!hasAttachment) {
        if (self.inputField.text.length > 0) {
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            msg.message = self.inputField.text;
            msg.contact_key = [DataModel shared].user.contact_key;
            msg.chat_key = chatId;
            
            [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                NSBubbleData *bubble;
                bubble = [self buildMessageBubble:msg];
                
                [tableDataSource addObject:bubble];
                [self.bubbleTable reloadData];
                [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
                
                self.inputField.text = @"";
                
                //                // Reset frame of chat and input
                //                self.inputField.frame = inputFrame;
                //                self.chatBar.frame = chatFrameWithKeyboard;
                
                // Build a target query: everyone in the chat room except for this device.
                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                PFQuery *query = [PFInstallation query];
                [query whereKey:@"channels" equalTo:chatId];
                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
                
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      msg.message, @"alert",
                                      @"Increment", @"badge",
                                      msg.contact_key, @"contact",
                                      chatId, @"chat",
                                      pfMessage.objectId, @"msg",
                                      nil];
                // Create time interval
                NSTimeInterval interval = 60*60*24*7; // 1 week
                
                // Send push notification with expiration interval
                PFPush *push = [[PFPush alloc] init];
                [push expireAfterTimeInterval:interval];
                [push setQuery:query];
                //            [push setChannel:chatId];
                //            [push setMessage:chatId];
                [push setData:data];
                [push sendPushInBackground];
            }];
            //        [chatSvc apiSaveChatMessage:msg];
        }
        
    }
    // Insert attachment if present. Reset inputs when done
    if (hasAttachment) {
        
        if (attachedForm != nil) {
            
            [formCache setObject:attachedForm forKey:attachedForm.system_id];
            
            // ################# PARSE SAVE ##################
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            
            msg.contact_key = [DataModel shared].user.contact_key;
            msg.chat_key = chatId;
            msg.form_key = attachedForm.system_id;
            
            if (self.inputField.text.length > 0) {
                msg.message = self.inputField.text;
            }
            
            NSBubbleData *bubble;
            
            bubble = [self buildMessageWidget:msg];
            
            [tableDataSource addObject:bubble];
            [self.bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
            [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                if (pfMessage) {
                    [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
                        // Build a target query: everyone in the chat room except for this device.
                        // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                        PFQuery *query = [PFInstallation query];
                        [query whereKey:@"channels" equalTo:chatId];
                        //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
                        
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                              msg.message, @"alert",
                                              msg.contact_key, @"contact",
                                              chatId, @"chat",
                                              pfMessage.objectId, @"msg",
                                              nil];
                        // Create time interval
                        NSTimeInterval interval = 60*60*24*7; // 1 week
                        
                        // Send push notification with expiration interval
                        PFPush *push = [[PFPush alloc] init];
                        [push expireAfterTimeInterval:interval];
                        [push setQuery:query];
                        //            [push setChannel:chatId];
                        //            [push setMessage:chatId];
                        [push setData:data];
                        [push sendPushInBackground];
                    }];
                } else {
                    NSLog(@"Chat message was not saved");
                }
            }];
            
            
            // ######################################################################### DELETE BELOW
            
            //
            //            switch (attachmentType) {
            //                case FormType_POLL:
            //                {
            //
            //
            //                    [formCache setObject:attachedForm forKey:attachedForm.system_id];
            //
            //                    // ################# PARSE SAVE ##################
            //                    ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            //
            //                    msg.contact_key = [DataModel shared].user.contact_key;
            //                    msg.chat_key = chatId;
            //                    msg.form_key = attachedForm.system_id;
            //
            //                    if (self.inputField.text.length > 0) {
            //                        msg.message = self.inputField.text;
            //                    }
            //
            //                    NSBubbleData *bubble;
            //
            //                    bubble = [self buildMessageWidget:msg];
            //
            //                    [tableDataSource addObject:bubble];
            //                    [self.bubbleTable reloadData];
            //                    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            //
            //                    [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
            //                        if (pfMessage) {
            //                            [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
            //                                // Build a target query: everyone in the chat room except for this device.
            //                                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
            //                                PFQuery *query = [PFInstallation query];
            //                                [query whereKey:@"channels" equalTo:chatId];
            //                                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
            //
            //                                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
            //                                                      msg.message, @"alert",
            //                                                      msg.contact_key, @"contact",
            //                                                      chatId, @"chat",
            //                                                      pfMessage.objectId, @"msg",
            //                                                      nil];
            //                                // Create time interval
            //                                NSTimeInterval interval = 60*60*24*7; // 1 week
            //
            //                                // Send push notification with expiration interval
            //                                PFPush *push = [[PFPush alloc] init];
            //                                [push expireAfterTimeInterval:interval];
            //                                [push setQuery:query];
            //                                //            [push setChannel:chatId];
            //                                //            [push setMessage:chatId];
            //                                [push setData:data];
            //                                [push sendPushInBackground];
            //                            }];
            //                        } else {
            //                            NSLog(@"Chat message was not saved");
            //                        }
            //                    }];
            //
            //
            //                    break;
            //                }
            //                case FormType_RATING:
            //                {
            //                    [formCache setObject:attachedForm forKey:attachedForm.system_id];
            //
            //                    // ################# PARSE SAVE ##################
            //                    ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            //
            //                    msg.contact_key = [DataModel shared].user.contact_key;
            //                    msg.chat_key = chatId;
            //                    msg.form_key = attachedForm.system_id;
            //
            //                    if (self.inputField.text.length > 0) {
            //                        msg.message = self.inputField.text;
            //                    }
            //
            //                    NSBubbleData *bubble;
            //
            //                    bubble = [self buildMessageWidget:msg];
            //
            //                    [tableDataSource addObject:bubble];
            //                    [self.bubbleTable reloadData];
            //                    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            //
            //                    [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
            //                        if (pfMessage) {
            //                            [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
            //                                // Build a target query: everyone in the chat room except for this device.
            //                                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
            //                                PFQuery *query = [PFInstallation query];
            //                                [query whereKey:@"channels" equalTo:chatId];
            //                                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
            //
            //                                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
            //                                                      msg.message, @"alert",
            //                                                      msg.contact_key, @"contact",
            //                                                      chatId, @"chat",
            //                                                      pfMessage.objectId, @"msg",
            //                                                      nil];
            //                                // Create time interval
            //                                NSTimeInterval interval = 60*60*24*7; // 1 week
            //
            //                                // Send push notification with expiration interval
            //                                PFPush *push = [[PFPush alloc] init];
            //                                [push expireAfterTimeInterval:interval];
            //                                [push setQuery:query];
            //                                //            [push setChannel:chatId];
            //                                //            [push setMessage:chatId];
            //                                [push setData:data];
            //                                [push sendPushInBackground];
            //                            }];
            //                        } else {
            //                            NSLog(@"Chat message was not saved");
            //                        }
            //                    }];
            //
            //
            //                    break;
            //
            //                }
            //                case FormType_RSVP:
            //                {
            //                    [formCache setObject:attachedForm forKey:attachedForm.system_id];
            //
            //                    // ################# PARSE SAVE ##################
            //                    ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            //
            //                    msg.contact_key = [DataModel shared].user.contact_key;
            //                    msg.chat_key = chatId;
            //                    msg.form_key = attachedForm.system_id;
            //
            //                    if (self.inputField.text.length > 0) {
            //                        msg.message = self.inputField.text;
            //                    }
            //
            //                    NSBubbleData *bubble;
            //
            //                    bubble = [self buildMessageWidget:msg];
            //
            //                    [tableDataSource addObject:bubble];
            //                    [self.bubbleTable reloadData];
            //                    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            //
            //                    [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
            //                        if (pfMessage) {
            //                            [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
            //                                // Build a target query: everyone in the chat room except for this device.
            //                                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
            //                                PFQuery *query = [PFInstallation query];
            //                                [query whereKey:@"channels" equalTo:chatId];
            //                                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
            //
            //                                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
            //                                                      msg.message, @"alert",
            //                                                      msg.contact_key, @"contact",
            //                                                      chatId, @"chat",
            //                                                      pfMessage.objectId, @"msg",
            //                                                      nil];
            //                                // Create time interval
            //                                NSTimeInterval interval = 60*60*24*7; // 1 week
            //
            //                                // Send push notification with expiration interval
            //                                PFPush *push = [[PFPush alloc] init];
            //                                [push expireAfterTimeInterval:interval];
            //                                [push setQuery:query];
            //                                //            [push setChannel:chatId];
            //                                //            [push setMessage:chatId];
            //                                [push setData:data];
            //                                [push sendPushInBackground];
            //                            }];
            //                        } else {
            //                            NSLog(@"Chat message was not saved");
            //                        }
            //                    }];
            //
            ////                    EmbedRSVPWidget *embedWidget = [[EmbedRSVPWidget alloc] initWithFrame:embedFrame andOptions:attachedFormOptions isOwner:NO];
            ////                    //                    embedWidget.subjectLabel.text = attachedForm.name;
            ////                    embedWidget.whatText.text = attachedForm.description;
            ////                    embedWidget.whereText.text = attachedForm.location;
            ////
            ////                    NSDate *dt = [DateTimeUtils readDateFromFriendlyDateTime:attachedForm.start_time];
            ////
            ////                    embedWidget.eventDateLabel.text = [DateTimeUtils printDatePartFromDate:dt];
            ////                    embedWidget.eventTimeLabel.text = [DateTimeUtils printTimePartFromDate:dt];
            ////                    embedWidget.whatText.text = attachedForm.description;
            ////                    embedWidget.whereText.text = attachedForm.location;
            ////
            ////                    UIImage *img;
            ////                    if (attachedForm.imagefile != nil) {
            ////                        img = [formSvc loadFormImage:attachedForm.imagefile];
            ////                        embedWidget.roundPic.image = img;
            ////                    }
            ////
            ////                    embedWidget.userInteractionEnabled = YES;
            ////                    embedWidget.tag = 399;
            ////
            ////                    NSLog(@"widget height = %f", embedWidget.dynamicHeight);
            ////                    embedFrame.size.height = embedWidget.dynamicHeight;
            ////                    embedWidget.frame = embedFrame;
            ////
            ////                    formBubble = [NSBubbleData dataWithView:embedWidget date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine insets:UIEdgeInsetsMake(5, 3, 5, 5)];
            ////
            ////                    formBubble.avatar = (UIImage *)[self.imageMap objectForKey:[DataModel shared].user.contact_key];
            //
            //
            //                    break;
            //                }
            //            }
            
            
        } else if (attachedPhoto != nil && attachmentType == 0) {
            //            NSBubbleData *photoBubble = [NSBubbleData dataWithImage:attachedPhoto date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            //            
            //            // FIXME: use user avatar image
            //            photoBubble.avatar = (UIImage *)[self.imageMap objectForKey:[DataModel shared].user.contact_key];
            //            
            //            [tableDataSource addObject:photoBubble];
            //            [self.bubbleTable reloadData];
            //            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            
            if (self.inputField.text.length > 0) {
                msg.message = self.inputField.text;
            }
            msg.contact_key = [DataModel shared].user.contact_key;
            msg.chat_key = chatId;
            msg.photo = attachedPhoto;
            NSBubbleData *bubble;
            bubble = [self buildMessageBubble:msg];
            
            [tableDataSource addObject:bubble];
            [self.bubbleTable reloadData];
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            
            [chatSvc apiSaveChatMessage:msg withPhoto:attachedPhoto callback:^(PFObject *pfMessage) {
                
                // Build a target query: everyone in the chat room except for this device.
                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                PFQuery *query = [PFInstallation query];
                [query whereKey:@"channels" equalTo:chatId];
                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      msg.message, @"alert",
                                      msg.contact_key, @"contact",
                                      chatId, @"chat",
                                      pfMessage.objectId, @"msg",
                                      nil];
                // Create time interval
                NSTimeInterval interval = 60*60*24*7; // 1 week
                
                // Send push notification with expiration interval
                PFPush *push = [[PFPush alloc] init];
                [push expireAfterTimeInterval:interval];
                [push setQuery:query];
                //            [push setChannel:chatId];
                //            [push setMessage:chatId];
                [push setData:data];
                [push sendPushInBackground];
            }];
            
        }
        CGRect scrollFrame = self.bubbleTable.frame;
        scrollFrame.size.height = [DataModel shared].stageHeight - kChatBarHeight - kScrollViewTop;
        NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
        
        self.bubbleTable.frame = scrollFrame;
        
        self.inputField.text = @"";
        hasAttachment = NO;
        attachedPhoto = nil;
        attachedForm = nil;
        [self.attachButton setImage:[UIImage imageNamed:kAttachPlusIcon] forState:UIControlStateNormal];
    }
}
- (void) resetChatUI {
    
}

@end
