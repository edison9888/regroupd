//
//  ContactInfoVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ContactInfoVC.h"

@interface ContactInfoVC ()

@end

@implementation ContactInfoVC

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
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        self.backButton.titleLabel.text = @"Back";
    } else {
        self.backButton.titleLabel.text = @"All Contacts";
    }
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    contactSvc = [[ContactManager alloc] init];
    [self.roundPic.layer setCornerRadius:66.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:3.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *img;
    img = [UIImage imageNamed:@"anonymous_user"];
    self.roundPic.image = img;

    [self refreshView];
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

#pragma mark - Data Load

- (void) refreshView {
    
    self.blockButton.enabled = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.blockButton.bounds.size.height / 2;
    CGFloat buttonWidth = self.blockButton.bounds.size.width;
    indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
    [self.blockButton addSubview:indicator];
    [indicator startAnimating];
    
    
    if ([DataModel shared].contact != nil && [DataModel shared].contact.system_id != nil) {
        [contactSvc apiLoadContact:[DataModel shared].contact.system_id callback:^(PFObject *pfContact) {
            if (pfContact[@"photo"]) {
                PFFile *photo = pfContact[@"photo"];
                self.roundPic.file = photo;
                [self.roundPic loadInBackground];
                
            }
            [contactSvc apiPrivacyLookupBlock:[DataModel shared].user.contact_key
                                   blockedKey:[DataModel shared].contact.system_id
                                     callback:^(PFObject *pfObject) {
                                         self.blockButton.enabled = YES;
                                         [indicator stopAnimating];

                                         if (pfObject) {
                                             isBlocked = YES;
                                             [self.blockButton setTitle:@"Unblock User" forState:UIControlStateNormal];
                                         }
                                     }];
        }];
    }

    if ([[DataModel shared].contact.system_id isEqualToString:[DataModel shared].user.contact_key]) {
        self.nameLabel.text = @"Me";
        
    } else if ([DataModel shared].contact.first_name != nil && [DataModel shared].contact.last_name != nil) {
        self.nameLabel.text = [DataModel shared].contact.fullname;
    } else {
        self.nameLabel.text = [DataModel shared].contact.phone;
    }
    
    
    NSString *phoneText = [NSString stringWithFormat:@"Phone %@", [DataModel shared].contact.phone];
    self.phoneButton.titleLabel.text = phoneText;
    [self.phoneButton setTitle:phoneText forState:UIControlStateNormal];
    NSString *msgText;
    
    if ([DataModel shared].contact.first_name != nil) {
        msgText =[NSString stringWithFormat:@"Message %@", [DataModel shared].contact.first_name];
        [self.messageButton setTitle:msgText forState:UIControlStateNormal];
    }

}
#pragma mark - IBActions

- (IBAction)tapBackButton {
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        [DataModel shared].action = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_delegate gotoSlideWithName:@"ContactsHome"];
    }
//    [_delegate gotoSlideWithName:@"ContactsHome" andOverrideTransition:kPresentationTransitionAuto];
    
}
- (IBAction)tapMessageButton {
    if (chatSvc == nil) {
        chatSvc = [[ChatManager alloc] init];
        
    }
    NSArray *contactKeys = @[[DataModel shared].user.contact_key, [DataModel shared].contact.system_id];
    
    [chatSvc apiFindChatsByContactKeys:contactKeys callback:^(NSArray *results) {
        BOOL chatExists = NO;
        ChatVO *chat;
        if (results && results.count > 0) {
            for (PFObject *pfChat in results) {
                if (pfChat[@"contact_keys"]) {
                    NSArray *keys =pfChat[@"contact_keys"];
                    if (keys.count == 2) {
                        // exact match.
                        chat = [ChatVO readFromPFObject:pfChat];
                        chatExists = YES;
                        break;
                    }
                }
            }
        }
        if (chatExists) {
            
            [DataModel shared].chat = chat;
            [DataModel shared].mode = @"Chats";
            [_delegate setBackPath:@"ChatsHome"];
            [_delegate gotoSlideWithName:@"Chat"];
            
        } else {
            ChatVO *chat = [[ChatVO alloc] init];
            
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
                
                [DataModel shared].mode = @"Chats";
                [_delegate setBackPath:@"ChatsHome"];
                [_delegate gotoSlideWithName:@"Chat"];
            }];
        }
    }];
}
- (IBAction)tapPhoneButton {
    NSString *phoneUrl = [NSString stringWithFormat:@"tel:%@", [DataModel shared].contact.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
    
}
- (IBAction)tapGroupsButton {
    
    [_delegate gotoSlideWithName:@"ContactGroups" returnPath:@"ContactInfo"];
    
}
- (IBAction)tapBlockButton {
    if (isBlocked) {
        [contactSvc apiPrivacyLookupBlock:[DataModel shared].user.contact_key
                               blockedKey:[DataModel shared].contact.system_id
                                 callback:^(PFObject *pfObject) {
                                     if (pfObject) {
                                         [pfObject deleteInBackground];
                                         [self.blockButton setTitle:@"Block User" forState:UIControlStateNormal];
                                         isBlocked = NO;
                                     }
                                     [[[UIAlertView alloc] initWithTitle:@"User unblocked" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                 }];
        
    } else {
        [contactSvc apiPrivacyLookupBlock:[DataModel shared].user.contact_key
                               blockedKey:[DataModel shared].contact.system_id
                                 callback:^(PFObject *pfObject) {
                                     if (pfObject) {
                                         [self.blockButton setTitle:@"Unblock User" forState:UIControlStateNormal];
                                         isBlocked = YES;
                                     } else {
                                         [contactSvc apiPrivacyBlockUser:[DataModel shared].user.contact_key
                                                              blockedKey:[DataModel shared].contact.system_id callback:^(PFObject *pfObject) {
                                                                  if (pfObject) {
                                                                      [self.blockButton setTitle:@"Unblock User" forState:UIControlStateNormal];
                                                                      isBlocked = YES;
                                                                      
                                                                      [[[UIAlertView alloc] initWithTitle:@"User blocked" message:@"This contact will no longer be able to send you individual chat messages." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                                  }
                                                              }];
                                         
                                     }
                                 }];

        
        
    }
}

@end
