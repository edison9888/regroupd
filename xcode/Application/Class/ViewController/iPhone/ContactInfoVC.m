//
//  ContactInfoVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "ContactInfoVC.h"

@interface ContactInfoVC ()

@end

@implementation ContactInfoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    
    [self.roundPic.layer setCornerRadius:66.0f];
    [self.roundPic.layer setMasksToBounds:YES];
    [self.roundPic.layer setBorderWidth:3.0f];
    [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.roundPic.clipsToBounds = YES;
    self.roundPic.contentMode = UIViewContentModeScaleAspectFill;

    UIImage *img;
    
    img = [UIImage imageNamed:@"anonymous_user"];
    self.roundPic.image = img;
    
    self.nameLabel.text = [DataModel shared].contact.name;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBActions

- (IBAction)tapBackButton {
    [_delegate gotoSlideWithName:@"ContactsHome" andOverrideTransition:kPresentationTransitionAuto];
    
}
- (IBAction)tapMessageButton {
    
}
- (IBAction)tapPhoneButton {
    
}
- (IBAction)tapGroupsButton {
    
}
- (IBAction)tapBlockButton {
    
}

@end
