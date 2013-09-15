//
//  SQLiteDB.m
//  WetCement
//
//  Created by Hugh Lang on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SQLiteDB.h"

@implementation SQLiteDB

@synthesize dbpath;
//@synthesize _database;
static FMDatabase *dbInstance = nil;
static NSString *dbfilename = @"regroupd.sqlite";

+ (FMDatabase *) sharedConnection {
    @synchronized(self)
    {
        
        if (dbInstance == nil) {
            NSString *resourcePath = [self getDBfilepath];

            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
            
            if ( exists ) { 
                NSLog(@"Found database at resourcePath=%@", resourcePath);
                
            } else {
                NSLog(@"Database does not exist at %@", resourcePath);
                return nil; 
            }

            
            dbInstance = [FMDatabase databaseWithPath:resourcePath];
            
            if (![dbInstance open]) {
                NSLog(@"Database not open");
            }

        }
        return dbInstance;
    }
}
+ (FMDatabaseQueue *) sharedQueue {
    NSString *resourcePath = [self getDBfilepath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:resourcePath];
    return queue;
}

// This is only used for unit tests
+ (FMDatabase *) testConnection {
    @synchronized(self)
    {
        
        if (dbInstance == nil) {
                        
            NSString *dataDirectory = @"/Sandbox/APPMOB/appmob-e-attending/xcode/NView/Resources/Data/";
            NSString *resourcePath = [dataDirectory stringByAppendingPathComponent:dbfilename];
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
            
            if ( exists ) {
                NSLog(@"Found database at resourcePath=%@", resourcePath);
                
            } else {
                NSLog(@"Database does not exist at %@", resourcePath);
                return nil;
            }
            
            
            dbInstance = [FMDatabase databaseWithPath:resourcePath];
            
            if (![dbInstance open]) {
                NSLog(@"Database not open");
            }
            
        }
        return dbInstance;
    }
}

+ (NSString *) getDBfilepath {
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:dbfilename];
    return filepath;

}
+(BOOL) installDatabase {
    
    // Get the path to the main bundle resource directory.
    
    NSString *pathsToResources = [[NSBundle mainBundle] resourcePath];
    
    NSString *yourOriginalDatabasePath = [pathsToResources stringByAppendingPathComponent:dbfilename];
    
    // Create the path to the database in the Documents directory.
    
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    
    NSString *yourNewDatabasePath = [documentsDirectory stringByAppendingPathComponent:dbfilename];
    
    NSLog(@"Ready to copy database from %@", yourOriginalDatabasePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager setDelegate:self];
    BOOL success;
    NSError *error;
    
    success = [fileManager fileExistsAtPath:yourNewDatabasePath];
    if ( success ) { 
        NSLog(@"Database already exists at %@", yourNewDatabasePath);
//        return YES; 
    }
    
    success = [fileManager copyItemAtPath:yourOriginalDatabasePath toPath:yourNewDatabasePath error:&error];
    
    if (success) {
        NSLog(@"Installed database at %@", yourNewDatabasePath);
        return YES;
    } else {
        NSLog(@"Failed to install database at %@", yourNewDatabasePath);
        return NO;
    }
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error
  copyingItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath{
    NSLog(@"%s", __FUNCTION__);
    
    if ([error code] == 516) {
        //error code for: The operation couldn’t be completed. File exists
        NSLog(@"Overwrite database at %@", dstPath);
        return YES;
    } else {
        return NO;        
    }
}

@end
