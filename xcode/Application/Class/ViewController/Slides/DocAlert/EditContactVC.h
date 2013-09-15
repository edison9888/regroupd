//
//  EditContactVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "BrandUITextField.h"
#import "SQLiteDB.h"

@interface EditContactVC : SlideViewController<UITextFieldDelegate, UIScrollViewDelegate> {
    
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;
    FMDatabaseQueue *dbqueue;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UILabel *navTitle;
@property (nonatomic, strong) IBOutlet UILabel *navCaption;

@property (nonatomic, strong) IBOutlet BrandUITextField *tf1;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf2;
@property (nonatomic, strong) IBOutlet BrandUITextField *tf3;

@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)goBack;
- (IBAction)goNext;

- (IBAction)tapSendButton;

@end
