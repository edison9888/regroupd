//
//  ProfileStart2aVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"

@interface ProfileStart2aVC : SlideViewController<UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton *nextButton;

    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf2;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)goNext;

@end
