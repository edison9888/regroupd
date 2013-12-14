//
//  ViewController.h
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentationViewController.h"
#import "TabBarView.h"
#import "MBProgressHUD.h"

#import "UserManager.h"
#import "ChatManager.h"

@interface ViewController : PresentationViewController {
    TabBarView *brandNav;
    NSMutableDictionary *navMap;
    UIView *navMask;
    
    ChatManager *chatSvc;
    
}

@property(nonatomic, strong) TabBarView *brandNav;
@property (nonatomic, strong) MBProgressHUD *hud;

//@property (nonatomic, strong) IBOutlet UIView *popOverNavigation;
//@property (nonatomic, strong) UIView *overlayView;
//@property (nonatomic, strong) UIView *tabBarOverlayView;
//@property (nonatomic, strong) IBOutlet UIView *tabBar;
//@property (nonatomic, strong) IBOutlet UIButton *espButton;
//@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *navigationButtons;
//@property (nonatomic, strong) UIButton *selectedButton;
//@property (nonatomic, strong) UIButton *lastSelectedButton;
//@property (nonatomic, assign) BOOL isOnHomeSlide;
//@property (nonatomic, assign) BOOL isOnEspSlide;
//
//- (IBAction)onHomeButtonTapped:(id)sender;
//- (IBAction)onHerdRiskButtonTapped:(id)sender;
//- (IBAction)onImpactButtonTapped:(id)sender;
//- (IBAction)onSolutionsButtonTapped:(id)sender;
//- (IBAction)onESPButtonTapped:(id)sender;
//- (IBAction)onESPTechnicalServicesButtonTapped:(id)sender;
//- (IBAction)onESPStompButtonTapped:(id)sender;
//- (IBAction)onESPRespiSureButtonTapped:(id)sender;
//- (IBAction)onESPLincomixButtonTapped:(id)sender;
//- (IBAction)onESPDraxxinButtonTapped:(id)sender;
//- (BOOL)isDifferentSection:(NSString *)slideId;
//- (void)removePopOver;

-(void) showPrimaryNav;
-(void) hidePrimaryNav;


@end
