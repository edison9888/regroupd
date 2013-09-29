//
//  FormManager.m
//  Regroupd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import "FormManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"


@implementation FormManager

- (FormVO *) loadForm:(int)_formId {
    return [self loadForm:_formId fetchAll:NO];
}
- (FormVO *) loadForm:(int)_formId fetchAll:(BOOL)all{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"select * from form where form_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_formId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        FormVO *result = [FormVO readFromDictionary:dict];
        
        if (all) {
            NSMutableArray *options = [[NSMutableArray alloc] init];
            
            sql = @"select * from form_option where form_id=? order by option_id";
            rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                  [NSNumber numberWithInt:_formId]];
            FormOptionVO *option;
            
            while ([rs next]) {
                option = [FormOptionVO readFromDictionary:[rs resultDictionary]];
                [options addObject:option];
            }
            result.options = options;
        }
        return result;
    } else {
        return nil;
    }
    
}


//- (int) saveForm:(FormVO *) form {
//    
//    NSString *sql;
//    BOOL success;
//    NSDate *now = [NSDate date];
//    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
//    NSLog(@"dt %@", dt);
//    
//    @try {
//        sql = @"INSERT into form (system_id, name, type, status, created, updated) values (?, ?, ?, ?, ?, ?);";
//        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
//                   form.system_id,
//                   form.name,
//                   [NSNumber numberWithInt:form.type],
//                   [NSNumber numberWithInt:form.status],
//                   dt,
//                   dt
//                   ];
//        
//        if (!success) {
//            NSLog(@"####### SQL Insert failed #######");
//        } else {
//            NSLog(@"====== SQL INSERT SUCCESS ======");
//            
//            sql = @"SELECT last_insert_rowid()";
//            
//            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
//            
//            if ([rs next]) {
//                int lastId = [rs intForColumnIndex:0];
//                NSLog(@"lastId = %i", lastId);
//                return lastId;
//            }
//            
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"EXCEPTION %@", exception);
//    }
//    return -1;
//    
//}

/*
 
 form_id INTEGER PRIMARY KEY,
 system_id TEXT,
 name TEXT,
 location TEXT,
 description TEXT,
 imagefile TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 start_time TEXT,
 end_time TEXT,
 allow_public INT DEFAULT 0,
 allow_share INT DEFAULT 0,
 allow_multiple INT DEFAULT 0,
 created TEXT,
 updated TEXT
 */
- (int) saveForm:(FormVO *) form {
    
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        sql = @"INSERT into form (system_id, name, location, description, imagefile, type, status, start_time, end_time, allow_public, allow_share, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   form.system_id,
                   form.name,
                   form.location,
                   form.description,
                   form.imagefile,
                   [NSNumber numberWithInt:form.type],
                   [NSNumber numberWithInt:form.status],
                   form.start_time,
                   form.end_time,
                   [NSNumber numberWithInt:form.allow_public],
                   [NSNumber numberWithInt:form.allow_share],
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

- (void) deleteForm:(FormVO *) form {

    NSString *sql;
    BOOL success;
    
    sql = @"delete from form where form_id=?";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               form.form_id
               ];
    
    if (!success) {
        NSLog(@"####### SQL Delete failed #######");
    } else {
        NSLog(@"====== SQL DELETE SUCCESS ======");
    }

}
- (void) updateForm:(FormVO *) form{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    sql = @"UPDATE form set system_id=?, name=?, location=?, description=?, imagefile=?, type=?, status=?, start_time=?, end_time=?, allow_public=?, allow_share=?, allow_multiple=?, updated=? where form_id=?";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               form.system_id,
               form.name,
               form.location,
               form.description,
               form.imagefile,
               [NSNumber numberWithInt:form.type],
               [NSNumber numberWithInt:form.status],
               form.start_time,
               form.end_time,
               [NSNumber numberWithInt:form.allow_public],
               [NSNumber numberWithInt:form.allow_share],
               [NSNumber numberWithInt:form.allow_multiple],
               dt,
               [NSNumber numberWithInt:form.form_id]
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
        }
    }

}
- (NSMutableArray *) listForms:(NSString *)orderBy {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    return results;
}
- (FormOptionVO *) loadOption:(int)_optionId{
    NSString *sql = nil;
    sql = @"select * from form_option where option_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_optionId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    FormOptionVO *result;
    
    if (dict != nil) {
        result = [FormOptionVO readFromDictionary:dict];
    }
    return result;
}

- (int) saveOption:(FormOptionVO *) option{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    sql = @"INSERT into form_option (form_id, system_id, name, stats, datafile, imagefile, type, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [NSNumber numberWithInt:option.form_id],
               option.system_id,
               option.name,
               option.stats,
               option.datafile,
               option.imagefile,
               [NSNumber numberWithInt:option.type],
               [NSNumber numberWithInt:option.status],
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
- (void) deleteOption:(FormOptionVO *) option{
    
}
- (void) updateOption:(FormOptionVO *) option{
    
}


@end
