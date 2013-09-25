//
//  NewPollVC.h
//  Regroupd
//
//  Created by Hugh Lang on 9/21/13.
//
//

#import "SlideViewController.h"
#import "FancyCheckbox.h" 
#import "FancyTextField.h"

@interface NewPollVC : SlideViewController<UIScrollViewDelegate, UITextFieldDelegate> {
 
    CGPoint  offset;
    UITextField *_currentField;
    BOOL keyboardIsShown;
    int navbarHeight;

}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPublic;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckPrivate;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleYes;
@property (nonatomic, retain) IBOutlet FancyCheckbox *ckMultipleNo;


@end
