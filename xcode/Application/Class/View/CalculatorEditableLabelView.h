//
//  CalculatorEditableLabelView.h
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorEditableLabelView : UIView {
    
    /**
     * label used to display text
     */
    UILabel *_label;
    
    /**
     * the text displayed in the label
     */
    NSString *_text;
    
    /**
     * current value enter by user
     */
    NSString *_enteredText;
    
    /**
     * float value of text by stripping commas
     */
    CGFloat _floatValue;
    
    UILabel *_dollarSignLabel;
    UILabel *_percentageSignLabel;
    
    BOOL _isFocused;
    
    BOOL _showDollarSign;
    BOOL _showPercentageSign;
    NSString *_placeHolderText;
    NSUInteger _maxCharacters;
    NSUInteger _minCharacters;
    NSUInteger _maxDecimalPlaces;
    NSUInteger _maximumValue;
    
    BOOL _testing;
}

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *enteredText;
@property (nonatomic, assign) CGFloat floatValue;
@property (nonatomic, strong) UILabel *dollarSignLabel;
@property (nonatomic, strong) UILabel *percentageSignLabel;
@property (nonatomic, assign) BOOL isFocused;
@property (nonatomic, assign) BOOL showDollarSign;
@property (nonatomic, assign) BOOL showPercentageSign;
@property (nonatomic, strong) NSString *placeHolderText;
@property (nonatomic, assign) NSUInteger maxCharacters;
@property (nonatomic, assign) NSUInteger minCharacters;
@property (nonatomic, assign) NSUInteger maxDecimalPlaces;
@property (nonatomic, assign) NSUInteger maximumValue;

@property (nonatomic, assign) BOOL testing;

- (void)addCharacterString:(NSString*)character;
- (void)removeLastCharacter;
- (void)update;

@end
