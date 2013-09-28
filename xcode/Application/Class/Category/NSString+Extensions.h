#import <Foundation/Foundation.h>

@interface NSString (NSString_Extensions)
- (int) indexOf:(NSString *)text;
- (BOOL)isValidEmailAddress;
- (NSString *)MD5Digest;
- (NSString *)stringByStrippingHTML;
@end
