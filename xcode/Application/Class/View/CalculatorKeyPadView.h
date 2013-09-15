//
//  CalculatorKeyPadView.h
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CalculatorKeys0 = 0,
    CalculatorKeys1,
    CalculatorKeys2,
    CalculatorKeys3,
    CalculatorKeys4,
    CalculatorKeys5,
    CalculatorKeys6,
    CalculatorKeys7,
    CalculatorKeys8,
    CalculatorKeys9,
    CalculatorKeysDecimal,
    CalculatorKeysBack,
    CalculatorKeysEnter,
} CalculatorKeys;

@protocol CalculatorKeyPadViewDelegate <NSObject>
- (void)calculatorKeyPadKeyPressed:(CalculatorKeys)key;
@end

@interface CalculatorKeyPadView : UIView {
    id <CalculatorKeyPadViewDelegate> __weak _delegate;
    UIView *_keysView;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, weak) IBOutlet id <CalculatorKeyPadViewDelegate> delegate;

- (void)setKey:(CalculatorKeys)key enabled:(BOOL)val;

@end
