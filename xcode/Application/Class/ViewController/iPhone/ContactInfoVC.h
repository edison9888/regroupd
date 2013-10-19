//
//  ContactInfoVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUILabel.h"
#import "BrandUIButton.h"

@interface ContactInfoVC : SlideViewController {
    
}

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUIButton *messageButton;
@property (nonatomic, strong) IBOutlet BrandUIButton *phoneButton;

- (IBAction)tapBackButton;
- (IBAction)tapMessageButton;
- (IBAction)tapPhoneButton;
- (IBAction)tapGroupsButton;
- (IBAction)tapBlockButton;


@end
