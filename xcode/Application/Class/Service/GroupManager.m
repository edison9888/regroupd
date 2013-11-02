//
//  GroupManager.m
//  Regroupd
//
//  Created by Hugh Lang on 11/2/13.
//
//

#import "GroupManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"
#import <AddressBook/AddressBook.h>

@implementation GroupManager


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
        sql = @"INSERT into db_group (user_key, system_id, name) values (?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   [DataModel shared].user.user_key,
                   group.system_id,
                   group.name
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


@end
