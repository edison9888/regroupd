//
//  ProfileStart1VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"

@interface ProfileStart1VC : SlideViewController<UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
    IBOutlet BrandUITextField *tf1;
    IBOutlet UIButton *nextButton;

    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)goNext;

@end
