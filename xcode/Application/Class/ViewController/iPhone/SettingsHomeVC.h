//
//  SettingsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "FancyToggle.h"
#import "BrandUILabel.h"

@interface SettingsHomeVC : SlideViewController {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
    
    BOOL Setting_Notifications_Enabled;
    BOOL Setting_Notifications_Show_Preview;
    BOOL Setting_Add_To_Calendar;
}

@property (nonatomic, strong) IBOutlet FancyToggle *toggle1;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle2;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle3;

- (IBAction)tapClearAllButton;
- (IBAction)tapContactButton;
- (IBAction)tapProfileButton;



@end
