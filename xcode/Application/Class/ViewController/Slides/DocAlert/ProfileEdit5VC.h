//
//  ProfileEdit5VC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"

@interface ProfileEdit5VC : SlideViewController<UITextFieldDelegate, UIScrollViewDelegate>
{
    IBOutlet BrandUITextField *tf1;
    IBOutlet BrandUITextField *tf2;
    IBOutlet BrandUITextField *tf3;
    IBOutlet BrandUITextField *tf4;
    IBOutlet UIImageView *pagedot1;
    IBOutlet UIImageView *pagedot2;
    IBOutlet UIImageView *pagedot3;
    IBOutlet UIImageView *pagedot4;
    IBOutlet UIImageView *pagedot5;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *nextButton;
    
    IBOutlet UILabel *label1;
    
    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf2;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf3;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf4;

@property (nonatomic, strong) IBOutlet UIImageView *pagedot1;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot2;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot3;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot4;
@property (nonatomic, strong) IBOutlet UIImageView *pagedot5;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) IBOutlet UILabel *label1;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

- (IBAction)tapCancelButton;
- (IBAction)tapDoneButton;

- (IBAction)goBack;
- (IBAction)goNext;

@end
