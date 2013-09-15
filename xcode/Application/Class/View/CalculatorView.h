//
//  CalculatorView.h
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorKeyPadView.h"
#import "CalculatorEditableLabelView.h"

@protocol CalculatorViewDelegate <NSObject>
- (void)totalUpdated;
@end

@interface CalculatorView : UIView <CalculatorKeyPadViewDelegate> {
    
     id <CalculatorViewDelegate> __weak _delegate;
    CalculatorKeyPadView *_keyPadView;
        
    /**
     * editable label that is being editted
     */
    CalculatorEditableLabelView *_focusedLabel;
    
    /**
     * button for label that is being editted
     */
    UIButton *_focusedLabelButton;
    
    /**
     * total value for calculator
     */
    CGFloat _total;
    
    /**
     * total label in calculator
     */
    CalculatorEditableLabelView *_totalLabelView;
    
    /**
     * total label in trigger button
     */
    UILabel *_buttonTotalLabel;

}

@property(nonatomic, weak) IBOutlet id<CalculatorViewDelegate> delegate;
@property(nonatomic, strong) IBOutlet CalculatorKeyPadView *keyPadView;
@property(nonatomic, strong) CalculatorEditableLabelView *focusedLabel;
@property(nonatomic, strong) UIButton *focusedLabelButton;
@property(nonatomic, assign) CGFloat total;
@property(nonatomic, strong) IBOutlet CalculatorEditableLabelView *totalLabelView;

/**
 * updates total labels add logic in subclass to calculate totals
 */
- (void)recalculate;

/**
 * messages delegate updateTotals
 */
- (void)updateTotals;

/**
 * sets focus views to nil and hides cursor
 */
- (void)blur;

- (void)updated;

@end

