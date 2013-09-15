//
//  NSString+NumberFormat.h
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NumberFormat)

- (NSString*)formatWithCommas;

+ (NSString*)formatIntWithCommas:(int)value;

+ (NSString*)formatDoubleWithCommas:(double)value decimals:(int)decimals;

+ (NSString*)formatDoubleAsCurrency:(double)value decimals:(int)decimals;

+ (NSString*)formatDoubleAsPercent1:(double)value;

+ (NSString*)formatDoubleWithMaxDecimals:(double)value minDecimals:(int)minDecimals maxDecimals:(int)maxDecimals;

+ (NSString*)formatDoubleWithMaxDecimals:(double)value minDecimals:(int)minDecimals maxDecimals:(int)maxDecimals AndPrefix:(NSString *)prefix AndSuffix:(NSString *)suffix;

+ (NSUInteger) numberOfDecimalPlaces:(double)value;

@end
