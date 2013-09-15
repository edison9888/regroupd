//
//  KeypadViewController.h
//  Blocpad
//
//  Created by Hugh Lang on 3/30/13.
//
//

#import <UIKit/UIKit.h>
#import "CalculatorKeyPadView.h"

@protocol KeypadViewControllerDelegate <NSObject>
- (void)keyHandler:(CalculatorKeys)key;
@end

@interface KeypadViewController : UIViewController<CalculatorKeyPadViewDelegate> {
    id <KeypadViewControllerDelegate> __weak _delegate;
    
}

@property(nonatomic, strong) CalculatorKeyPadView *keyPadView;

@property (nonatomic, weak) id <KeypadViewControllerDelegate> delegate;


@end
