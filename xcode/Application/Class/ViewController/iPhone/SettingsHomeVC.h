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
}

@property (nonatomic, strong) IBOutlet FancyToggle *toggle1;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle2;
@property (nonatomic, strong) IBOutlet FancyToggle *toggle3;

@property (nonatomic, strong) IBOutlet BrandUILabel *value1;
@property (nonatomic, strong) IBOutlet BrandUILabel *value2;
@property (nonatomic, strong) IBOutlet BrandUILabel *value3;
@property (nonatomic, strong) IBOutlet BrandUILabel *value4;

- (IBAction)tapClearAllButton;
- (IBAction)tapContactButton;
- (IBAction)tapProfileButton;



@end
