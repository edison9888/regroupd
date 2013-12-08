//
//  DataUtils.h
//  WetCement
//
//  Created by Hugh Lang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

#define kSimpleTimeFormat  @"h:mm a"
#define kSimpleDateFormat  @"MMM d, yyyy"

#define kShortDateOnlyFormat @"M/d/yy"
#define kDecimalDateFormat @"MM.dd.yy"

@interface DateTimeUtils : NSObject

+ (NSDateFormatter *) sharedDbDateTimeFormatter;
+ (NSDateFormatter *) sharedDbDateFormatter;
+ (NSDateFormatter *) getShortDateFormatter;

// Convert string to date
+ (NSDate *) dateFromDBDateString:(NSString *)dbDate;
+ (NSDate *) dateFromDBDateStringNoOffset:(NSString *)dbDate;
+ (NSDate *) readDateFromFriendlyDateTime:(NSString *)dbDate;

// Convert date to String
+ (NSString *) formatDecimalDate:(NSDate *)date;
+ (NSString *) dbDateTimeStampFromDate:(NSDate *)date;
+ (NSString *) dbDateStampFromDate:(NSDate *)date;
+ (NSString *) dbTimeStampFromDateNoOffset:(NSDate *)date;

+ (NSString *) printTimePartFromDate:(NSDate *)date;
+ (NSString *) printDatePartFromDate:(NSDate *)date;

@end
