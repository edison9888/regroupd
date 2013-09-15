//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAppearanceContainer>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;

@end
