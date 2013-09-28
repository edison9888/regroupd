#import <Foundation/Foundation.h>

@interface NSDate (Extensions)
+ (NSDate *)dateWithToday;
- (NSDate *)dateAtMidnight;
- (NSString *)formatTime;
- (NSString *)formatDate;
- (NSString *)formatShortDate;
- (NSString *)formatShortTime;
- (NSString *)formatDateTime;
- (NSString *)formatRelativeTime;
- (NSString *)formatShortRelativeTime;
- (NSString *)formatDay:(NSDateComponents *)today yesterday:(NSDateComponents *)yesterday;
- (NSString *)formatMonth;
- (NSString *)formatYear;
@end
