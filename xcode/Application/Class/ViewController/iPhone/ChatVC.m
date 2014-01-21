//
//  ChatVC
//  Re:group'd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "ChatVC.h"
#import <QuartzCore/QuartzCore.h>

#import "DataModel.h"
#import "Constants.h"

#import "UIAlertView+Helper.h"
#import "UIImage+Resize.h"

#import "DateTimeUtils.h"
#import "EmbedPollWidget.h"
#import "EmbedRatingWidget.h"
#import "EmbedRSVPWidget.h"
#import "ChatMessageWidget.h"

#import "PollDetailVC.h"
#import "RatingDetailVC.h"
#import "RSVPDetailVC.h"

#import "EditPollVC.h"
#import "EditRatingVC.h"
#import "EditRSVPVC.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIColor+ColorWithHex.h"

#define kMinInputHeight 40
#define kMaxInputHeight 93

#define kAlertClearMessages 2
#define kAlertClearMessages 2

#define kBaseTagForNameWidget   900


@interface ChatVC ()
{
}

@end

@implementation ChatVC

@synthesize tableDataSource;
@synthesize bubbleTable;


#define kFirstOptionId  1
#define kScrollViewTop 50
#define kChatBarHeight 50
#define kDrawerHeight 180
#define kDrawerItemsStartX 10
#define kDrawerItemsStartY 55
#define kCreateLinkWidth 120

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

#define kDetailsNotPublic   @"Whoops! These results are private."

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
    chatTitle = [DataModel shared].chat.names;
    dbChat = [DataModel shared].chat;
    
    if (chatTitle != nil && chatTitle.length > 0) {
        self.navTitle.text = chatTitle;
        
    }
    
    
    msgTimeFormat = [[NSDateFormatter alloc] init];
    [msgTimeFormat setDateFormat:@"h:mm a"];
    //    [msgTimeFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    
    inputHeight = 0;
    
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
    defaultChatFrameHeight = chatFrame.size.height;
    inputFrame = self.inputField.frame;
    
    defaultInputFrameHeight = inputFrame.size.height;
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
                                             selector:@selector(formResponseEnteredHandler:)     name:k_formResponseEntered
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFormDetailsHandler:)     name:k_showFormDetails
                                               object:nil];
    
    // Create and initialize a tap gesture
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.tableDataSource = [[NSMutableArray alloc] init];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatPushNotificationHandler:) name:k_chatPushNotificationReceived object:nil];
    
    
    /*
     http://stackoverflow.com/questions/6672677/how-to-use-uipangesturerecognizer-to-move-object-iphone-ipad
     */
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSString *channelId = [@"chat_" stringByAppendingString:chatId];
    //        [currentInstallation addUniqueObject:[DataModel shared].chat.system_id forKey:@"channels"];
    [currentInstallation addUniqueObject:channelId forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    [chatSvc apiLoadChat:chatId callback:^(ChatVO *chat) {
        liveChat = chat;
        [self loadChatMessages];
    }];
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

#pragma mark - Data loaders

- (void) loadChatMessages
{
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self.hud setLabelText:@"Loading"];
//    [self.hud setDimBackground:YES];
    
    //        dbChat = [chatSvc loadChatByKey:chatId];
    //        if (dbChat == nil) {
    //
    //        } else {
    //            if (dbChat.clear_timestamp && dbChat.clear_timestamp.doubleValue > 0) {
    //
    //            }
    //        }
    
    // Auto subscribe user to push notifications for this chat objectId
    
    formCache = [[NSMutableDictionary alloc]init];
    [self.tableDataSource removeAllObjects];
    
    dbChat = [chatSvc loadChatByKey:chatId];
    
    NSLog(@"Fetching chat %@ with cutoffDate %@", chatId, dbChat.cutoffDate);
    [chatSvc apiListChatMessages:chatId afterDate:dbChat.cutoffDate callback:^(NSArray *results) {
        
        if (results.count > 0) {
            contactKeySet = [[NSMutableSet alloc] init];
            formKeySet = [[NSMutableSet alloc] init];
            
            //            self.imageMap = [[NSMutableDictionary alloc] initWithCapacity:liveChat.contact_keys.count];
            liveChat.messages = [results mutableCopy];
            for (ChatMessageVO *msg in liveChat.messages) {
                [contactKeySet addObject:msg.contact_key];
                if (msg.form_key && msg.form_key.length > 0) {
                    [formKeySet addObject:msg.form_key];
                }
            }
            __block int index=0;
            int total = contactKeySet.count;
            for (NSString *contactKey in contactKeySet) {
                [contactSvc apiLoadContact:contactKey callback:^(PFObject *pfContact) {
                    ContactVO *contact;
                    if (pfContact) {
                        contact = [ContactVO readFromPFObject:pfContact];
                        [[DataModel shared].contactCache setObject:contact forKey:contactKey];
                    }
                    index++;
                    if (index == total) {
                        [self loadFormData];
                    }
                }];
            }
            
        } else {
            liveChat.messages = [results mutableCopy];
            [self renderChatMessages:liveChat];
            
        }
        
    }];
}


- (void) loadFormData {
    
    __block int index=0;
    int total = formKeySet.count;
    
    if (total==0) {
        [self renderChatMessages:liveChat];
    } else {
        
        for (NSString *formKey in formKeySet) {
            if (!formKey || formKey.length == 0) {
                NSLog(@"Skipping empty formKey");
                continue;
            }
            [formSvc apiLoadForm:formKey fetchAll:YES callback:^(FormVO *form) {
                NSString *contactKey = nil;
                if ([form.user_key isEqualToString:[PFUser currentUser].objectId]) {
                    contactKey = nil;
                } else {
                    contactKey = [DataModel shared].user.contact_key;
                }
                
                
                if (form) {
                    NSLog(@"Getting form responses %@", formKey);
                    [formSvc apiListFormResponses:formKey contactKey:contactKey callback:^(NSArray *results) {
                        if (!results) {
                            // Skip
                        } else {

                            form.responsesMap = [[NSMutableDictionary alloc] init];
                            if (results.count == 0) {
                                // No results
                            } else {
                                FormResponseVO *response;
                                if (contactKey == nil) {
                                    // not form owner. other recipient (left side)
                                    
                                    for (PFObject *result in results) {
                                        response = [FormResponseVO readFromPFObject:result];
                                        response.answerTotal = [NSNumber numberWithInt:1];
                                        response.ratingCount = [NSNumber numberWithInt:1];
                                        response.ratingTotal = response.rating;
                                        
                                        [form.responsesMap setObject:response forKey:response.option_key];
                                    }
                                    
                                } else {
                                    // Form owner. That means aggregate result stats.
                                    for (PFObject *result in results) {
                                        response = [FormResponseVO readFromPFObject:result];
                                        
                                        if ([form.responsesMap objectForKey:response.option_key] == nil) {
                                            response.answerTotal = [NSNumber numberWithInt:1];
                                            response.ratingCount = [NSNumber numberWithInt:1];
                                            response.ratingTotal = response.rating;
                                            
                                            [form.responsesMap setObject:response forKey:response.option_key];
                                            
                                        } else {
                                            
                                            ((FormResponseVO *)[form.responsesMap objectForKey:response.option_key]).answerTotal = [NSNumber numberWithInt:[response.answerTotal intValue] + 1];;
                                            if (response.rating) {
                                                
                                                FormResponseVO *_resp = (FormResponseVO *)[form.responsesMap objectForKey:response.option_key];
                                                ((FormResponseVO *)[form.responsesMap objectForKey:response.option_key]).ratingTotal = [NSNumber numberWithInt:(_resp.ratingTotal.intValue + response.rating.intValue)];
                                                ((FormResponseVO *)[form.responsesMap objectForKey:response.option_key]).ratingCount = [NSNumber numberWithInt:[response.ratingCount intValue] + 1];;
                                                
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            // Finish up. List chat messages now that we have the forms, options and responses
                            [formCache setObject:form forKey:formKey];
                            
                            
                        }
                        index++;
                        
                        if (index==total) {
                            [self renderChatMessages:liveChat];
                        }
                    }];
                    
                } // if form
                else {
                    
                }
                
            }];
            
        }
        
    }
    
    
}


- (void) renderChatMessages:(ChatVO *)theChat {
    NSLog(@"%s", __FUNCTION__);
    NSBubbleData *bubble;
    int index = 0;
    for (ChatMessageVO* msg in theChat.messages) {
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
            [self.tableDataSource addObject:bubble];
        }
    }
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    [chatSvc updateChatReadTime:chatId name:chatTitle readtime:[NSNumber numberWithDouble:seconds]];
    
    //    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSLog(@"Ready to reload table");
    [self setupTopDrawer];
    
    [self.bubbleTable reloadData];
    [self.bubbleTable scrollBubbleViewToBottomAnimated:NO];
}

#pragma mark - Notifications


- (void)formResponseEnteredHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    @try {
        
        [[[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Response sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }
    @catch (NSException *exception) {
        NSLog(@"########### Exception %@", exception);
    }
    
    
}

- (void)showFormDetailsHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    if (notification.object) {
        NSString *formKey = (NSString *) notification.object;
        
        if ([formCache objectForKey:formKey]) {
            FormVO *theForm = (FormVO *) [formCache objectForKey:formKey];
            [DataModel shared].form = theForm;
            
            
            
            switch (theForm.type) {
                case FormType_POLL:
                {
                    BOOL allowView = NO;
                    if (theForm.allow_public != nil) {
                        if (theForm.allow_public.intValue == 1) {
                            allowView = YES;
                        }
                    }
                    if ([theForm.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
                        allowView = YES;
                    }
                    if (allowView) {
                        [DataModel shared].action = @"popup";
                        PollDetailVC *pollDetailVC = [[PollDetailVC alloc] initWithNibName:@"PollDetailVC" bundle:nil];
                        pollDetailVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                        [self presentViewController:pollDetailVC animated:YES completion:nil];
                        
                        
                    } else {
                        [[[UIAlertView alloc] initWithTitle:nil message:kDetailsNotPublic delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    
                    }
                    
                    break;
                }
                case FormType_RATING:
                {
                    BOOL allowView = NO;
                    if (theForm.allow_public != nil) {
                        if (theForm.allow_public.intValue == 1) {
                            allowView = YES;
                        }
                    }
                    if ([theForm.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
                        allowView = YES;
                    }
                    if (allowView) {
                        [DataModel shared].action = @"popup";
                        RatingDetailVC *detailsVC = [[RatingDetailVC alloc] init];
                        detailsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                        [self presentViewController:detailsVC animated:YES completion:nil];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:nil message:kDetailsNotPublic delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        
                    }
                    
                    break;
                }
                case FormType_RSVP:
                {
                    [DataModel shared].action = @"popup";
                    RSVPDetailVC *detailsVC = [[RSVPDetailVC alloc] init];
                    detailsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:detailsVC animated:YES completion:nil];
                    break;
                }
            }
        } else {
            NSLog(@"formKey not recognized in cache %@", formKey);
        }
        
    }
    
    
}

#pragma mark - Load Data and Setup
- (void) setupTopDrawer {
    
    [self.bubbleTable setContentInset:UIEdgeInsetsMake(20,0,0,0)];
    theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];
    UIImage *icon = [UIImage imageNamed:@"name_widget_arrow"];
    
    ContactVO* contact;
    contactsArray = [[NSMutableArray alloc] initWithCapacity:[DataModel shared].chat.contact_keys.count];
    NSString *name;
    int xpos = kDrawerItemsStartX;
    int ypos = kDrawerItemsStartY;
    
    WidgetStyle *style = [[WidgetStyle alloc] init];
    style.fontcolor = 0xFFFFFF;
    style.bgcolor = 0x28CFEA;
    style.bordercolor = 0x09a1bd;
    style.corner = 2;
    style.font = theFont;
    
    int index = 0;
    float itemWidth = 0;
    for (NSString *key in [DataModel shared].chat.contact_keys) {
        
        if ([key isEqualToString:[DataModel shared].user.contact_key]) {
            name = @"Me";
        } else {
            contact = [[DataModel shared].contactCache objectForKey:key];
            
            if (contact.first_name != nil && contact.last_name != nil) {
                name = contact.fullname;
            } else {
                name = contact.phone;
            }
        }
        //        name = [[DataModel shared].chat.
        CGSize txtSize = [name sizeWithFont:theFont];
        itemWidth = txtSize.width + 25;
        
        if (xpos + itemWidth > self.drawerContents.frame.size.width - kDrawerItemsStartX * 2) {
            xpos = kDrawerItemsStartX;
            ypos += kNameWidgetRowHeight;
            
        }
        
        CGRect itemFrame = CGRectMake(xpos, ypos, itemWidth, 25);
        
        NameWidget *item = [[NameWidget alloc] initWithFrame:itemFrame andStyle:style];
        item.userInteractionEnabled = YES;
        item.tag = kBaseTagForNameWidget + index;
        //        [item setupButton:key];
        
        [item setFieldLabel:name];
        xpos += itemWidth + kNameWidgetGap;
        [item setIcon:icon];
        
        [self.drawerContents addSubview:item];
        index++;
        
    }

    CGRect frame = self.drawerContents.frame;

    if (xpos > 200) {
        ypos += kNameWidgetRowHeight;
    }
    float delta = 0;
    
    // Determine if group already exists
    
    theFont = [UIFont fontWithName:@"Raleway-Bold" size:11];

    UIButton *createGroupLink = [UIButton buttonWithType:UIButtonTypeCustom];
    createGroupLink.backgroundColor = [UIColor clearColor];
    createGroupLink.titleLabel.font = theFont;
    createGroupLink.titleLabel.textColor = [UIColor whiteColor];
//    createGroupLink.titleLabel.text = @"New group from list";
    [createGroupLink setTitle:@"New group from list" forState:UIControlStateNormal];
    CGRect linkFrame = CGRectMake(frame.size.width - kCreateLinkWidth - 10, ypos, kCreateLinkWidth, 25);
    createGroupLink.frame = linkFrame;
    [createGroupLink addTarget:self action:@selector(tapCreateGroupLink:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.drawerContents addSubview:createGroupLink];
    // Resize outer drawer frame and view

    ypos += kNameWidgetRowHeight;
    

    //    float originalY = self.topDrawer.frame.origin.y;
    float originalHeight = frame.size.height;
    
    delta = originalHeight - ypos;
    frame.size.height -= delta;
    self.drawerContents.frame = frame;
    
    frame = self.drawerPull.frame;
    frame.origin.y -= delta;
    self.drawerPull.frame = frame;
    
    frame = self.drawerView.frame;
    frame.size.height -= delta;
    frame.origin.y = -1 * frame.size.height + 70;
    self.drawerView.frame = frame;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handlePull:)];
    
    // Specify that the gesture must be a single tap
    [panRecognizer setMinimumNumberOfTouches:1];
    
    panRecognizer.cancelsTouchesInView = YES;
    [self.drawerView addGestureRecognizer:panRecognizer];
    
    drawerMinTop = self.drawerView.frame.origin.y;
    drawerMaxTop = 0;
    
    
    
    
}

- (void)chatPushNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    if (notification.object) {
        ChatMessageVO *msg = (ChatMessageVO *) notification.object;
        
        if ([msg.chat_key isEqualToString:chatId]) {
            
            [self loadChatMessages];
            
            
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
        
        for (ChatMessageVO *msg in messages) {
            countKey = [NSNumber numberWithInt:index];
            /*
             Embedded form should be it's own bubble. That means closing previous bubble and starting new one.
             
             add prev message to dialogue map
             create new one and add to dialogue map
             index++
             
             */
            if (msg.pfPhoto != nil) {
                lastMessage.message = currentText;
                [dialogueMap setObject:lastMessage forKey:countKey];
                //                [(ChatMessageVO *)[dialogueMap objectForKey:countKey]].message = currentText;
                lastMessage = msg;
                index++;
                countKey = [NSNumber numberWithInt:index];
                [dialogueMap setObject:lastMessage forKey:countKey];
                currentText = @"";
                
            } else if (msg.form_key != nil) {
                // Embedded form.
                lastMessage.message = currentText;
                [dialogueMap setObject:lastMessage forKey:countKey];
                //                [(ChatMessageVO *)[dialogueMap objectForKey:countKey]].message = currentText;
                lastMessage = msg;
                index++;
                countKey = [NSNumber numberWithInt:index];
                [dialogueMap setObject:lastMessage forKey:countKey];
                currentText = @"";
                
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
    ContactVO *contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:msg.contact_key];

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
        bubble.iconFile = contact.pfPhoto;
//        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
    } else {
        // someone else
        if (msg.pfPhoto == nil) {
            viewInset = UIEdgeInsetsMake(2, 10, 2, 0);
        } else {
            viewInset = UIEdgeInsetsMake(5, 10, 5, 0);
        }
        
        if (contact) {
            if (contact.first_name != nil && contact.last_name != nil) {
                nameValue = contact.fullname;
            } else {
                nameValue = contact.phone;
            }
        } else {
            nameValue = @"";
        }
        
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
        bubble.iconFile = contact.pfPhoto;

//        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
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
    if (theForm.status.intValue == FormStatus_REMOVED) {
        NSLog(@"Ignoring removed form >>>>>>>>>>>> %@", msg.form_key);
        return nil;
    }
    NSBubbleType whoType;
    BOOL isOwner;
    UIEdgeInsets viewInset;
    
    ContactVO *contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:msg.contact_key];

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
        
        ContactVO *contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:msg.contact_key];
        if (contact) {
            if (contact.first_name != nil && contact.last_name != nil) {
                nameValue = contact.fullname;
            } else {
                nameValue = contact.phone;
            }
        } else {
            nameValue = @"";
        }
    }
    
    timeValue = [msgTimeFormat stringFromDate:msg.createdAt];
    NSLog(@"createdAt %@ -- timeValue %@", msg.createdAt, timeValue);
    
    
    if (theForm.type == FormType_POLL) {
        EmbedPollWidget *embedWidget = [[EmbedPollWidget alloc] initWithFrame:msgFrame andOptions:theForm.options andResponses:theForm.responsesMap  isOwner:isOwner];
        embedWidget.subjectLabel.text = theForm.name;
        embedWidget.userInteractionEnabled = YES;
        
        // Save keys in widget for when user submits response data
        embedWidget.chat_key = chatId;
        embedWidget.form_key = theForm.system_id;
        
        embedWidget.tag = 199;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:msg.createdAt type:whoType insets:viewInset];
        bubble.iconFile = contact.pfPhoto;
//        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        return bubble;
        
    } else if (theForm.type == FormType_RATING) {
        EmbedRatingWidget *embedWidget = [[EmbedRatingWidget alloc] initWithFrame:msgFrame andOptions:theForm.options andResponses:theForm.responsesMap isOwner:isOwner];
        embedWidget.subjectLabel.text = theForm.name;
        embedWidget.userInteractionEnabled = YES;
        embedWidget.tag = 299;
        
        // Save keys in widget for when user submits response data
        embedWidget.chat_key = chatId;
        embedWidget.form_key = theForm.system_id;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:msg.createdAt type:whoType insets:viewInset];
//        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        bubble.iconFile = contact.pfPhoto;
        return bubble;
        
    } else if (theForm.type == FormType_RSVP) {
        EmbedRSVPWidget *embedWidget = [[EmbedRSVPWidget alloc] initWithFrame:msgFrame andOptions:theForm.options andResponses:(NSMutableDictionary *)theForm.responsesMap isOwner:isOwner];
        //                    embedWidget.subjectLabel.text = self.attachedForm.name;
        
        // Save keys in widget for when user submits response data
        
        embedWidget.chat_key = chatId;
        embedWidget.form_key = theForm.system_id;
        embedWidget.form = theForm;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        
        embedWidget.nameLabel.text = nameValue;
        embedWidget.timeLabel.text = timeValue;
        
        embedWidget.userInteractionEnabled = YES;
        
        
        embedWidget.eventDateLabel.text = [DateTimeUtils printDatePartFromDate:theForm.eventStartsAt];
        
        NSString *timeRange = @"%@ - %@";
        
        timeRange = [NSString stringWithFormat:timeRange,
                     [DateTimeUtils printTimePartFromDate:theForm.eventStartsAt],
                     [DateTimeUtils printTimePartFromDate:theForm.eventEndsAt]];
        embedWidget.eventTimeLabel.text = timeRange;
        
        embedWidget.subjectLabel.text = theForm.name;
        embedWidget.whatText.text = theForm.details;
        embedWidget.whereText.text = theForm.location;
        
        embedWidget.roundPic.image = [DataModel shared].defaultImage;
        if (theForm.pfPhoto != nil) {
            embedWidget.roundPic.file = theForm.pfPhoto;
            [embedWidget.roundPic loadInBackground];
        }
        
        embedWidget.userInteractionEnabled = YES;
        embedWidget.tag = 399;
        
        NSLog(@"widget height = %f", embedWidget.dynamicHeight);
        msgFrame.size.height = embedWidget.dynamicHeight;
        embedWidget.frame = msgFrame;
        
        bubble = [NSBubbleData dataWithView:embedWidget date:msg.createdAt type:whoType insets:viewInset];
//        bubble.avatar = (UIImage *)[self.imageMap objectForKey:msg.contact_key];
        bubble.iconFile = contact.pfPhoto;

        return bubble;
        
    }
    return nil;
}
- (void)hideFormSelectorNotificationHandler:(NSNotification*)notification
{
    if (notification.object != nil) {
        self.attachedForm = (FormVO *) notification.object;
        attachmentType = self.attachedForm.type;
        hasAttachment = YES;
        NSLog(@"Form pick: %@", self.attachedForm.name);
        self.sendButton.enabled = YES;
        
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
        [formSvc apiListFormOptions:self.attachedForm.system_id callback:^(NSArray *results) {
            self.attachedForm.options = [[NSMutableArray alloc] initWithCapacity:results.count];
            FormOptionVO *option;
            
            for (PFObject *result in results) {
                option = [FormOptionVO readFromPFObject:result];
                [self.attachedForm.options addObject:option];
            }
            [self hideFormSelector];
            [self hideAttachModal];
        }];
        
    } else {
        [self hideFormSelector];
        [self hideAttachModal];
    }
    
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    NSLog(@"rowsForBubbleTable %i", [self.tableDataSource count]);
    return [self.tableDataSource count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    //    NSLog(@"bubbleTableView dataForRow %i",row);
    return [self.tableDataSource objectAtIndex:row];
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
    // Add 3px since some letters are taller and go below baseline
    float newsize = estSize.height + 3;
    
    //    NSLog(@"inputHeight %f // newsize %f", inputHeight, newsize);
    
    if (inputHeight != newsize ) {
        NSLog(@"textView height is now %f", newsize);
        vshift = newsize - inputHeight;
        
        inputHeight = newsize;
        float maxHeight = [DataModel shared].stageHeight - keyboardHeight - kScrollViewTop - 10;
        if (inputHeight < maxHeight) {
            CGRect frame = self.inputField.frame;
            frame.size.height = newsize;
            self.inputField.frame = frame;
            inputFrame = frame;
            //            self.inputField.frame = CGRectMake(self.inputField.frame.origin.x,
            //                                           self.inputField.frame.origin.y,
            //                                           self.inputField.frame.size.width,
            //                                           newsize);
            //            self.inputField.frame = inputFrame;
            
            frame = self.chatBar.frame;
            
            frame.size.height += vshift;
            frame.origin.y -= vshift;
            self.chatBar.frame = frame;
            chatFrame = frame;
            
            CGRect scrollFrame = self.bubbleTable.frame;
            scrollFrame.size.height -= vshift;
            self.bubbleTable.frame = scrollFrame;
            
        } else {
            //            [textView scr]
        }
        
        [self.bubbleTable scrollBubbleViewToBottomAnimated:NO];

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


#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //    NSLog(@"%s", __FUNCTION__);
    keyboardIsShown = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = kbSize.height;
    //    kbSize.height += kChatBarHeight;
    //    NSLog(@"Keyboard height is %f", kbSize.height)
    
    [UIView animateWithDuration:0.1f animations:^{
        
        chatFrameWithKeyboard = self.chatBar.frame;
        chatFrameWithKeyboard.origin.y -= keyboardHeight;
        chatFrame = chatFrameWithKeyboard;
        self.chatBar.frame = chatFrameWithKeyboard;
        
        CGRect frame = self.bubbleTable.frame;
        //        frame.size.height = chatFrameWithKeyboard.origin.y - kChatBarHeight - kScrollViewTop;
        frame.size.height -= kbSize.height;
        
        self.bubbleTable.frame = frame;
        [self.bubbleTable scrollBubbleViewToBottomAnimated:NO];
        
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"%s", __FUNCTION__);
    keyboardIsShown = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        chatFrame = self.chatBar.frame;
        chatFrame.origin.y = [DataModel shared].stageHeight - chatFrame.size.height;
        self.chatBar.frame = chatFrame;
        
        CGRect frame = self.bubbleTable.frame;
        frame.size.height = [DataModel shared].stageHeight - chatFrame.size.height - kScrollViewTop;
        //        frame.size.height += kbSize.height + kChatBarHeight;
        self.bubbleTable.frame = frame;
        
        
        
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
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please confirm"
                                                    message:@"Do you want to clear all messages?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    alert.tag = kAlertClearMessages;
    [alert show];
    
    
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
    self.attachedPhoto = nil;
    
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
    
    switch (alertView.tag) {
        case kAlertClearMessages:
        {
            if (buttonIndex == 1) {
                
                NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                NSLog(@"timestamp = %f", seconds);
                
                [chatSvc updateClearTimestamp:chatId cleartime:[NSNumber numberWithDouble:seconds]];
                dbChat = [chatSvc loadChatByKey:chatId];
                [self loadChatMessages];
                
            }
            break;
        }
        default:
            [_delegate gotoSlideWithName:@"ChatHome"];
            break;
            
    }
    
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.imagePickerVC = nil;
    self.attachedPhoto = nil;
    
}

- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s", __FUNCTION__);
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    UIImage *tmpImage = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    CGSize resize;
    
    resize = CGSizeMake(kMinimumImageDimension, kMinimumImageDimension);
    
    self.attachedPhoto = [tmpImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:resize interpolationQuality:kCGInterpolationMedium];
    
    tmpImage = nil;
    
    NSLog(@"photo size = %f / %f", self.attachedPhoto.size.width, self.attachedPhoto.size.height);
    
    attachmentType = 0;
    hasAttachment = YES;
    
	[self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerVC = nil;
    
    [self hidePhotoModal];
    
    //    self.attachButton.imageView.image = [UIImage imageNamed:kAttachPhotoIcon];
    [self.attachButton setImage:[UIImage imageNamed:kAttachPhotoIconAqua] forState:UIControlStateNormal];
    
    
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
            int nameIndex = subview.tag - kBaseTagForNameWidget;
            if (nameIndex >= 0 && nameIndex <= 99) {
                @try {
                    NSString *key = (NSString *) [[DataModel shared].chat.contact_keys objectAtIndex:nameIndex];
                    ContactVO *contact = (ContactVO *) [[DataModel shared].contactCache objectForKey:key];
                    [DataModel shared].contact = contact;
                    self.contactInfoVC = [[ContactInfoVC alloc] initWithNibName:@"ContactInfoVC" bundle:nil];
                    [DataModel shared].action = @"popup";
                    [self presentViewController:self.contactInfoVC animated:YES completion:nil];
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"ERROR >>>>>>>> %@", exception);
                }
                
                
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

- (void) tapCreateGroupLink:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    
}

#pragma mark - Chat message handling

- (void) insertMessageInChat {
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.sendButton.bounds.size.height / 2;
    CGFloat buttonWidth = self.sendButton.bounds.size.width;
    spinner.center = CGPointMake(buttonWidth / 2, halfButtonHeight);
    [self.sendButton addSubview:spinner];
    [spinner startAnimating];
    self.sendButton.enabled = NO;

    //    [self.bubbleTable becomeFirstResponder];
    //    self.sendButton.enabled = NO;
    if (!hasAttachment) {
        if (self.inputField.text.length > 0) {
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            
            NSString *chatText = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (chatText.length > 0) {
                msg.message = chatText;
                msg.contact_key = [DataModel shared].user.contact_key;
                msg.chat_key = chatId;
                msg.createdAt = [NSDate date];
                
                [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                    NSBubbleData *bubble;
                    
                    bubble = [self buildMessageBubble:msg];
                    
                    [self.tableDataSource addObject:bubble];
                    [self.bubbleTable reloadData];
                    [self resetChatUI];
                    
                    // Build a target query: everyone in the chat room except for this device.
                    // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                    PFQuery *query = [PFInstallation query];
                    
                    NSString *channelId = [@"chat_" stringByAppendingString:chatId];
                    [query whereKey:@"channels" equalTo:channelId];
                    //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
                    
                    //                    NSString *msgtext = @"New message from %@";
                    NSString *msgtext = @"%@: %@";
                    msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, msg.message];
                    
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          msgtext, @"alert",
                                          //                                      @"Increment", @"badge",
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
                    
                    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                    [chatSvc updateChatReadTime:chatId name:chatTitle readtime:[NSNumber numberWithDouble:seconds]];
                    
                }];
            }
            //        [chatSvc apiSaveChatMessage:msg];
        }
        
        return;
    }
    // Insert attachment if present. Reset inputs when done
    if (hasAttachment) {
//        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [self.hud setLabelText:@"Sending"];
        
        if (self.attachedForm != nil) {
            
            [formCache setObject:self.attachedForm forKey:self.attachedForm.system_id];
            
            // ################# PARSE SAVE ##################
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            
            msg.contact_key = [DataModel shared].user.contact_key;
            msg.chat_key = chatId;
            msg.form_key = self.attachedForm.system_id;
            msg.createdAt = [NSDate date];

            if (self.inputField.text.length > 0) {
                NSString *chatText = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                msg.message = chatText;
            }
            
            NSBubbleData *bubble;
            
            bubble = [self buildMessageWidget:msg];
            
            [self.tableDataSource addObject:bubble];
            [self.bubbleTable reloadData];
            //            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            formTitle = self.attachedForm.name;
            NSLog(@"Saving form %@ in chat", formTitle);
            
            [chatSvc apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                if (pfMessage) {
                    
                    [formSvc apiLookupFormContacts:msg.form_key contactKeys:[DataModel shared].chat.contact_keys callback:^(NSArray *savedKeys) {
                        
                        NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                        
                        for (NSString *key in [DataModel shared].chat.contact_keys) {
                            
                            if (![savedKeys containsObject:key]) {
                                [unsavedKeySet addObject:key];
                            }
                        }
                        
                        [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                            NSLog(@"Saved form contacts count %i", savedKeys.count);
                            
                        }];
                        [chatSvc apiSaveChatForm:msg.chat_key formId:msg.form_key callback:^(PFObject *object) {
                            // Build a target query: everyone in the chat room except for this device.
                            // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                            PFQuery *query = [PFInstallation query];
                            
                            NSString *channelId = [@"chat_" stringByAppendingString:chatId];
                            [query whereKey:@"channels" equalTo:channelId];
                            
                            NSLog(@"form type = %i", attachmentType);
                            NSString *msgtext = @"%@ posted a new %@: %@";
                            switch (attachmentType) {
                                case FormType_POLL:
                                {
                                    msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"poll", formTitle];
                                    break;
                                }
                                case FormType_RATING:
                                {
                                    msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"Rating poll", formTitle];
                                    
                                    break;
                                }
                                case FormType_RSVP:
                                {
                                    msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"RSVP", formTitle];
                                    break;
                                }
                            }
                            
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  msgtext, @"alert",
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
                            [push setData:data];
                            [push sendPushInBackground];
                            
                            self.sendButton.enabled = YES;
                            
                            NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                            [chatSvc updateChatReadTime:chatId name:chatTitle readtime:[NSNumber numberWithDouble:seconds]];
                            
                        }];
                        
                    }];
                } else {
                    NSLog(@"Chat message was not saved");
                }
            }];
            
            
        } else if (self.attachedPhoto != nil && attachmentType == 0) {
            
            ChatMessageVO *msg = [[ChatMessageVO alloc] init];
            
            if (self.inputField.text.length > 0) {
                NSString *chatText = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                msg.message = chatText;
            }
            msg.contact_key = [DataModel shared].user.contact_key;
            msg.chat_key = chatId;
            msg.createdAt = [NSDate date];

            msg.photo = self.attachedPhoto;
            NSBubbleData *bubble;
            bubble = [self buildMessageBubble:msg];
            
            [self.tableDataSource addObject:bubble];
            [self.bubbleTable reloadData];
            
            [chatSvc apiSaveChatMessage:msg withPhoto:self.attachedPhoto callback:^(PFObject *pfMessage) {
                
                // Build a target query: everyone in the chat room except for this device.
                // See also: http://blog.parse.com/2012/07/23/targeting-pushes-from-a-device/
                PFQuery *query = [PFInstallation query];
                NSString *channelId = [@"chat_" stringByAppendingString:chatId];
                [query whereKey:@"channels" equalTo:channelId];
                //            [query whereKey:@"installationId" notEqualTo:[PFInstallation currentInstallation].installationId];
                NSString *msgtext = @"%@: %@";
                msgtext = [NSString stringWithFormat:msgtext, [DataModel shared].myContact.fullname, @"posted a photo"];
                
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
                NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                [chatSvc updateChatReadTime:chatId name:chatTitle readtime:[NSNumber numberWithDouble:seconds]];
                
//                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
            }];
            
        }
        [self resetChatUI];
    }
    
    
}
- (void) resetChatUI {
    CGRect scrollFrame = self.bubbleTable.frame;
    
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.sendButton.enabled = NO;

    self.inputField.text = @"";
    
    inputFrame.size.height = defaultInputFrameHeight;
    self.inputField.frame = inputFrame;
    
    if (keyboardIsShown) {
        scrollFrame.size.height = [DataModel shared].stageHeight - keyboardHeight - kChatBarHeight - kScrollViewTop;
        NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
        self.bubbleTable.frame = scrollFrame;
        
        chatFrame.size.height = defaultChatFrameHeight;
        chatFrame.origin.y = [DataModel shared].stageHeight - chatFrame.size.height - keyboardHeight;
        self.chatBar.frame = chatFrame;
        
    } else {
        scrollFrame.size.height = [DataModel shared].stageHeight - kChatBarHeight - kScrollViewTop;
        NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);
        self.bubbleTable.frame = scrollFrame;
        
        
        chatFrame.size.height = defaultChatFrameHeight;
        chatFrame.origin.y = [DataModel shared].stageHeight - chatFrame.size.height;
        self.chatBar.frame = chatFrame;
        
    }
    
    
    hasAttachment = NO;
    self.attachedPhoto = nil;
    self.attachedForm = nil;
    [self.attachButton setImage:[UIImage imageNamed:kAttachPlusIcon] forState:UIControlStateNormal];
    self.sendButton.enabled = YES;
    
    [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    
}

#pragma mark - Create new form handlers

- (IBAction)tapCreatePollButton {
    [DataModel shared].action = @"popup";
    [DataModel shared].didSaveOK = NO;
    
    EditPollVC *editPollVC = [[EditPollVC alloc] init];
    [self presentViewController:editPollVC animated:YES completion:^{
        
//        if ([DataModel shared].didSaveOK) {
//            NSLog(@"form saved.");
//            [self hideAttachModal];
//            self.attachedForm = [DataModel shared].form;
//        }
    }];
    
}
- (IBAction)tapCreateRatingButton {
    [DataModel shared].action = @"popup";
    [DataModel shared].didSaveOK = NO;

    EditRatingVC *editRatingVC = [[EditRatingVC alloc] init];
    [self presentViewController:editRatingVC animated:YES completion:^{
//        if ([DataModel shared].didSaveOK) {
//            NSLog(@"form saved.");
//            [self hideAttachModal];
//            self.attachedForm = [DataModel shared].form;
//        }
    }];
    
}
- (IBAction)tapCreateRSVPButton {
    [DataModel shared].action = @"popup";
    [DataModel shared].didSaveOK = NO;

    EditRSVPVC *editRSVPVC = [[EditRSVPVC alloc] init];
    [self presentViewController:editRSVPVC animated:YES completion:^{
//        if ([DataModel shared].didSaveOK) {
//            NSLog(@"form saved.");
//            [self hideAttachModal];
//            self.attachedForm = [DataModel shared].form;
//        }
    }];
    
    
}

@end
