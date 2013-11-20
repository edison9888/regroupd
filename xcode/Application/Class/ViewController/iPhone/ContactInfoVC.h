//
//  ContactInfoVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "ContactManager.h"
#import "ChatManager.h"

#import "BrandUILabel.h"
#import "BrandUIButton.h"

@interface ContactInfoVC : SlideViewController {
    ContactManager *contactSvc;
    ChatManager *chatSvc;
}

@property (nonatomic, strong) IBOutlet PFImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUIButton *messageButton;
@property (nonatomic, strong) IBOutlet BrandUIButton *phoneButton;

- (IBAction)tapBackButton;
- (IBAction)tapMessageButton;
- (IBAction)tapPhoneButton;
- (IBAction)tapGroupsButton;
- (IBAction)tapBlockButton;


@end
