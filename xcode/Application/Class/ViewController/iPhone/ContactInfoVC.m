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

    if ([DataModel shared].contact != nil && [DataModel shared].contact.contact_key != nil) {
        [contactSvc apiLoadContact:[DataModel shared].contact.contact_key callback:^(PFObject *pfContact) {
            if (pfContact[@"photo"]) {
                PFFile *photo = pfContact[@"photo"];
                self.roundPic.file = photo;
                [self.roundPic loadInBackground];
            }
        }];
    }
    if ([[DataModel shared].contact.system_id isEqualToString:[DataModel shared].user.contact_key]) {
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    NSArray *contactKeys = @[[DataModel shared].user.contact_key, [DataModel shared].contact.contact_key];
    
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
            [_delegate gotoSlideWithName:@"Chat" andOverrideTransition:kPresentationTransitionFade];
            
        } else {
            ChatVO *chat = [[ChatVO alloc] init];
            
            chat.contact_keys = contactKeys;
            
            [chatSvc apiSaveChat:chat callback:^(PFObject *pfChat) {
                
                // Adding push notifications subscription
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:pfChat.objectId forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                chat.system_id = pfChat.objectId;
                
                [chatSvc saveChat:chat];
                
                [DataModel shared].chat = chat;
                
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
    
}
- (IBAction)tapBlockButton {
    
}

@end
