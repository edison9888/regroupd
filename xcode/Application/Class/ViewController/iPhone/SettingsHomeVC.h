//
//  SettingsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "FancyToggle.h"

@interface SettingsHomeVC : SlideViewController {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
}

@property (nonatomic, strong) IBOutlet FancyToggle *toggle1;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle2;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle3;

- (IBAction)tapClearAllButton;
- (IBAction)tapContactButton;


@end
