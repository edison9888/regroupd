//
//  ProfileHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"

@interface ProfileHomeVC : SlideViewController {
    UILabel *fullname;
    UILabel *title;
    UILabel *company;
    UILabel *address1;
    UILabel *address2;
    UILabel *phone;
    UIView *signaturebox;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *signatureView;

@property (nonatomic, strong) IBOutlet UILabel *fullname;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *company;
@property (nonatomic, strong) IBOutlet UILabel *address1;
@property (nonatomic, strong) IBOutlet UILabel *address2;
@property (nonatomic, strong) IBOutlet UILabel *phone;

@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet UIButton *editButton;

- (IBAction)tapEditButton;


@end
