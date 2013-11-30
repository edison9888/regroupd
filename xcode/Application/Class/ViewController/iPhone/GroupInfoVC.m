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
    
    return;
    
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
- (IBAction)tapManageButton {
    
}
- (IBAction)tapDeleteButton {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please confirm"
                                                    message:@"Do you want to delete this group?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}

@end
