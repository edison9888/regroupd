//
//  FaxRecordViewVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "FaxRecordViewVC.h"
#import "UserVO.h"
#import "FaxManager.h"

@interface FaxRecordViewVC ()

@end

@implementation FaxRecordViewVC

@synthesize tf1, tf2;
//@synthesize nextButton, cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = @"FaxRecordViewVC";

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        navbarHeight = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *qtyLeftCaption = [FaxManager renderFaxQtyLabel:[DataModel shared].faxBalance];
    self.navCaption.text = qtyLeftCaption;

    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    CGSize scrollContentSize = CGSizeMake(320, 520);
    self.scrollView.contentSize = scrollContentSize;

    
    if ([DataModel shared].faxlog != nil) {
        self.tf1.text = [DataModel shared].faxlog.patient_name;
        self.tf2.text = [DataModel shared].faxlog.message;
    }
    
    
    self.scrollView.delegate = self;
        
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapCancelButton {
    [_delegate gotoPreviousSlide];
    
}
- (IBAction)tapNextButton {
    [_delegate gotoNextSlide];
}


@end
