#import "NSDate+Extensions.h"

#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)

@implementation NSDate (Extensions)

+ (NSDate *)dateWithToday {
    return [[NSDate date] dateAtMidnight];
}

- (NSDate *)dateAtMidnight {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                           fromDate:[NSDate date]];
	NSDate *midnight = [gregorian dateFromComponents:comps];
	
	
	return midnight;
}

- (NSString *)formatTime {
    static NSDateFormatter *formatter = nil;
	
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = NSLocalizedString(@"h:mm a", @"Date format: 1:05 pm");
        formatter.locale = [NSLocale currentLocale];
    }
	
    return [formatter stringFromDate:self];
}

- (NSString *)formatDate {
    static NSDateFormatter *formatter = nil;
	
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =
        NSLocalizedString(@"MM/dd/yyyy", @"Date format: 07/27/2009");
        formatter.locale = [NSLocale currentLocale];
    }
	
    return [formatter stringFromDate:self];
}

- (NSString *)formatShortDate {
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    
    if (diff < TT_5_DAYS) {
        static NSDateFormatter *formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"EEEE", @"Date format: Monday");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter *formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"M/d/yy", @"Date format: 7/27/09");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
    }
}

- (NSString *)formatShortTime {
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    
    if (diff < TT_DAY) {
        return [self formatTime];
    } else if (diff < TT_5_DAYS) {
        static NSDateFormatter *formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"EEEE", @"Date format: Monday");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter* formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"M/d/yy", @"Date format: 7/27/09");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
    }
}

- (NSString *)formatDateTime {
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
	
    if (diff < TT_DAY) {
        return [self formatTime];
        
    } else if (diff < TT_5_DAYS) {
        static NSDateFormatter *formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"EEE h:mm a", @"Date format: Mon 1:05 pm");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
    } else {
        static NSDateFormatter *formatter = nil;
		
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = NSLocalizedString(@"MMM d h:mm a", @"Date format: Jul 27 1:05 pm");
            formatter.locale = [NSLocale currentLocale];
        }
		
        return [formatter stringFromDate:self];
    }
}

- (NSString *)formatRelativeTime {
    NSTimeInterval elapsed = [self timeIntervalSinceNow];
	
    if (elapsed > 0) {
        if (elapsed <= 1) {
            return NSLocalizedString(@"in just a moment", @"");
        }
        else if (elapsed < TT_MINUTE) {
            int seconds = (int)(elapsed);
			
            return [NSString stringWithFormat:NSLocalizedString(@"in %d seconds", @""), seconds];
        }
        else if (elapsed < 2*TT_MINUTE) {
            return NSLocalizedString(@"in about a minute", @"");
        }
        else if (elapsed < TT_HOUR) {
            int mins = (int)(elapsed/TT_MINUTE);
			
            return [NSString stringWithFormat:NSLocalizedString(@"in %d minutes", @""), mins];
        }
        else if (elapsed < TT_HOUR*1.5) {
            return NSLocalizedString(@"in about an hour", @"");
        }
        else if (elapsed < TT_DAY) {
            int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
			
            return [NSString stringWithFormat:NSLocalizedString(@"in %d hours", @""), hours];
        }
        else {
            return [self formatDateTime];
        }
    }
    else {
        elapsed = -elapsed;
        
        if (elapsed <= 1) {
            return NSLocalizedString(@"just a moment ago", @"");
        } else if (elapsed < TT_MINUTE) {
            int seconds = (int)(elapsed);
			
            return [NSString stringWithFormat:NSLocalizedString(@"%d seconds ago", @""), seconds];
        } else if (elapsed < 2 * TT_MINUTE) {
            return NSLocalizedString(@"about a minute ago", @"");
        } else if (elapsed < TT_HOUR) {
            int mins = (int)(elapsed/TT_MINUTE);
			
            return [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", @""), mins];
        } else if (elapsed < TT_HOUR * 1.5) {
            return NSLocalizedString(@"about an hour ago", @"");
        } else if (elapsed < TT_DAY) {
            int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
			
            return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", @""), hours];
        } else {
            return [self formatDateTime];
        }
    }
}

- (NSString *)formatShortRelativeTime {
    NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
    
    if (elapsed < TT_MINUTE) {
        return NSLocalizedString(@"<1m", @"Date format: less than one minute ago");
        
    } else if (elapsed < TT_HOUR) {
        int mins = (int)(elapsed / TT_MINUTE);
		
        return [NSString stringWithFormat:NSLocalizedString(@"%dm", @"Date format: 50m"), mins];
    } else if (elapsed < TT_DAY) {
        int hours = (int)((elapsed + TT_HOUR / 2) / TT_HOUR);
		
        return [NSString stringWithFormat:NSLocalizedString(@"%dh", @"Date format: 3h"), hours];
    } else if (elapsed < TT_WEEK) {
        int day = (int)((elapsed + TT_DAY / 2) / TT_DAY);
		
        return [NSString stringWithFormat:NSLocalizedString(@"%dd", @"Date format: 3d"), day];
    } else {
        return [self formatShortTime];
    }
}

- (NSString *)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
    static NSDateFormatter *formatter = nil;
	NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *day = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                   fromDate:self];
	
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = NSLocalizedString(@"MMMM d", @"Date format: July 27");
        formatter.locale = [NSLocale currentLocale];
    }
    
    if (day.day == today.day && day.month == today.month && day.year == today.year)
        return NSLocalizedString(@"Today", @"");
    else if (day.day == yesterday.day && day.month == yesterday.month && day.year == yesterday.year)
        return NSLocalizedString(@"Yesterday", @"");
    else
        return [formatter stringFromDate:self];
}

- (NSString *)formatMonth {
    static NSDateFormatter *formatter = nil;
	
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = NSLocalizedString(@"MMMM", @"Date format: July");
        formatter.locale = [NSLocale currentLocale];
    }
	
    return [formatter stringFromDate:self];
}

- (NSString *)formatYear {
    static NSDateFormatter *formatter = nil;
	
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = NSLocalizedString(@"yyyy", @"Date format: 2009");
        formatter.locale = [NSLocale currentLocale];
    }
	
    return [formatter stringFromDate:self];
}

@end
