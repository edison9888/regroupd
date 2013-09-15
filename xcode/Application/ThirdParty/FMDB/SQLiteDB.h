//
//  SQLiteDB.h
//  WetCement
//
//  Created by Hugh Lang on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface SQLiteDB : NSObject<NSFileManagerDelegate> {

}

@property (nonatomic, retain) NSString *dbpath;

+(FMDatabase *) sharedConnection;
+(FMDatabaseQueue *) sharedQueue;

+(FMDatabase *) testConnection;

+(BOOL) installDatabase;

+(NSString *) getDBfilepath;


@end
