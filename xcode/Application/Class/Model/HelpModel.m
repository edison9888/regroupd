//
//  HelpModel.m
//  Blocpad
//
//  Created by Hugh Lang on 4/9/13.
//
//

#import "HelpModel.h"
#import "HelpCopy.h"

@implementation HelpModel

@synthesize helpDB;

- (id)init{
    if ((self = [super init])) {
        [self load];
    }
    return self;
}

- (void) load {
    helpDB = [[NSMutableDictionary alloc] init];
    
}


@end
