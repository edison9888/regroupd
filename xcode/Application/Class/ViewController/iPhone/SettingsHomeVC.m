//
//  SettingsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SettingsHomeVC.h"
#import "ChatManager.h"
#import "NexmoSMS.h"

#define kAlertClearMessages 666

@interface SettingsHomeVC ()

@end

@implementation SettingsHomeVC

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
    
    CGRect scrollFrame = self.scrollView.frame;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        scrollFrame.origin.y += 20;
    }
    scrollFrame.size.height = [DataModel shared].stageHeight;
    self.scrollView.frame = scrollFrame;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Notifications_Enabled]) {
        [self.toggle1 selected];
    } else {
        [self.toggle1 unselected];
        
    }
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Notifications_Show_Preview]) {
//        [self.toggle2 selected];
//    } else {
//        [self.toggle2 unselected];
//    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Add_To_Calendar]) {
        [self.toggle3 selected];
    } else {
        [self.toggle3 unselected];
    }


    
//    // ######### TEMP DEBUG #############
//    self.value1.text = [DataModel shared].user.username;
//    self.value2.text = [DataModel shared].user.password;
//    self.value3.text = [DataModel shared].user.user_key;
//    
//    // ######### TEMP DEBUG #############

    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];
    
    
    self.toggle1.tag = 1;
    self.toggle2.tag = 2;
    self.toggle3.tag = 3;
    
    // Create and initialize a tap gesture
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapRecognizer];

    
}

- (void)viewWillDisappear:(BOOL)animated
{

    [self saveToggle1];
    [self saveToggle2];
    [self saveToggle3];
    
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


#pragma mark - MessageUI

- (void) createEmail {
    NSString *emailTitle = @"";
    // Email Content
    NSString *message = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@getregroupd.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:message isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Tap Gestures


-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        UIView* view = sender.view;
        CGPoint loc = [sender locationInView:view];
        UIView* subview = [view hitTest:loc withEvent:nil];
        NSLog(@"tag = %i", subview.tag);
        
        // http://www.rqgg.net/topic/zpnnq-on-off-setting-for-push-notification-at-app-level.html
        switch (subview.tag) {
            case 1:
//                [[NSUserDefaults standardUserDefaults] setObject:m.location forKey:@"loc"];

                [self.toggle1 toggle];
                break;
            case 2:
                [self.toggle2 toggle];
                break;
            case 3:
                [self.toggle3 toggle];
                break;
                
        }
//        CGPoint loc = [sender locationInView:view];
//        UIView* subview = [view hitTest:loc withEvent:nil];
//        CGPoint subloc = [sender locationInView:subview];
//        NSLog(@"hit tag = %i at point %f / %f", subview.tag, subloc.x, subloc.y);
    }

}
- (void) saveToggle1 {
    if (self.toggle1.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Notifications_Enabled];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Notifications_Enabled];
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void) saveToggle2 {
    if (self.toggle2.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Notifications_Show_Preview];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Notifications_Show_Preview];
    }

}
- (void) saveToggle3 {
    if (self.toggle3.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSetting_Add_To_Calendar];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSetting_Add_To_Calendar];
    }
}
#pragma mark - IBActions
- (IBAction)tapClearAllButton {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Please confirm"
                                                    message:@"Do you want to clear all chat messages?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    alert.tag = kAlertClearMessages;
    [alert show];

    
}
- (IBAction)tapContactButton {
    [self createEmail];
    
    
}
- (IBAction)tapProfileButton {
    [_delegate gotoSlideWithName:@"MyProfile" returnPath:@"SettingsHome"];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case kAlertClearMessages:
        {
            if (buttonIndex == 1) {
                
                NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
                NSLog(@"timestamp = %f", seconds);
                
                ChatManager *chatSvc = [[ChatManager alloc] init];
                
                [chatSvc updateClearTimestamp:@"*" cleartime:[NSNumber numberWithDouble:seconds]];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"All chats cleared." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                
            }
            break;
        }
            
    }
    
}

@end
