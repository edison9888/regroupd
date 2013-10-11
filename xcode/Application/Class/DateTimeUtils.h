//
//  DataUtils.h
//  WetCement
//
//  Created by Hugh Lang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface DateTimeUtils : NSObject

+ (NSString *) readKeyValue:(NSString *)key data:(NSDictionary *)dict;

+ (int) readSelectedIndex:(NSString *)key data:(NSMutableDictionary *)dict;

+ (NSDateFormatter *) sharedDbDateTimeFormatter;
+ (NSDateFormatter *) sharedDbDateFormatter;
+ (NSDateFormatter *) getShortDateFormatter;

+ (NSDate *) dateFromDBDateString:(NSString *)dbDate;
+ (NSDate *) dateFromDBDateStringNoOffset:(NSString *)dbDate;
+ (NSString *) simpleTimeLabelFromDate:(NSDate *)date;
+ (NSString *) dbDateTimeStampFromDate:(NSDate *)date;
+ (NSString *) dbDateStampFromDate:(NSDate *)date;

+ (NSString *) dbTimeStampFromDateNoOffset:(NSDate *)date;

+ (NSString *) printTimePartFromDate:(NSDate *)date;
+ (NSString *) printDatePartFromDate:(NSDate *)date;

@end
