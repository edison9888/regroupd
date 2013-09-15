//
//  CalculatorKeyPadView.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorKeyPadView.h"

@implementation CalculatorKeyPadView

@synthesize enabled;
@synthesize delegate = _delegate;

- (id)init {
    NSLog(@"%s", __FUNCTION__);
    if ((self = [super init])) {
        
        _keysView = [[[NSBundle mainBundle] loadNibNamed:@"CalculatorKeyPadView" owner:self options:nil] objectAtIndex:0];
        [self addSubview:_keysView];
        
        for (UIButton *button in _keysView.subviews) {
            [button addTarget:self action:@selector(onKeyTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self setEnabled:YES];
    }
    return self;
}


#pragma mark - getters and seters

- (void)setEnabled:(BOOL)val {
    for (UIButton *button in _keysView.subviews) {
        button.enabled = val;
    }
}

#pragma mark - gesture handlers

- (void)onKeyTapped:(id)selector {
    if (_delegate || [_delegate respondsToSelector:@selector(calculatorKeyPadKeyPressed:)]) {
        [_delegate calculatorKeyPadKeyPressed:((UIView*)selector).tag];
    }
}

- (void)setKey:(CalculatorKeys)key enabled:(BOOL)val {
    
    UIButton *button = (UIButton*)[_keysView viewWithTag:key];
    button.enabled = val;
}

@end
