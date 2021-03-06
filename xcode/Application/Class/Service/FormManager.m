//
//  FormManager.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import "FormManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"


@implementation FormManager


- (int) fetchLastFormID{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"SELECT MAX(form_id) AS max_id FROM form";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    int maxId = 0;

    if ([rs next]) {
        maxId = [rs intForColumnIndex:0];
    }
    
    return maxId;
}
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
                   form.details,
                   form.imagefile,
                   [NSNumber numberWithInt:form.type],
                   [NSNumber numberWithInt:form.status],
                   form.start_time,
                   form.end_time,
                   form.allow_public,
                   form.allow_share,
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
               form.details,
               form.imagefile,
               [NSNumber numberWithInt:form.type],
               [NSNumber numberWithInt:form.status],
               form.start_time,
               form.end_time,
               form.allow_public,
               form.allow_share,
               form.allow_multiple,
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
- (NSMutableArray *) listForms:(int)typeFilter {
    NSMutableArray *results = [[NSMutableArray alloc] init];
 
    if (typeFilter == 0) {
        NSString *sql = @"select * from form order by updated desc";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        FormVO *row;
        
        while ([rs next]) {
            row = [FormVO readFromDictionary:[rs resultDictionary]];
            [results addObject:row];
        }
        
    } else {
        NSLog(@"%s: %i", __FUNCTION__, typeFilter);
        NSString *sql = @"select * from form where type=? order by updated desc";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                           [NSNumber numberWithInt:typeFilter]];
        FormVO *row;

        while ([rs next]) {
            row = [FormVO readFromDictionary:[rs resultDictionary]];
            [results addObject:row];
        }
    }
    
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

- (NSMutableArray *) listFormOptions:(int)formId {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select * from form_option where form_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:formId]];
    FormVO *row;
    
    while ([rs next]) {
        row = [FormVO readFromDictionary:[rs resultDictionary]];
        [results addObject:row];
    }
    
    return results;
}

- (int) fetchLastOptionID{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"SELECT MAX(option_id) AS max_id FROM form_option";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    int maxId = 0;
    
    if ([rs next]) {
        maxId = [rs intForColumnIndex:0];
    }
    
    return maxId;
}

#pragma mark - image handling
/*
 Create a temporary filename and save image data to file in Documents or temp dir
 */
- (NSString *)saveFormImage:(UIImage *)saveImage withName:(NSString *)filename
{
    
    
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSLog(@"Saving image to: %@", savePath);
    
    NSData *imageData = UIImagePNGRepresentation(saveImage);
    
    [imageData writeToFile:savePath atomically:NO];
    
    return savePath;
}

- (UIImage *)loadFormImage:(NSString *)filename {
    
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

#pragma mark - Form API functions


// API client functions
- (void) apiSaveForm:(FormVO *)form callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    
    if (form.photo == nil) {

        PFObject *data = [self buildPFForm:form];
        
        [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Saved form with objectId %@", data.objectId);
            callback(data);
        }];
    } else {
        
        NSData *imageData = UIImagePNGRepresentation(form.photo);
        
        PFFile *fileObject = [PFFile fileWithName:form.imagefile data:imageData];
        
        [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFObject *data = [self buildPFForm:form];
            data[@"photo"] = fileObject;

            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved form with objectId %@", data.objectId);
                callback(data);
                
                
            }];
            
        }];

    }
}

- (PFObject *) buildPFForm:(FormVO *)form {
    PFObject *data = [PFObject objectWithClassName:kFormDB];
    
    data[@"name"] = form.name;
    data[@"type"] = [NSNumber numberWithInt:form.type];
    if (form.status) {
        data[@"status"] = form.status;
    }
    
    data[@"user"] = [PFUser currentUser];
    data[@"contact_key"] = [DataModel shared].user.contact_key;
    
    if (form.location != nil) {
        data[@"location"] = form.location;
    }
    if (form.details != nil) {
        data[@"details"] = form.details;
    }
    if (form.eventStartsAt != nil) {
        data[@"eventStartsAt"] = form.eventStartsAt;
    }
    if (form.eventEndsAt != nil) {
        data[@"eventEndsAt"] = form.eventEndsAt;
    }
    if (form.allow_share != nil) {
        data[@"allow_share"] = form.allow_share;
    }
    if (form.allow_public != nil) {
        data[@"allow_public"] = form.allow_public;
    }
    if (form.allow_multiple != nil) {
        data[@"allow_multiple"] = form.allow_multiple;
    }
    return data;
}


- (void) apiRemoveForm:(NSString *)formKey callback:(void (^)(BOOL))callback {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Load form %@", formKey);
    PFQuery *query = [PFQuery queryWithClassName:kFormDB];
    [query getObjectInBackgroundWithId:formKey block:^(PFObject *pfForm, NSError *error) {
        
        if (error) {
            NSLog(@"########### Error loading form %@", formKey);
            
        } else {
            pfForm[@"status"] = [NSNumber numberWithInt:FormStatus_REMOVED];
            [pfForm saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                callback(YES);
            }];
        }
    }];
    
}
- (void) apiLoadForm:(NSString *)formKey fetchAll:(BOOL)fetchAll callback:(void (^)(FormVO *form))callback {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Load form %@", formKey);
    PFQuery *query = [PFQuery queryWithClassName:kFormDB];
    [query getObjectInBackgroundWithId:formKey block:^(PFObject *pfForm, NSError *error) {
        FormVO *form;
        if (!error) {
            form = [FormVO readFromPFObject:pfForm];
            
            if (fetchAll) {
                NSLog(@"Load form options %@", formKey);
                
                PFQuery *query = [PFQuery queryWithClassName:kFormOptionDB];
                [query whereKey:@"form" equalTo:pfForm];
                [query addAscendingOrder:@"position"];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                    if (error) {
                        NSLog(@"Error with options for formKey %@", formKey);
                        callback(nil);
                    } else {
                        NSLog(@"Found form options %i", results.count);
                        
                        FormOptionVO *option;
                        form.options = [[NSMutableArray alloc] init];
                        for (PFObject *result in results) {
                            option = [FormOptionVO readFromPFObject:result];
                            [form.options addObject: option];
                        }
                        callback(form);
                        
                    }
                }];

            } else {
                callback(form);
            }
        } else {
            NSLog(@"Error with loading formKey %@", formKey);
            callback(nil);
        }
    }];
    
    
}

- (void) apiListForms:(NSString *)contactKey callback:(void (^)(NSArray *results))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kFormDB];
    if (contactKey == nil) {
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"contact_key" equalTo:contactKey];
    }
    [query whereKey:@"status" notEqualTo:[NSNumber numberWithInt:FormStatus_REMOVED]];
    
    [query addDescendingOrder:@"updatedAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
}

- (void) apiUpdateFormCounter:(NSString *)formKey withCount:(NSNumber *)count {
    
    PFQuery *query = [PFQuery queryWithClassName:kFormDB];
    [query getObjectInBackgroundWithId:formKey block:^(PFObject *pfChat, NSError *error) {
        if (pfChat) {
            if (count) {
                pfChat[@"counter"] = count;
                [pfChat saveInBackground];
            } else {
                [pfChat incrementKey:@"counter"];
                [pfChat saveInBackground];
            }
        }
    }];
}


#pragma mark - Form Option API functions


- (void)apiSaveFormOption:(FormOptionVO *)option formId:(NSString *)formId callback:(void (^)(PFObject *object))callback
{
    if (option.photo == nil) {
        
        PFObject *data = [PFObject objectWithClassName:kFormOptionDB];
        
        data[@"form"] = [PFObject objectWithoutDataWithClassName:kFormDB objectId:formId];
        data[@"name"] = option.name;
        if (option.position > 0) {
            data[@"position"] = [NSNumber numberWithInt:option.position];
        }
        [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Saved form option with objectId %@", data.objectId);
            callback(data);
        }];
        
    } else {
        NSData *imageData = UIImagePNGRepresentation(option.photo);
        
        PFFile *fileObject = [PFFile fileWithName:option.imagefile data:imageData];
        
        [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            PFObject *data = [PFObject objectWithClassName:kFormOptionDB];
            
            data[@"form"] = [PFObject objectWithoutDataWithClassName:kFormDB objectId:formId];
            data[@"name"] = option.name;
            if (option.position > 0) {
                data[@"position"] = [NSNumber numberWithInt:option.position];
            }
            
            data[@"photo"]=fileObject;
            
            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved form option with objectId %@", data.objectId);
                callback(data);
            }];
            
        }];
        
    }
}

- (void) apiListFormOptions:(NSString *)formId callback:(void (^)(NSArray *results))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kFormOptionDB];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formId]];
     
    [query addAscendingOrder:@"position"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
}

- (void)apiLookupFormOption:(NSString *)formKey withName:(NSString *)name callback:(void (^)(FormOptionVO *option))callback
{
    PFQuery *query = [PFQuery queryWithClassName:kFormOptionDB];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    [query whereKey:@"name" equalTo:name];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if (results) {
            PFObject *pfObject = [results objectAtIndex:0];
            FormOptionVO *result = [FormOptionVO readFromPFObject:pfObject];
            callback(result);
        }
        callback(nil);
    }];
    
    
}

#pragma mark - Form Response API

- (void)apiSaveFormResponse:(FormResponseVO *)response callback:(void (^)(PFObject *object))callback
{
    PFObject *data = [PFObject objectWithClassName:kFormResponseDB];
    
    // TODO: Check for previously saved responses and stop / purge if needed.
    
    data[@"form"] = [PFObject objectWithoutDataWithClassName:kFormDB objectId:response.form_key];
    data[@"contact"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:response.contact_key];
    if (response.chat_key != nil) {
        data[@"chat"] = [PFObject objectWithoutDataWithClassName:kChatDB objectId:response.chat_key];
    }
    if (response.option_key != nil) {
        data[@"option"] =[PFObject objectWithoutDataWithClassName:kFormOptionDB objectId:response.option_key];
    }
    if (response.rating != nil) {
        data[@"rating"] = response.rating;
    }
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved form option with objectId %@", data.objectId);
        [self apiUpdateFormCounter:response.form_key withCount:nil];
        callback(data);
    }];
}
- (void)apiListFormResponses:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(NSArray *results))callback
{
    PFQuery *query = [PFQuery queryWithClassName:kFormResponseDB];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    
    if (contactKey != nil) {
        [query whereKey:@"contact" equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (error) {
            callback(nil);
        } else {
            callback(results);
        }
    }];
}

#pragma mark - FormContact API

- (void) apiSaveFormContact:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(PFObject *object))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kFormContactDB];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    [query whereKey:@"contact" equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfObject, NSError *error) {
        
        if (pfObject) {
            callback(pfObject);
        } else {
            PFObject *data = [PFObject objectWithClassName:kFormContactDB];
            
            data[@"form"] = [PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey];
            data[@"contact"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey];
            
            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved form-contact with objectId %@", data.objectId);
                callback(data);
            }];
        }
        
    }];
    
}
- (void) apiListFormContacts:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(NSArray *results))callback{
    PFQuery *query = [PFQuery queryWithClassName:kFormContactDB];
    
    if (formKey) {
        [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    }
    if (contactKey) {
        [query whereKey:@"contact" equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
    
}

- (void) apiCountFormContacts:(NSString *)formKey excluding:(NSString *)contactKey callback:(void (^)(int rowcount))callback{
    PFQuery *query = [PFQuery queryWithClassName:kFormContactDB];
    
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    
    if (contactKey != nil) {
        [query whereKey:@"contact" notEqualTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    }
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        callback(number);
    }];
    
}

/*
 
 Find contact keys already saved. Useful in finding contact keys that need to be saved
 */
- (void) apiLookupFormContacts:(NSString *)formKey contactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *savedKeys))callback{
    PFQuery *query = [PFQuery queryWithClassName:kFormContactDB];
    
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formKey]];
    
    [query whereKey:@"contact_key" containedIn:contactKeys];
    __block NSMutableArray *savedKeys = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            NSString *key = object[@"contact_key"];
            [savedKeys addObject: key];
        }
        callback([savedKeys copy]);
    }];
    
}

- (void) apiBatchSaveFormContacts:(NSString *)formKey contactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *savedKeys))callback {
    int total = contactKeys.count;
    __block int index = 0;
    
    __block NSMutableArray *savedKeys = [[NSMutableArray alloc] init];
    for (NSString *key in contactKeys) {
        [self apiSaveFormContact:formKey contactKey:key callback:^(PFObject *object) {
            [savedKeys addObject:key];
            index++;
            if (index == total) {
                callback([savedKeys copy]);
            }
        }];
    }
}

// Returns array of forms
- (void) apiFindReceivedForms:(NSString *)contactKey callback:(void (^)(NSArray *results))callback{

    
//    PFQuery *innerQuery = [PFQuery queryWithClassName:kFormContactDB];
//    [innerQuery whereKey:@"contact" equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
//    PFQuery *query = [PFQuery queryWithClassName:kFormDB];
//    [query whereKey:@"post" matchesQuery:innerQuery];
    
    PFQuery *query = [PFQuery queryWithClassName:kFormContactDB];
    [query whereKey:@"contact" equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    [query includeKey:@"form"];
    __block NSMutableSet *receivedFormSet = [[NSMutableSet alloc] init];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        for (PFObject *data in results) {
            
            PFObject *form = data[@"form"];
            if (form != nil) {
                NSString *contactKey = form[@"contact_key"];
                if (![contactKey isEqualToString:[DataModel shared].user.contact_key]) {
                    [receivedFormSet addObject:form];
                } else {
                    // ignore if owner of form
                }
            } else {
                // form is nil
            }
        }
        callback([receivedFormSet allObjects]);
    }];
    
}

@end
