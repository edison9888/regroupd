//
//  AppDelegate.m
//
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SQLiteDB.h"
#import <Parse/Parse.h>
#import "ChatMessageVO.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize networkStatus;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    NSLog(@"Fonts: %@", [UIFont fontNamesForFamilyName:@"NotoSans"] );
    
    //  #################### PARSE SETUP #####################
    //    https://www.parse.com/apps/quickstart#ios/native/existing
    
    [Parse setApplicationId:@"Xsf11WQNwFxIyu6rM447OTYtrvj5qSNNc5EX93Qt"
                  clientKey:@"ZlDNsNZE4KaiDdyOp9HQC6oPxP85NO2gAJn7tTtQ"];
    
    //    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //  #################### /PARSE SETUP #####################
    [self performSelector:@selector(finishLaunchingApp) withObject:self afterDelay:0];

    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];

    [DataModel shared].needsLookup = YES;
    [DataModel shared].contactCache = [[NSMutableDictionary alloc] init];
    [DataModel shared].phonebookCache = [[NSMutableDictionary alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"tabbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [SQLiteDB installDatabase];

    [DataModel shared].stageWidth = [[UIScreen mainScreen] bounds].size.width;
    [DataModel shared].stageHeight = [[UIScreen mainScreen] bounds].size.height;
    [DataModel shared].anonymousImage = [UIImage imageNamed:@"anonymous_user.png"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // code here
        self.window.clipsToBounds =YES;
        self.window.frame =  CGRectMake(0,0,self.window.frame.size.width,self.window.frame.size.height);
    } else {
        self.window.clipsToBounds =NO;
        
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height);
        
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    

    return YES;
}

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:ReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName: @"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}
//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    
    if ([self isParseReachable] && [PFUser currentUser]) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
//        [self.homeViewController loadObjects];
    }
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void) finishLaunchingApp {
    

    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    if (_viewController.isOnHomeSlide) {
//        [_viewController removePopOver];
//        
//        if ([_viewController.activeSlide.slideModel.name isEqualToString:kSlideHome]) {
//            [((SlideHomeVideoVC*)_viewController.activeSlide) restartVideo];
//        }else{
//            [_viewController gotoSlideWithName:kSlideHome andOverrideTransition:kPresentationTransitionCut];
//        }
//    }
    
//    _viewController.isTransitioning = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{        
    NSLog(@"%s", __FUNCTION__);
    [DataModel shared].needsLookup = YES;
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"newDeviceToken %@", newDeviceToken);
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    /*
     NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
     @"Increment", @"badge",
     msg.contact_key, @"contact",
     chatId, @"chat",
     pfMessage.objectId, @"msg",
     msg.createdAt, @"dt",
     nil];
     */
    NSString *text;
    ChatMessageVO *msg = [[ChatMessageVO alloc] init];
    
    text = (NSString *) [userInfo objectForKey:@"contact"];
    if (text) {
        msg.contact_key = text;
    }
    text = (NSString *) [userInfo objectForKey:@"chat"];
    if (text) {
        msg.chat_key = text;
    }
    text = (NSString *) [userInfo objectForKey:@"msg"];
    if (text) {
        msg.system_id = text;
    }
    if ([userInfo objectForKey:@"dt"]) {
        msg.createdAt = (NSDate *)[userInfo objectForKey:@"dt"];
    }
    if ([msg.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
        // ignore
    } else {
        NSLog(@"####### contact_key=%@", msg.contact_key);
        NSLog(@"####### chat_key=%@", msg.chat_key);
        NSLog(@"####### msg_key=%@", msg.system_id);
        
//        [PFPush handlePush:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_chatPushNotificationReceived object:msg]];
        
    }
    
//

//
//
//    [PFPush handlePush:userInfo];
//    NSString *value;
//    
//    for (NSString *key in userInfo) {
//        value = (NSString *)[userInfo objectForKey:key];
//        
//        NSLog(@"Received push notification %@ = %@", key, value);
//    }
}

@end
