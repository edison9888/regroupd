//
//  CalculatorEditableLabelView.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorEditableLabelView.h"
#import "NSString+NumberFormat.h"
#import <QuartzCore/QuartzCore.h>

@interface CalculatorEditableLabelView () {
    UIView *_cursor;
    NSString *_nonDollarBlankDefault;
}

@end


@implementation CalculatorEditableLabelView

@synthesize label = _label;
@synthesize text = _text;
@synthesize enteredText = _enteredText;
@synthesize floatValue = _floatValue;
@synthesize dollarSignLabel = _dollarSignLabel;
@synthesize percentageSignLabel = _percentageSignLabel;
@synthesize isFocused = _isFocused;
@synthesize showDollarSign = _showDollarSign;
@synthesize showPercentageSign = _showPercentageSign;
@synthesize placeHolderText = _placeHolderText;
@synthesize maxCharacters = _maxCharacters;
@synthesize minCharacters = _minCharacters;
@synthesize maxDecimalPlaces = _maxDecimalPlaces;
@synthesize maximumValue = _maximumValue;

@synthesize testing = _testing;

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        _nonDollarBlankDefault = @"- -";
        
        _placeHolderText = @"";
        _maxCharacters = 4;
        _minCharacters = 0;
        _maxDecimalPlaces = 2;
        //_maximumValue = nil;

        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 2 * 5, self.frame.size.height)];
        _label.textColor = [UIColor whiteColor];
        _label.minimumFontSize = 10;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.shadowColor = [UIColor darkGrayColor];
        _label.shadowOffset = CGSizeMake(0, -1);
        
        _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 50)];
        _cursor.backgroundColor = [UIColor colorWithRed:130.0 green:197.0 blue:225.0 alpha:0.5];
        _cursor.hidden = YES;
        [self addSubview:_cursor];
        
        self.enteredText = _placeHolderText;
        _label.text = self.enteredText;
                
        [self addSubview:_label];        
    }
    return self;
}



#pragma mark - getters and setters

- (void)setShowDollarSign:(BOOL)showDollarSign 
{
    if (!_showDollarSign) {
        _dollarSignLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _dollarSignLabel.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont fontWithName:@"FSAlbert-Light" size:_label.font.pointSize / 2];
        _dollarSignLabel.font = font;
        _dollarSignLabel.textColor = [UIColor colorWithRed:0.47 green:0.835 blue:0.976 alpha:1.0];
        _dollarSignLabel.shadowColor = _label.shadowColor;
        _dollarSignLabel.shadowOffset = _label.shadowOffset;
        _dollarSignLabel.text = @"$";
        [self addSubview:_dollarSignLabel];
    }
    _showDollarSign =  showDollarSign;
}

- (void)setShowPercentageSign:(BOOL)showPercentageSign
{
    if (!_showPercentageSign) {
        
        _maxCharacters = 3;
        _maximumValue = 100;
        
        _percentageSignLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 0, 50, 50)];
        _percentageSignLabel.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont fontWithName:@"FSAlbert-Light" size:_label.font.pointSize / 2];
        _percentageSignLabel.font = font;
        _percentageSignLabel.textColor = [UIColor colorWithRed:0.47 green:0.835 blue:0.976 alpha:1.0];
        _percentageSignLabel.shadowColor = _label.shadowColor;
        _percentageSignLabel.shadowOffset = _label.shadowOffset;
        _percentageSignLabel.text = @"%";
        [self addSubview:_percentageSignLabel];
    }
    _showPercentageSign =  showPercentageSign;
}

//- (void)setDefaultText:(NSString *)value {
//    _enteredText = value;
//    _defaultText = value;
//    [self update];
//}

- (void)setText:(NSString *)text {
    
    if (_minCharacters && _minCharacters > 0) {
         self.enteredText = [text substringToIndex:text.length - (_minCharacters - 1)];
    }else {
         self.enteredText = text;
    }
    
    [self update];
}

- (NSString*)text {
    return _label.text;
}

- (CGFloat)floatValue {
    
    return [[_label.text stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
}

- (void)setIsFocused:(BOOL)isFocused {

    _cursor.hidden = !isFocused;
    if (isFocused) {
        
        //animate blicking cursor
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
                             _cursor.alpha = 0.0;
                         }
                         completion:NULL
                         ];
        
        //add glow to label
        _label.layer.shadowColor = [[UIColor whiteColor] CGColor]; 
        _label.layer.shadowOffset = CGSizeMake(0, 0);
        _label.layer.shadowOpacity = 1;
        _label.layer.shadowRadius = 6;
        _label.layer.masksToBounds = NO;
        
    }else{
        _label.layer.shadowRadius = 0;
        [_cursor.layer removeAllAnimations];
        _cursor.alpha = 1.0;
    }
    
    _isFocused = isFocused;
    
    if (!_isFocused && !_minCharacters) {
        [self update];
    }
}


#pragma mark - edit text

- (void)addCharacterString:(NSString*)character {
        
    if (_enteredText == _placeHolderText) {
        self.enteredText = @"";
    }
    
    if ([_enteredText isEqualToString:@"0"]) {
        _enteredText = @"";
    }
    
    self.enteredText = [NSString stringWithFormat:@"%@%@", _enteredText, character];
    
    [self update];
}

- (void)removeLastCharacter {
    
    self.enteredText = [self.enteredText substringToIndex:_enteredText.length - 1];
    
    if (_enteredText.length == 0) {
        self.enteredText = _placeHolderText;
    }
    
    [self update];
}

- (void)update {
    
    BOOL adjustCursorPositionForMinCharacters = NO;
    if (_isFocused) {
       _cursor.hidden = NO; 
    }
    
    //add trailing zeros if required
    if (![_enteredText isEqualToString:_placeHolderText] && _minCharacters > 0) {
        
        NSString *zeros = @"";
        NSUInteger zeroMultiplier = 1;
        for (NSUInteger i = 0; i < _minCharacters - 1; i++){
            zeros = [NSString stringWithFormat:@"%@0", zeros];
            zeroMultiplier *= 10;
        }
        _label.text = [[NSString stringWithFormat:@"%@%@", _enteredText, zeros] formatWithCommas];
        adjustCursorPositionForMinCharacters = YES;
        
        if (_maximumValue && _enteredText.floatValue * zeroMultiplier > _maximumValue){
            _label.text = [[NSString stringWithFormat:@"%i", _maximumValue] formatWithCommas];
            _cursor.hidden = YES;
        }
    
    //in case of text equalling placeholder
    }else if ([_enteredText isEqualToString:_placeHolderText]){
        _label.text = _placeHolderText;
        
    //add 0 start of . value
    }else if ([_enteredText isEqualToString:@"."]) {
        _label.text = @"0.";
    }else{
        
        _label.text = [_enteredText formatWithCommas];
        
        //check for max value
        if (_maximumValue && (_enteredText.floatValue) > _maximumValue){
            _label.text = [NSString stringWithFormat:@"%i", _maximumValue];
            _cursor.hidden = YES;
        }
        
        //in case of numbers ending in .0 
        if (_enteredText.length > 1 && [[_enteredText substringFromIndex:_enteredText.length - 2] isEqualToString:@".0"]) {
            _label.text = [NSString stringWithFormat:@"%@.0", _label.text];
        }
        
        else if (_enteredText.length > 2 && [[_enteredText substringFromIndex:_enteredText.length - 3] isEqualToString:@".00"]) {
            _label.text = [NSString stringWithFormat:@"%@.00", _label.text];
        }
        
        //in case of numbers ending in . 
        else if ([[_enteredText substringFromIndex:_enteredText.length - 1] isEqualToString:@"."] && _minCharacters == 0) {
            _label.text = [NSString stringWithFormat:@"%@.", _label.text];
        }
        
        if (_enteredText.length > _label.text.length) {
            _label.text = [NSString stringWithFormat:@"%@0", _label.text];
        }
    }
    
    //make text is formatted as dollar ammount on blur
    if (!_isFocused && _showDollarSign) {

        if([_label.text rangeOfString:@"."].location == NSNotFound) {
            _label.text = [NSString stringWithFormat:@"%@.00", _label.text];
            self.enteredText = [NSString stringWithFormat:@"%@.00", _enteredText];
        
        //if blank set to 0.00
        }else if([_label.text isEqualToString:@""] || [_label.text isEqualToString:@"0"]) {
            _label.text = @"0.00";
            self.enteredText = @".00";
            
        //if 0. set to 0.00
        }else if ([_label.text isEqualToString:@"0."]) {
            _label.text = @"0.00";
            self.enteredText = [NSString stringWithFormat:@"%@00", _enteredText];
            
        //if ends with . add 00
        }else if(_label.text.length > 0 && [[_label.text substringWithRange:NSMakeRange(_label.text.length - 1,1)] isEqualToString:@"."] ) {
            _label.text = [NSString stringWithFormat:@"%@00", _label.text];
            self.enteredText = [NSString stringWithFormat:@"%@00", _enteredText];
        
        //if ends with .0 add 0
        }else if(_label.text.length > 1 && [[_label.text substringWithRange:NSMakeRange(_label.text.length - 2,2)] isEqualToString:@".0"] ) {
            _label.text = [NSString stringWithFormat:@"%@0", _label.text];
            self.enteredText = [NSString stringWithFormat:@"%@0", _enteredText];
        }else{
            NSRange decimalRange = [_label.text rangeOfString:@"."];
            NSUInteger decimalLocation = (decimalRange.location == NSNotFound) ? 0 : decimalRange.location;
            
            if (_label.text.length - decimalLocation == 2) {
                _label.text = [NSString stringWithFormat:@"%@0", _label.text];
                self.enteredText = [NSString stringWithFormat:@"%@0", _enteredText];
            }
        }
        
    }else if (!_isFocused && !_minCharacters) {
        
        if([_label.text isEqualToString:@""]) {
            _label.text = @"0";
            self.enteredText = @"0";
        }else if([_label.text isEqualToString:@"0."] || [_label.text isEqualToString:@"0.0"]|| [_label.text isEqualToString:@"0.00"]) {
            _label.text = @"0";
            self.enteredText = @"0";
        }else if(_label.text.length > 0 && [[_label.text substringWithRange:NSMakeRange(_label.text.length - 1,1)] isEqualToString:@"."] ) {
            self.enteredText = [_label.text substringToIndex:_label.text.length - 1];
            _label.text = [_label.text substringToIndex:_label.text.length - 1];
            
        }
    }
    
    //set position cursor
    CGFloat actualFontSize;
    CGSize charactersSize = [self.label.text sizeWithFont:self.label.font minFontSize:10 actualFontSize:&actualFontSize forWidth:self.label.frame.size.width lineBreakMode:self.label.lineBreakMode];
    CGFloat x = self.frame.size.width / 2 + charactersSize.width / 2;
    
    if (charactersSize.height == 0) {
        charactersSize = CGSizeMake(charactersSize.width, self.frame.size.height);
    }
    
    //center label vertically
    _label.frame = CGRectMake(_label.frame.origin.x, (self.frame.size.height - charactersSize.height) / 2, _label.frame.size.width, charactersSize.height);

    //adjusts cursor position in the case where it is not suppose to be at end of text
    if (adjustCursorPositionForMinCharacters) {
        
        UIFont *font = [UIFont fontWithName:self.label.font.fontName size:actualFontSize];
        charactersSize = [@"00" sizeWithFont:font];
        x -= charactersSize.width + 7;
    }
    
    _cursor.frame = CGRectMake(x, _cursor.frame.origin.y, _cursor.frame.size.width, _cursor.frame.size.height);
    

    //position dollar sign
    if (_showDollarSign) {
        UIFont *dollarSignFont = [UIFont fontWithName:_dollarSignLabel.font.fontName size:actualFontSize/2];
        CGSize dollarCharactersSize = [@"$" sizeWithFont:dollarSignFont];
        CGFloat dollarSignX = (_label.frame.size.width - charactersSize.width) / 2 - dollarCharactersSize.width;
        _dollarSignLabel.font = dollarSignFont;
        _dollarSignLabel.frame = CGRectMake(dollarSignX, -3, _dollarSignLabel.frame.size.width, _dollarSignLabel.frame.size.height);
    }
}

@end
