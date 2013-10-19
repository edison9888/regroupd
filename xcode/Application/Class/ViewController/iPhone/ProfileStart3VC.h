//
//  ProfileStart3VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"

@interface ProfileStart3VC : SlideViewController<UIAlertViewDelegate>
{
    CGPoint  offset;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIButton *yesButton;
@property (nonatomic, strong) IBOutlet UIButton *noButton;

- (IBAction)tapYesButton;
- (IBAction)tapNoButton;

@end
