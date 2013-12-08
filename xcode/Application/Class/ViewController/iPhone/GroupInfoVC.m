//
//  GroupInfoVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "GroupInfoVC.h"

@interface GroupInfoVC ()

@end

@implementation GroupInfoVC

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
    [self setupModal:self.actionsheet];
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    
    [self.roundPic.layer setCornerRadius:66.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:3.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

    self.nameLabel.text = [DataModel shared].group.name;

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
#pragma mark - Modal view

-(void)setupModal:(UIView*)modalView
{
    
    
    CGRect modalFrame = modalView.frame;
    
    modalFrame.origin.y = [DataModel shared].stageHeight + 40;
    
    modalFrame.origin.x = ([DataModel shared].stageWidth - modalFrame.size.width ) / 2;
    
    modalView.layer.zPosition = 99;
    modalView.layer.borderWidth = 1.0;
    modalView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    modalView.layer.cornerRadius = 5.0;
    
    modalView.frame = modalFrame;
    
    if(![modalView isDescendantOfView:[self view]]) {
        [self.view addSubview:modalView];
    }
}


-(void)showModal:(UIView*)modalView animate:(BOOL)animate
{
    
    
    CGRect modalFrame = modalView.frame;
    modalFrame.origin.y = [DataModel shared].stageHeight - modalFrame.size.height;
    
    [self.view bringSubviewToFront:modalView];
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            modalView.frame = modalFrame;
        }];
        
    } else {
        modalView.frame = modalFrame;
        
    }
}
-(void)hideModal:(UIView*)modalView animate:(BOOL)animate
{
    
    
    CGRect modalFrame = modalView.frame;
    modalFrame.origin.y = modalFrame.size.height * -1;
    modalFrame.origin.y -= 20;
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            modalView.frame = modalFrame;
        }];
    } else {
        modalView.frame = modalFrame;
    }
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        if (groupSvc == nil) {
            groupSvc = [[GroupManager alloc] init];
        }
        
//        int groupId = [DataModel shared].group.group_id;
        [groupSvc deleteGroup:[DataModel shared].group];
        [_delegate goBack];
    }
}


#pragma mark - IBActions

- (IBAction)tapBackButton {
    [_delegate goBack];
    
}
- (IBAction)tapMessageButton {
    
    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
        
    }
    if (groupSvc == nil) {
        groupSvc = [[GroupManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    NSMutableArray *contactKeys = [groupSvc listGroupContactKeys:[DataModel shared].group.group_id];
    [contactKeys addObject:[DataModel shared].user.contact_key];
    
    NSLog(@"Found contactKeys %@", contactKeys);
    [contactSvc apiLookupContacts:contactKeys callback:^(NSArray *results) {
        NSMutableArray *namesArray = [[NSMutableArray alloc] init];
        
        ContactVO *contact;
        for (NSString *key in contactKeys) {
            contact = [[DataModel shared].contactCache objectForKey:key];
            if (contact) {
                [namesArray addObject:contact.fullname];
            }
        }
        NSString *names = [namesArray componentsJoinedByString:@", "];
        
        [chatSvc apiFindChatsByContactKeys:contactKeys callback:^(NSArray *results) {
            BOOL chatExists = NO;
            ChatVO *chat;
            if (results && results.count > 0) {
                for (PFObject *pfChat in results) {
                    if (pfChat[@"contact_keys"]) {
                        NSArray *keys =pfChat[@"contact_keys"];
                        if (keys.count == contactKeys.count) {
                            // exact match.
                            chat = [ChatVO readFromPFObject:pfChat];
                            chatExists = YES;
                            break;
                        }
                    }
                }
            }
            if (chatExists) {
                NSLog(@"Found existing chat");
                chat.names = names;
                [DataModel shared].chat = chat;
                [_delegate gotoSlideWithName:@"Chat" andOverrideTransition:kPresentationTransitionFade];
                
            } else {
                NSLog(@"Creating new chat");
                ChatVO *chat = [[ChatVO alloc] init];
                chat.names = names;
                chat.contact_keys = contactKeys;
                
                [chatSvc apiSaveChat:chat callback:^(PFObject *pfChat) {
                    
                    // Adding push notifications subscription
                    
                    NSString *channelId = [@"chat_" stringByAppendingString:pfChat.objectId];
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation addUniqueObject:channelId forKey:@"channels"];
                    [currentInstallation saveInBackground];
                    
                    chat.system_id = pfChat.objectId;
                    
                    [chatSvc saveChat:chat];
                    
                    [DataModel shared].chat = chat;
                    
                    [_delegate gotoSlideWithName:@"Chat"];
                }];
            }
        }];
    }];
    
}
- (IBAction)tapManageButton {
    
    
    [_delegate gotoSlideWithName:@"ManageGroup"];
    
}
- (IBAction)tapDeleteButton {
//    [self showModal:self.actionsheet animate:YES];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please confirm"
                                                    message:@"Do you want to delete this group?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}
- (IBAction)tapDeleteYesButton {
    
}
- (IBAction)tapDeleteNoButton {
    
}
@end
