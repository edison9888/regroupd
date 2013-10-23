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
    sql = @"select * from user where user_key is not null limit 1";
    
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
    
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    /*
     CREATE TABLE IF NOT EXISTS user (
     user_key TEXT,
     username TEXT,
     password TEXT,
     system_id TEXT,
     facebook_id TEXT,
     first_name TEXT,
     last_name TEXT,
     phone TEXT,
     email TEXT,
     imagefile TEXT,
     type INT DEFAULT 1,
     status INT DEFAULT 0,
     created TEXT,
     updated TEXT
     );
     
     */
    sql = @"INSERT into user (user_key, username, password, first_name, last_name, phone, email, imagefile, type, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               user.user_key,
               user.username,
               user.password,
               user.first_name,
               user.last_name,
               user.phone,
               user.email,
               user.imagefile,
               [NSNumber numberWithInt:1],
               [NSNumber numberWithInt:0],
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

#pragma mark - User API
// API functions
- (UserVO *) apiLoadUser:(NSString *)objectId {
    
    return nil;
}
- (NSString *) apiSaveUser:(UserVO *) user {

    PFUser *u = [PFUser currentUser];
    u.username = user.username;
    u.password = user.password;
    if (user.email != nil) {
        u.email = user.email;
    }
    [u setObject:user.phone forKey:@"phone"];
    BOOL success = [u signUp];
    if (success) {
        return u.objectId;
        
    } else {
        NSLog(@"apiSaveUser failed");
        return nil;
    }
    
}
- (NSMutableArray *) apiListUsers:(NSString *)userId {
    return nil;
}
- (void) apiDeleteUser:(UserVO *)user {
}


@end
