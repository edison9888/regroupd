//
//  DataUtils.m
//  WetCement
//
//  Created by Hugh Lang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateTimeUtils.h"

@implementation DateTimeUtils


static NSDateFormatter *dbDateTimeFormatter;
static NSDateFormatter *dbDateFormatter;
static NSDateFormatter *shortDateFormatter;

//static NSDateFormatter *simpleTimeFormatter;

+ (NSDateFormatter *) getShortDateFormatter {
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc]init];
        [shortDateFormatter setDateFormat:kShortDateOnlyFormat];
    }
    return shortDateFormatter;
}

+ (NSDateFormatter *) sharedDbDateTimeFormatter {
    if (dbDateTimeFormatter==nil) {
        dbDateTimeFormatter = [[NSDateFormatter alloc] init];
        [dbDateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];   
        [dbDateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    
    return dbDateTimeFormatter;
}

+ (NSDateFormatter *) sharedDbDateFormatter {
    if (dbDateFormatter==nil) {
        dbDateFormatter = [[NSDateFormatter alloc] init];
        [dbDateFormatter setDateFormat:@"yyyy-MM-dd"];   
        [dbDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    return dbDateFormatter;
}

+ (NSString *) formatDecimalDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDecimalDateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - OLD SHIT

+ (NSDate *) dateFromDBDateString:(NSString *)dbDate {
    
    return [self.sharedDbDateTimeFormatter dateFromString:dbDate];
}

+ (NSString *) simpleTimeLabelFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kSimpleTimeFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    return [dateFormatter stringFromDate:date];
}

+ (NSString *) dbDateTimeStampFromDate:(NSDate *)date{        
    return [self.sharedDbDateTimeFormatter stringFromDate:date];
}

+ (NSDate *) dateFromDBDateStringNoOffset:(NSString *)dbDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];   
    return [dateFormatter dateFromString:dbDate];
}

+ (NSString *) dbDateStampFromDate:(NSDate *)date {
    
    return [self.sharedDbDateFormatter stringFromDate:date];
}
+ (NSString *) dbTimeStampFromDateNoOffset:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];   
    return [dateFormatter stringFromDate:date];
}

//2013-10-11 3:30 PM
+ (NSDate *) readDateFromFriendlyDateTime:(NSString *)dbDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM, d yyyy h:mm a"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    return [dateFormatter dateFromString:dbDate];
}


+ (NSString *) printTimePartFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kSimpleTimeFormat];
    
    return [dateFormatter stringFromDate:date];
    
}
+ (NSString *) printDatePartFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM, d yyyy"];
    
    return [dateFormatter stringFromDate:date];
    
}


//- (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key {
//	return [[plaintext dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
//    
//}
//
//- (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key {
//	return [[[NSString alloc] initWithData:[ciphertext AES256DecryptWithKey:key]
//								  encoding:NSUTF8StringEncoding] autorelease];
//}


@end
