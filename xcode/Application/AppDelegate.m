//
//  AppDelegate.m
//
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SQLiteDB.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
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
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
//  #################### /PARSE SETUP #####################
    
    [DataModel shared].needsLookup = YES;
    [DataModel shared].contactCache = [[NSMutableDictionary alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"tabbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [SQLiteDB installDatabase];
    sleep(2);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // code here
        [DataModel shared].stageWidth = [[UIScreen mainScreen] bounds].size.width;
        [DataModel shared].stageHeight = [[UIScreen mainScreen] bounds].size.height;
    } else {
        [DataModel shared].stageWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        [DataModel shared].stageHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    

    return YES;
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

@end
