//
//  UserManager.m
//  eAttending
//
//  Created by Hugh Lang on 7/21/13.
//
//

#import "UserManager.h"
#import "DateTimeUtils.h"

@implementation UserManager

@synthesize user = _user;

- (UserVO *) lookupDefaultUser {
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from user limit 1";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        UserVO *user = [UserVO readFromDictionary:dict];
        return user;
        
    } else {
        return nil;
    }
}
- (void) createUser:(UserVO *) user {
    NSLog(@"%s", __FUNCTION__);
    
//    [user dumpInfo];
    
    [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql;
        BOOL success;
        NSDate *now = [NSDate date];
        NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
        NSLog(@"dt %@", dt);
        
        sql = @"INSERT into user (firstname, middlename, lastname, company, title, phone, fax, address, city, state, zip, password, hint, email, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        success = [db executeUpdate:sql,
                   user.firstname,
                   user.middlename,
                   user.lastname,
                   user.company,
                   user.title,
                   user.phone,
                   user.fax,
                   user.address,
                   user.city,
                   user.state,
                   user.zip,
                   user.password,
                   user.hint,
                   user.email,
                   [NSNumber numberWithInt:1],
                   dt,
                   dt
                   ];
        
        if (!success) {
            NSLog(@"################################### SQL Insert failed ###################################");
        } else {
            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
            
            sql = @"SELECT last_insert_rowid()";
            
            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];

            if ([rs next]) {
                int lastId = [rs intForColumnIndex:0];
                NSLog(@"lastId = %i", lastId);
            }
        }
    }];
}

/*
 Create a temporary filename and save image data to file in Documents or temp dir
 */
- (NSString *)saveSignature:(UIImage *)saveImage withName:(NSString *)filename
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImagePNGRepresentation(saveImage);
    
    [imageData writeToFile:savePath atomically:NO];
    
    return savePath;
}

- (UIImage *)loadSignature:(NSString *)filename {
    
    @try {
        NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
        
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        return image;
    }
    @catch (NSException *exception) {
        return nil;
    }    
}
@end
