//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "ChatMessageVO.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAppearanceContainer>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

@property (nonatomic, strong) NSString *notificationKey;
@property (nonatomic, strong) ChatMessageVO *lastMessage;


@end
