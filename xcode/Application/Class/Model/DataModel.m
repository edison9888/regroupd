//
//  DataModel.m
//
//  Created by Hugh Lang on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

@synthesize contactId;

@synthesize user;
@synthesize myContact;
@synthesize contact;
@synthesize form;
@synthesize chat;
@synthesize group;
@synthesize formsList;

@synthesize contactCache;
@synthesize chatCache;
@synthesize phonebookCache;

@synthesize timestampText;
@synthesize needsLookup, needsRefresh, didSaveOK;
@synthesize stageHeight, stageWidth;

@synthesize navIndex;
@synthesize formType;
@synthesize action, mode;

static DataModel *instance = nil;

+ (DataModel *) shared {
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[DataModel alloc] init];
        }
        return instance;
    }
}

+ (NSDictionary *) readPFObjectAsDictionary:(PFObject *) data {
    NSArray * allKeys = [data allKeys];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in allKeys) {
        
        [dict setObject:[data objectForKey:key] forKey:key];
        
    }
    return dict;
}

@end
