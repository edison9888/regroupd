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
@synthesize contact;
@synthesize form;
@synthesize chat;
@synthesize group;

@synthesize contactData;
@synthesize timestampText;
@synthesize needsLookup, needsRefresh;
@synthesize stageHeight, stageWidth;

@synthesize navIndex;
@synthesize formType;
@synthesize action;

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


@end
