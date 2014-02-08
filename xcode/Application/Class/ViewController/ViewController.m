//
//  ViewController.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SlideModel.h"
#import "ChatMessageVO.h"
#import "UserManager.h"
#import "ContactManager.h"

@implementation ViewController

@synthesize brandNav;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.presentationModel = [PresentationModel presentationModelWithPlistFile:@"RegroupdUI.plist"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"%s", __FUNCTION__);
//    _isOnHomeSlide = YES;
//    _selectedButton = [_navigationButtons objectAtIndex:0];
    
    [super viewDidLoad];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
//    UserManager *userSvc = [[UserManager alloc] init];
//    UserVO *user = [userSvc lookupDefaultUser];
//    [DataModel shared].user = user;

    NSNumber *numIndex;
    navMap = [[NSMutableDictionary alloc] init];
    numIndex = [NSNumber numberWithInt:1];
    [navMap setObject:@"GroupsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:2];
    [navMap setObject:@"ChatsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:3];
    [navMap setObject:@"FormsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:4];
    [navMap setObject:@"ContactsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:5];
    [navMap setObject:@"SettingsHome" forKey:numIndex];

    brandNav = [[TabBarView alloc] init];

    
    NSLog(@"dimensions = %i x %i", [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    
    CGRect frame = CGRectMake(0, [DataModel shared].stageHeight - 63, [DataModel shared].stageWidth, 63);
    brandNav.frame = frame;
    brandNav.hidden = YES;
    [self.view addSubview:brandNav];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNavNotificationHandler:)     name:@"hideNavNotification"            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNavNotificationHandler:)     name:@"showNavNotification"            object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMaskNotificationHandler:)     name:@"hideMaskNotification"            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMaskNotificationHandler:)     name:@"showMaskNotification"            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchNavNotificationHandler:)     name:@"switchNavNotification"            object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundPushNotificationReceived:)     name:k_chatPushNotificationReceived            object:nil];

//    [self performSelector:@selector(startNewProfile) withObject:nil afterDelay:1];
    // Do any additional setup after loading the view, typically from a nib.
//    [self startNewProfile];
    [self gotoSlideWithName:kSlideHome andOverrideTransition:kPresentationTransitionAuto];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    self.popOverNavigation = nil;
//    self.tabBar = nil;
//    self.navigationButtons = nil;
//    self.espButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark - Notification handlers
- (void)hideNavNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    brandNav.hidden = YES;
    
}
- (void)showNavNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    brandNav.hidden = NO;
}
- (void)hideMaskNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    if (navMask != nil) {
        [navMask removeFromSuperview];
        navMask = nil;
    }
    
}
- (void)showMaskNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    CGRect navFrame = brandNav.frame;
    navMask = [[UIView alloc] initWithFrame:navFrame];
    navMask.backgroundColor = [UIColor grayColor];
    navMask.alpha = 0;

    [self.view addSubview:navMask];
}

- (void)switchNavNotificationHandler:(NSNotification*)notification
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    NSNumber *numIndex = [NSNumber numberWithInt:[DataModel shared].navIndex];
    [brandNav moveLayerToIndex:numIndex.intValue];
    NSString *target;
    if (notification.object) {
        target = (NSString *) notification.object;
    } else {
        target = [navMap objectForKey:numIndex];
    }
    
    
    NSLog(@"Switch to slide %@", target);
    [_activeSlide.delegate gotoSlideWithName:target andOverrideTransition:kPresentationTransitionFade];
    
}

- (void)backgroundPushNotificationReceived:(NSNotification*)notification
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    NSLog(@"Current screen is %@", _activeSlide.slideModel.name);
    if (notification.object != nil) {
        ChatMessageVO *msg = (ChatMessageVO *) notification.object;
        if (chatSvc == nil) {
            chatSvc = [[ChatManager alloc] init];
        }
        [chatSvc apiLoadChat:msg.chat_key callback:^(ChatVO *chat) {
            [DataModel shared].chat =  chat;
            [DataModel shared].mode = @"Chats";
            
            if ([_activeSlide.slideModel.name isEqualToString:@"Chat"]) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_chatRefreshNotification object:msg]];

            } else {
                [_activeSlide.delegate gotoSlideWithName:@"Chat" andOverrideTransition:kPresentationTransitionFade];

            }
        }];
        
    }
    
}

#pragma mark - menu button tap handlers

- (void)setSelectedButton:(UIButton *)selectedButton {
        
//    _selectedButton.selected = NO;
//    _selectedButton = selectedButton;
//    _selectedButton.selected = YES;
}

- (void)onHomeButtonTapped:(id)sender {
    
//    if (self.isTransitioning) {
//        return;
//    }
//    
//    _lastSelectedButton = sender;
//
//    _isOnHomeSlide = YES;
//    _isOnEspSlide = NO;
//    _espButton.selected = NO;
//    
//    if ([self isDifferentSection:kSlideHome]) { 
//        [self gotoSlideWithName:kSlideHome andOverrideTransition:kPresentationTransitionFadeInFadeOut];
//        self.selectedButton = (UIButton*)sender;
//    }
}

     
- (BOOL)isDifferentSection:(NSString *)slideId 
{
    BOOL isDifferent = NO;
    SlideModel *toSlide = [_presentationModel slideWithName:slideId];
    if (![toSlide.category isEqualToString:_activeSlide.slideModel.category]) {
        isDifferent = YES;
    }
    
    return isDifferent;
}

- (void)removePopOver
{
//    self.selectedButton = _lastSelectedButton;
//
//    if (_isOnHomeSlide && ((SlideHomeVideoVC*)self.activeSlide).isPlaying) {
//        [((SlideHomeVideoVC*)self.activeSlide) playVideo];
//    }
    
//    [_overlayView setAlpha:0];
//    [_tabBarOverlayView setAlpha:0];
//    [_overlayView removeFromSuperview];
//    [_tabBarOverlayView removeFromSuperview];
//    [_popOverNavigation removeFromSuperview];
}
-(void) showPrimaryNav {
    
}
-(void) hidePrimaryNav {
    
}

- (void) startNewProfile
{
    NSLog(@"%s", __FUNCTION__);
    
    // allocate a reachability object
    //    Reachability* reach = [Reachability reachabilityWithHostname:@"www.parse.com"];
    //
    //    reach.reachableBlock = ^(Reachability*reach)
    //    {
    
    
    __block BOOL hasAccount = NO;
    
    UserManager *userSvc = [[UserManager alloc] init];
    UserVO *user = [userSvc lookupDefaultUser];
    PFUser *u;
    
    if (user == nil) {
        // TODO: Attempt to login
        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    } else if ([PFUser currentUser] == nil) {
        // db user is not nil.  Try to login
        NSLog(@"db user does not exist");
        
        //        u = [PFUser logInWithUsername:user.username password:user.password];
        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    } else if ([PFUser currentUser] != nil) {
        
        [DataModel shared].user = user;
        
        u = [PFUser currentUser];
        NSLog(@"Current user is %@, %@", u.username, u.objectId);
        [userSvc apiLookupContactForUser:u callback:^(PFObject *pfContact) {
            if (pfContact != nil) {
                NSLog(@"Valid user is %@, user_key=%@, contact_key=%@", u.username, u.objectId, pfContact.objectId);
                ContactVO *contact = [ContactVO readFromPFObject:pfContact];
                [DataModel shared].myContact = contact;
                [DataModel shared].user.contact_key = pfContact.objectId;
                [DataModel shared].navIndex = 3;
                hasAccount = YES;
                // post notification to switch to new tab (in ViewController)
                NSNotification* switchNavNotification = [NSNotification notificationWithName:@"switchNavNotification" object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:switchNavNotification];
            } else {
                NSLog(@"No contact for user");
                [_delegate gotoSlideWithName:@"ProfileStart1"];
            }
        }];
        
    } else {
        // No-op. Condition not possible
        //        [_delegate gotoSlideWithName:@"ProfileStart1"];
        
    }
    
    //            [self performSelector:@selector(refreshData:) withObject:self afterDelay:2];
    //    };
    //
    //    reach.unreachableBlock = ^(Reachability*reach)
    //    {
    //        NSLog(@"UNREACHABLE!");
    //        [[[UIAlertView alloc] initWithTitle:@"Connection error" message:@"No Internet connection found. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    //
    //
    ////        [self stopLoadingAnimation];
    //    };
    
    // start the notifier which will cause the reachability object to retain itself!
    //    [reach startNotifier];
    
    
}



@end
