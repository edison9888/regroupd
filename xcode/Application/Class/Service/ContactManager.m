//
//  GroupManager.m
//  Regroupd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import "ContactManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"

@implementation ContactManager


#pragma mark - Contact DAO

- (ContactVO *) loadContact:(int)_contactId{
    NSString *sql = nil;
    sql = @"select * from contact where contact_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_contactId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    ContactVO *result;
    
    if (dict != nil) {
        result = [ContactVO readFromDictionary:dict];
    }
    return result;
}

- (int) saveContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    /*
     CREATE TABLE IF NOT EXISTS contact (
     contact_id INTEGER PRIMARY KEY,
     user_key TEXT,
     record_id BIGINT,
     system_id TEXT,
     facebook_id TEXT,
     first_name TEXT,
     last_name TEXT,
     phone TEXT,
     email TEXT,
     imagefile TEXT,
     type int DEFAULT 1,
     status INT DEFAULT 0,
     created TEXT,
     updated TEXT
     );

     */
    sql = @"INSERT into contact (user_key, system_id, first_name, last_name, phone, email, imagefile, type, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
   
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [DataModel shared].user.user_key,
               contact.system_id,
               contact.first_name,
               contact.last_name,
               contact.phone,
               contact.email,
               contact.imagefile,
               [NSNumber numberWithInt:contact.type],
               [NSNumber numberWithInt:contact.status],
               dt,
               dt
               ];
    
    if (!success) {
        NSLog(@"####### SQL Insert failed #######");
    } else {
        NSLog(@"====== SQL INSERT SUCCESS ======");
        
        sql = @"SELECT last_insert_rowid()";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        if ([rs next]) {
            int lastId = [rs intForColumnIndex:0];
            NSLog(@"lastId = %i", lastId);
            return lastId;
        }
    }
    return -1;
}
- (void) deleteContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    
    sql = @"delete from contact where contact_id=?";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               contact.contact_id
               ];
    
    if (!success) {
        NSLog(@"####### SQL Delete failed #######");
    } else {
        NSLog(@"====== SQL DELETE SUCCESS ======");
    }
    
}
- (void) updateContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    sql = @"UPDATE contact set system_id=?, first_name=?, last_name=?, phone=?, type=?, status=?, updated=? where contact_id=?";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               contact.system_id,
               contact.first_name,
               contact.last_name,
               contact.phone,
               contact.type,
               contact.status,
               dt,
               [NSNumber numberWithInt:contact.contact_id]
               ];
    
    if (!success) {
        NSLog(@"####### SQL Update failed #######");
    } else {
        NSLog(@"====== SQL UPDATE SUCCESS ======");
    }
    
}

- (int) fetchLastContactID{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"SELECT MAX(contact_id) AS max_id FROM contact";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    int maxId = 0;
    
    if ([rs next]) {
        maxId = [rs intForColumnIndex:0];
    }
    
    return maxId;
}

#pragma mark - Group DAO
- (int) fetchLastGroupID{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"SELECT MAX(group_id) AS max_id FROM db_group";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    int maxId = 0;
    
    if ([rs next]) {
        maxId = [rs intForColumnIndex:0];
    }
    
    return maxId;
}
- (GroupVO *) loadGroup:(int)_groupId {
    return [self loadGroup:_groupId fetchAll:NO];
}
- (GroupVO *) loadGroup:(int)_groupId fetchAll:(BOOL)all{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"select * from db_group where group_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_groupId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        GroupVO *result = [GroupVO readFromDictionary:dict];
        
        if (all) {
            NSMutableArray *contacts = [[NSMutableArray alloc] init];
            
            //            sql = @"select * from group_contact where group_id=? order by Contact_id";
            //            rs = [[SQLiteDB sharedConnection] executeQuery:sql,
            //                  [NSNumber numberWithInt:_GroupId]];
            //            ContactVO *Contact;
            //
            //            while ([rs next]) {
            //                Contact = [ContactVO readFromDictionary:[rs resultDictionary]];
            //                [Contacts addObject:Contact];
            //            }
            //            result.Contacts = Contacts;
        }
        return result;
    } else {
        return nil;
    }
    
}


- (int) saveGroup:(GroupVO *) group {
    
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        sql = @"INSERT into db_group (system_id, name, type, status, created, updated) values (?, ?, ?, ?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   group.system_id,
                   group.name,
                   group.type,
                   group.status,
                   dt,
                   dt
                   ];
        
        if (!success) {
            NSLog(@"####### SQL Insert failed #######");
        } else {
            NSLog(@"====== SQL INSERT SUCCESS ======");
            
            sql = @"SELECT last_insert_rowid()";
            
            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
            
            if ([rs next]) {
                int lastId = [rs intForColumnIndex:0];
                NSLog(@"lastId = %i", lastId);
                return lastId;
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION %@", exception);
    }
    return -1;
    
}

- (void) deleteGroup:(GroupVO *) group {
    
    NSString *sql;
    BOOL success;
    
    sql = @"delete from db_group where group_id=?";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               group.group_id
               ];
    
    if (!success) {
        NSLog(@"####### SQL Delete failed #######");
    } else {
        NSLog(@"====== SQL DELETE SUCCESS ======");
    }
    
}
- (void) updateGroup:(GroupVO *) group{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    sql = @"UPDATE db_group set system_id=?, name=?, type=?, status=?, updated=? where group_id=?";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               group.system_id,
               group.name,
               group.type,
               group.status,
               dt,
               [NSNumber numberWithInt:group.group_id]
               ];
    
    if (!success) {
        NSLog(@"####### SQL Update failed #######");
    } else {
        NSLog(@"====== SQL UPDATE SUCCESS ======");
    }
    
}
- (NSMutableArray *) listGroups:(int)typeFilter {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select * from db_group order by updated desc";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    GroupVO *row;
    
    while ([rs next]) {
        row = [GroupVO readFromDictionary:[rs resultDictionary]];
        [results addObject:row];
    }
    return results;
}



#pragma mark - group_contact DAO
- (NSMutableArray *) listGroupContacts:(int)groupId {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select c.* from contact as c join group_contact as gc on c.contact_id=gc.contact_id where gc.group_id=? order by c.first_name?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:groupId]];
    ContactVO *row;
    
    while ([rs next]) {
        row = [ContactVO readFromDictionary:[rs resultDictionary]];
        [results addObject:row];
    }
    
    return results;
}

- (BOOL) checkGroupContact:(int)groupId contactId:(int)contactId {
    NSString *sql = @"select * from group_contact where group_id=? and contact_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:groupId],
                       [NSNumber numberWithInt:contactId]
                       ];
    if ([rs next]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) addGroupContact:(int)groupId contactId:(int)contactId {
    
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    sql = @"INSERT into group_contact (group_id, contact_id) values (?, ?);";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [NSNumber numberWithInt:groupId],
               [NSNumber numberWithInt:contactId]
               ];
    
    if (!success) {
        NSLog(@"####### SQL Insert failed #######");
    } else {
        NSLog(@"====== SQL INSERT SUCCESS ======");
    }
    
}

- (void) removeGroupContact:(int)groupId contactId:(int)contactId {
    NSString *sql;
    BOOL success;

    sql = @"delete from group_contact where group_id=? and contact_id=?";

    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [NSNumber numberWithInt:groupId],
               [NSNumber numberWithInt:contactId]
               ];

}

#pragma mark - parse.com - Contact API

- (NSString *) apiSaveContact:(ContactVO *) contact {
    
    PFObject *data = [PFObject objectWithClassName:kContactDB];
    
    data[@"first_name"] = contact.first_name;
    data[@"last_name"] = contact.last_name;
    data[@"phone"] = contact.phone;
    
    if (contact.email != nil) {
        data[@"email"] = contact.email;
    }
    
    [data save];
    
    NSLog(@"Saved chat with objectId %@", data.objectId);
    return data.objectId;
    
}

@end
