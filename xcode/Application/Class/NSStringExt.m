//
//  NSStringExt.m
//  BookApp
//
//  Created by Hugh Lang on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSStringExt.h"

@implementation NSString (util)

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

@end
