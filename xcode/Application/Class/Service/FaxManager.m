//
//  FaxManager.m
//  eAttending
//
//  Created by Hugh Lang on 8/11/13.
//
//

#import "FaxManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"

@implementation FaxManager


- (FaxAccountVO *) loadCurrentAccount:(int) userId {
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from fax_account where user_id=? and status=1 order by account_id limit 1";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:userId]
                       ];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        FaxAccountVO *account = [FaxAccountVO readFromDictionary:dict];
        return account;
    } else {
        return nil;
    }
    
}

- (int) createFaxAccount:(FaxAccountVO *)account {
    NSLog(@"%s", __FUNCTION__);
    
    __block int lastId;
    
    [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql;
        BOOL success;
        NSDate *now = [NSDate date];
        NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
        //        NSLog(@"dt %@", dt);
        
        sql = @"INSERT into fax_account (user_id, qty_purchased, qty_used, qty_left, status, purchase_id, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?);";
        success = [db executeUpdate:sql,
                   [NSNumber numberWithInt:account.user_id],
                   account.qty_purchased,
                   account.qty_used,
                   account.qty_left,
                   [NSNumber numberWithInt:account.status],
                   account.purchase_id,
                   dt,
                   dt
                   ];
        
        if (!success) {
            NSLog(@"################ SQL Insert failed ################");
        } else {
            NSLog(@"================ SQL INSERT SUCCESS ================");
            
            sql = @"SELECT last_insert_rowid()";
            
            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
            
            if ([rs next]) {
                lastId = [rs intForColumnIndex:0];
                NSLog(@"lastId = %i", lastId);
            }
        }
    }];
    return lastId;
    
}
- (void) updateAccountBalance:(FaxAccountVO *)account {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"balance = %i", account.qty_left);
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    
    sql = @"UPDATE fax_account set qty_used=%i, qty_left=%i, updated='%@' where account_id=%i;";
    sql = [NSString stringWithFormat:sql, account.qty_used, account.qty_left, dt, account.account_id];
    
    NSLog(@"%@", sql);
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql];
    
    if (!success) {
        NSLog(@"############## SQL Update failed ##############");
    } else {
        NSLog(@"=============== SQL UPDATE SUCCESS ================");
    }
}

- (FaxLogVO *) selectLastLog:(int) userId {
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from fax_log where user_id=? order by log_id desc limit 1";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:userId]
                       ];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        FaxLogVO *row = [FaxLogVO readFromDictionary:dict];
        return row;
    } else {
        return nil;
    }
    
}

- (int) createFaxLog:(FaxLogVO *)faxlog {
    
    NSLog(@"%s", __FUNCTION__);
    int lastId = -1;
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    
    sql = @"INSERT into fax_log (contact_id, user_id, account_id, patient_name, efax_id, fax, message, type, status, created) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [NSNumber numberWithInt:faxlog.contact_id],
               [NSNumber numberWithInt:faxlog.user_id],
               [NSNumber numberWithInt:faxlog.account_id],
               faxlog.patient_name,
               faxlog.efax_id,
               faxlog.fax,
               faxlog.message,
               [NSNumber numberWithInt:faxlog.type],
               [NSNumber numberWithInt:faxlog.status],
               dt
               ];
    
    if (!success) {
        NSLog(@"################################### SQL Insert failed ###################################");
    } else {
        NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
        
        sql = @"SELECT last_insert_rowid()";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        if ([rs next]) {
            lastId = [rs intForColumnIndex:0];
            NSLog(@"lastId = %i", lastId);
        }
    }
    return lastId;
}


- (void) updateFaxLog:(FaxLogVO *)faxlog {
    
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql;
    BOOL success;
    //        NSLog(@"dt %@", dt);
    
    sql = @"UPDATE fax_log set efax_id='%@', status=%i where log_id=%i;";
    sql = [NSString stringWithFormat:sql, faxlog.efax_id, faxlog.status, faxlog.log_id];
    NSLog(@"%@", sql);
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql];
    
    if (!success) {
        NSLog(@"############## SQL Update failed ##############");
    } else {
        NSLog(@"=============== SQL UPDATE SUCCESS ================");
    }
}


- (ContactVO *) selectContactByID:(int) contactId {
    
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from contact  where contact_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:contactId]
                       ];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        ContactVO *row = [ContactVO readFromDictionary:dict];
        return row;
    } else {
        return nil;
    }

    
}
+ (NSString *) renderFaxQtyLabel:(int) qty {
    NSString *fmt = @"%i %@ left";
    NSString *output = nil;
    
    if (qty == 0) {
        output = [NSString stringWithFormat:fmt, qty, @"faxes"];
    } else if (qty == 1) {
        output = [NSString stringWithFormat:fmt, qty, @"fax"];
    } else {
        output = [NSString stringWithFormat:fmt, qty, @"faxes"];
    }
    return output;
    
}
@end
