//
//  CalculatorView.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorView.h"

@interface CalculatorView()
- (void)updateKeyPad;
@end

@implementation CalculatorView

@synthesize delegate = _delegate;
@synthesize keyPadView = _keyPadView;
@synthesize focusedLabel = _focusedLabel;
@synthesize totalLabelView = _totalLabelView;
@synthesize focusedLabelButton = _focusedLabelButton;
@synthesize total = _total;

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    _keyPadView.enabled = NO;
    
    UIFont *font = [UIFont fontWithName:@"FSAlbert-Bold" size:80];
    _totalLabelView.label.font = font;
}


#pragma mark - calculate total

- (void)recalculate {

    _totalLabelView.text = [NSString stringWithFormat:@"%.2f", _total]; 
    
    [_totalLabelView update];
}

- (void)updateTotals {
    
    if (_delegate && [_delegate respondsToSelector:@selector(totalUpdated)]) {
        [_delegate totalUpdated];
    }
}

#pragma mark - getters and setters

- (void)blur {
    
    _focusedLabel.isFocused = NO;
    _focusedLabel = nil;
    _focusedLabelButton.selected = NO;
    _focusedLabelButton = nil;
}

- (void)setFocusedLabel:(CalculatorEditableLabelView *)focusedLabel {
    
    BOOL shouldSelect = YES;
    if (_focusedLabel == focusedLabel) {
        shouldSelect = NO;
    }

    //unfocus last label
    if (_focusedLabel != nil) {
        _focusedLabel.isFocused = NO;
    }
    _focusedLabel = nil;
    
    if (shouldSelect) {
        _focusedLabel = focusedLabel;
        focusedLabel.isFocused = YES;
        [self updateKeyPad];
    }else{
        _keyPadView.enabled = NO;
    }
}

- (void)setFocusedLabelButton:(UIButton *)focusedLabelButton {
    
    _focusedLabelButton.selected = NO;
    
    BOOL shouldSelect = YES;
    if (_focusedLabelButton == focusedLabelButton) {
        shouldSelect = NO;
        _focusedLabelButton = nil;
    }

    if (shouldSelect) {
        _focusedLabelButton = focusedLabelButton;
        _focusedLabelButton.selected = YES;
    }
}

#pragma mark - Calculator KeyPad Delegate

- (void)calculatorKeyPadKeyPressed:(CalculatorKeys)key {
    
    switch (key) {
        case CalculatorKeysBack:
            [_focusedLabel removeLastCharacter];
            break;
            
        case CalculatorKeysDecimal:
            [_focusedLabel addCharacterString:@"."];
            break;

        case CalculatorKeysEnter:
            
            break;

        default:
            [_focusedLabel addCharacterString:[NSString stringWithFormat:@"%i", key]];
            break;
    }
    
    [self updated];
}

- (void)updated {
    [self updateKeyPad];
    [self recalculate];
    [self updateTotals];
}

- (void)updateKeyPad {
    
    NSString *labelValue = _focusedLabel.label.text;
    labelValue = [labelValue stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSRange decimalRange = [labelValue rangeOfString:@"."];
    NSUInteger decimalLocation = (decimalRange.location == NSNotFound) ? 0 : decimalRange.location;
    
    //disable all keys but back if at max characters && //check if max decimal range is reached
    BOOL disableAddingNewCharacters = NO;
    
    //check for max decimal places
    if (decimalLocation > 0 && (labelValue.length - decimalLocation - 1) == _focusedLabel.maxDecimalPlaces) {
        disableAddingNewCharacters = YES;
    }
    
    //check for max characters to the left of the decimal
    if (decimalLocation == 0 && labelValue.length == _focusedLabel.maxCharacters) {
        disableAddingNewCharacters = YES;
    }
    
    if (disableAddingNewCharacters) {
        _keyPadView.enabled = NO;
        [_keyPadView setKey:CalculatorKeysBack enabled:YES]; 
    }else {
        _keyPadView.enabled = YES;
    }
    
    //disable decimal key if decimal is in value
    [_keyPadView setKey:CalculatorKeysDecimal enabled:(decimalLocation == 0)];
    
    //disable back button if value is placeholder
    [_keyPadView setKey:CalculatorKeysBack enabled:![labelValue isEqualToString:_focusedLabel.placeHolderText]];
}

@end
