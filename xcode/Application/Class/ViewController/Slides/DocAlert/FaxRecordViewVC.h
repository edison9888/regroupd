//
//  FaxRecordViewVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "BrandUITextField.h"

@interface FaxRecordViewVC : SlideViewController<UIScrollViewDelegate>
{
    IBOutlet BrandUITextField *tf1;
    IBOutlet UITextView *tf2;
    
    
    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet UITextView *tf2;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)tapCancelButton;
- (IBAction)tapNextButton;


@end
