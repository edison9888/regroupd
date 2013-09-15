//
//  NSString+NumberFormat.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+NumberFormat.h"

@implementation NSString (NumberFormat)

static NSString *pctFormat = @"%0.1f%%";
static NSString *amtFormat = @"%f";

- (NSString*)formatWithCommas {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *result =  [formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue]]];
    return result;
}

+ (NSString*)formatIntWithCommas:(int)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 0;
    NSString *result =  [formatter stringFromNumber:[NSNumber numberWithInt:value]];
    return result;
}

+ (NSString*)formatDoubleWithCommas:(double)value decimals:(int)decimals {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = decimals;
    NSString *result =  [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    return result;
}

+ (NSString*)formatDoubleAsCurrency:(double)value decimals:(int)decimals {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.maximumFractionDigits = decimals;
    NSString *result =  [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    return result;
}

+ (NSString*)formatDoubleWithMaxDecimals:(double)value minDecimals:(int)minDecimals maxDecimals:(int)maxDecimals {
    return [self formatDoubleWithMaxDecimals:value minDecimals:minDecimals maxDecimals:maxDecimals AndPrefix:nil AndSuffix:nil];
}

+ (NSString*)formatDoubleWithMaxDecimals:(double)value minDecimals:(int)minDecimals maxDecimals:(int)maxDecimals AndPrefix:(NSString *)prefix AndSuffix:(NSString *)suffix {
    NSUInteger places = [self numberOfDecimalPlaces:value];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    int decimals = MIN(maxDecimals, places);
    
    formatter.maximumFractionDigits = decimals;
    formatter.minimumFractionDigits = minDecimals;
    NSString *result;
    result =  [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    if (prefix != nil) {
        result = [prefix stringByAppendingString:result];
    }
    if (suffix != nil) {
        result = [result stringByAppendingString:suffix];
    }
    
    return result;
    
}
+ (NSString*)formatDoubleAsPercent1:(double)value {
    NSString *result =  [NSString stringWithFormat:pctFormat, value];
    return result;    
}

+ (NSUInteger) numberOfDecimalPlaces:(double)value {
    
    NSString *strValue = [NSString stringWithFormat:@"%f", value];
    
    // If nil, return -1
    if (!strValue) return 0;
    
    // If non-numeric, return -1
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setMaximumFractionDigits:128];
    NSNumber *numValue = [f numberFromString:strValue];
    if (!numValue) return -1;
    
    // Count digits after decimal point in original input
    NSRange range = [strValue rangeOfString:@"."];
    if (NSNotFound == range.location) return 0;
    
    return [strValue substringFromIndex:range.location+1].length;
}

@end
