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

-(void) showPrimaryNav;
-(void) hidePrimaryNav;


@end
