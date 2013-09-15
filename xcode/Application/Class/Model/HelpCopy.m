//
//  HelpCopy.m
//  Blocpad
//
//  Created by Hugh Lang on 4/9/13.
//
//

#import "HelpCopy.h"

@implementation HelpCopy

@synthesize key, title, description;

- (id)initWithKey:(NSString *)_key title:(NSString *)_title desc:(NSString *)_desc {
    if ((self = [super init])) {
        key = _key;
        title = _title;
        description = _desc;
    }
    return self;
}



@end
