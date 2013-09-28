#import "NSString+Extensions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSString_Extensions)

- (int) indexOf:(NSString *)text {
    
    @try {
        NSRange range = [self rangeOfString:text];
        if ( range.location != NSNotFound ) {
            return range.location;
        } else {
            return -1;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        return -1;
    }
    
}
- (BOOL)isValidEmailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:self];
}

- (NSString *)MD5Digest {
    unsigned char hashResult[16];
    
    CC_MD5([self UTF8String], [self lengthOfBytesUsingEncoding:NSASCIIStringEncoding], hashResult);
    return [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            hashResult[0], hashResult[1],
            hashResult[2], hashResult[3],
            hashResult[4], hashResult[5],
            hashResult[6], hashResult[7],
            hashResult[8], hashResult[9],
            hashResult[10], hashResult[11],
            hashResult[12], hashResult[13],
            hashResult[14], hashResult[15]
            ] lowercaseString];
}

- (NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];

    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    return s; 
}

@end
