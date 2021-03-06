//
//  GroupInfoVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "ChatManager.h"
#import "GroupManager.h"
#import "ContactManager.h"

#import "BrandUILabel.h"
#import "BrandUIButton.h"

@interface GroupInfoVC : SlideViewController {
    ChatManager *chatSvc;
    GroupManager *groupSvc;
    ContactManager *contactSvc;
}

@property (nonatomic, strong) IBOutlet UIView *bodyView;

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUIButton *messageButton;
@property (nonatomic, strong) IBOutlet BrandUIButton *phoneButton;

@property (nonatomic, strong) IBOutlet UIView *actionsheet;
@property (nonatomic, strong) IBOutlet BrandUIButton *deleteYesButton;
@property (nonatomic, strong) IBOutlet BrandUIButton *deleteNoButton;


- (IBAction)tapBackButton;
- (IBAction)tapMessageButton;
- (IBAction)tapManageButton;
- (IBAction)tapDeleteButton;

- (IBAction)tapDeleteYesButton;
- (IBAction)tapDeleteNoButton;


@end
