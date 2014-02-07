//
//  ChatManager.m
//  Re:group'd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "ChatManager.h"
#import "GroupManager.h"
#import "FormManager.h"

#import "SQLiteDB.h"
#import "DateTimeUtils.h"
#import "DataModel.h"

@implementation ChatManager


- (ChatVO *) loadChatByKey:(NSString *)chatKey {
    NSString *sql = nil;
    sql = @"select * from chat where system_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       chatKey];
    
    ChatVO *result;
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
        result = [ChatVO readFromDictionary:dict];
    }
    return result;
    
}

- (void) updateChat:(NSString *)chatKey withName:(NSString *)name status:(NSNumber *)status {
    
    NSString *sql;
    BOOL success;
    
    @try {
        sql = @"UPDATE chat set name=?, status=? where system_id=?";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   name,
                   status,
                   chatKey
                   ];
        
        if (!success) {
            NSLog(@"####### SQL Update failed #######");
        } else {
            NSLog(@"====== SQL UPDATE SUCCESS ======");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION %@", exception);
    }
    
}

- (void) updateChatReadTime:(NSString *)chatKey name:(NSString *)name readtime:(NSNumber *)readtime  {
    NSString *sql;
    BOOL success;
    NSLog(@"%@ update readtime = %f",chatKey, readtime.doubleValue);
    
    @try {
        sql = @"UPDATE chat set name=?, read_timestamp=? where system_id=?";
        //        sql = [NSString stringWithFormat:sql, chatKey];
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   name,
                   readtime,
                   chatKey
                   ];
        
        if (!success) {
            NSLog(@"####### SQL Update failed #######");
        } else {
            NSLog(@"====== SQL UPDATE SUCCESS ======");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION %@", exception);
    }
    
}

- (void) updateClearTimestamp:(NSString *)chatKey cleartime:(NSNumber *)cleartime {
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        if ([chatKey isEqualToString:@"*"]) {
            sql = @"UPDATE chat set clear_timestamp=?";
            success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                       cleartime,
                       chatKey
                       ];
            
        } else {
            sql = @"UPDATE chat set clear_timestamp=? where system_id=?";
            success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                       cleartime,
                       chatKey
                       ];
            
        }
        
        if (!success) {
            NSLog(@"####### SQL Update failed #######");
        } else {
            NSLog(@"====== SQL UPDATE SUCCESS ======");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION %@", exception);
    }
    
}

- (void) updateChatStatus:(NSString *)chatKey status:(int)status {
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        sql = @"UPDATE chat set status=? where system_id=?";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   [NSNumber numberWithInt:status],
                   chatKey
                   ];
        
        if (!success) {
            NSLog(@"####### SQL Update failed #######");
        } else {
            NSLog(@"====== SQL UPDATE SUCCESS ======");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION %@", exception);
    }
    
}

- (ChatVO *) loadChat:(int)_chatId {
    return [self loadChat:_chatId fetchAll:NO];
}

- (ChatVO *) loadChat:(int)_chatId fetchAll:(BOOL)all {
    
    NSString *sql = nil;
    sql = @"select * from chat where chat_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_chatId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        ChatVO *result = [ChatVO readFromDictionary:dict];
        
        if (all) {
            NSMutableArray *msgs = [[NSMutableArray alloc] init];
            
            sql = @"select * from chat_message where chat_id=? order by message_id";
            rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                  [NSNumber numberWithInt:_chatId]];
            
            ChatMessageVO *msg;
            
            while ([rs next]) {
                msg = [ChatMessageVO readFromDictionary:[rs resultDictionary]];
                
                [msgs addObject:msg];
            }
            result.messages = msgs;
            
        }
        return result;
    } else {
        return nil;
    }
    
}

/*
 chat_id INTEGER PRIMARY KEY,
 system_id TEXT,
 name TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 
 */
- (int) saveChat:(ChatVO *)chat {
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        sql = @"INSERT into chat (user_key, system_id, name, type, status, clear_timestamp, read_timestamp, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   chat.user_key,
                   chat.system_id,
                   chat.name,
                   chat.type,
                   chat.status,
                   [NSNumber numberWithDouble:0],
                   [NSNumber numberWithDouble:0],
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
- (void) deleteChat:(ChatVO *) chat {
    
    
    NSString *sql;
    BOOL success;
    
    sql = @"delete from chat where system_id=?";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               chat.system_id
               ];
    
    if (!success) {
        NSLog(@"####### SQL Delete failed #######");
    } else {
        NSLog(@"====== SQL DELETE SUCCESS ======");
    }
    
}
- (NSMutableArray *) listChats:(int)type {
    return nil;
}

#pragma mark - Chat Message DAO

- (ChatMessageVO *) loadChatMessage:(int)_msgId {
    
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"select * from chat_message where message_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_msgId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        ChatMessageVO *result = [ChatMessageVO readFromDictionary:dict];
        return result;
    } else {
        return nil;
    }
    
}

/*
 message_id INTEGER PRIMARY KEY,
 chat_id INTEGER,
 contact_id INTEGER,
 form_id INTEGER,
 system_id TEXT,
 message TEXT,
 attachment TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT
 */

- (int) saveChatMessage:(ChatMessageVO *)msg {
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    @try {
        sql = @"INSERT into chat_message (chat_id, contact_id, form_id, system_id, message, attachment, type, status, created) values (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   [NSNumber numberWithInt:msg.chat_id],
                   [NSNumber numberWithInt:msg.contact_id],
                   [NSNumber numberWithInt:msg.form_id],
                   msg.system_id,
                   msg.message,
                   msg.attachment,
                   [NSNumber numberWithInt:msg.type],
                   [NSNumber numberWithInt:msg.status],
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
- (void) deleteChatMessage:(ChatMessageVO *) msg {
    
}
- (void) updateChatMessage:(ChatMessageVO *) msg {
}
- (NSMutableArray *) listChatMessages:(int)type {
    return nil;
}

#pragma mark - Find By System ID

// Find ChatVO by system_id
- (ChatVO *) findChatBySystemId:(NSString *)objectId {
    
    
    NSString *sql = nil;
    sql = @"select * from chat where system_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql, objectId];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        ChatVO *result = [ChatVO readFromDictionary:dict];
        return result;
    }
    return nil;
    
}
- (ChatMessageVO *) findChatMessageBySystemId:(NSString *)objectId {
    NSString *sql = nil;
    sql = @"select * from chat_message where system_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql, objectId];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    if (dict != nil) {
        ChatMessageVO *result = [ChatMessageVO readFromDictionary:dict];
        return result;
    }
    return nil;
    
}



#pragma mark - Chat API

- (void)apiLoadChat:(NSString *)objectId callback:(void (^)(ChatVO *chat))callback {
    
    if ([[DataModel shared].chatCache objectForKey:objectId]) {
        ChatVO *chat = [[DataModel shared].chatCache objectForKey:objectId];
        callback(chat);
    } else {
        PFQuery *query = [PFQuery queryWithClassName:kChatDB];
        [query whereKey:@"objectId" equalTo:objectId];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfObject, NSError *error) {
            ChatVO *chat = [ChatVO readFromPFObject:pfObject];
            callback(chat);
        }];
        
    }
}

- (void) apiListChats:(NSString *)contactKey status:(NSNumber *)status callback:(void (^)(NSArray *results))callback {
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"contact_keys" containsAllObjectsInArray:@[contactKey]];
    [query whereKey:@"removed_keys" notContainedIn:@[contactKey]];
    if (status) {
        if (status.intValue == ChatType_GROUP) {
            [query whereKey:@"status" equalTo:status];
        } else {
            [query whereKey:@"status" notEqualTo:[NSNumber numberWithInt:ChatType_GROUP]];
        }
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        callback(results);
    }];
    
}

- (void) apiFindGroupChats:(NSString *)userId
                withStatus:(NSNumber *)status
                 excluding:(NSArray *)excludedKeys callback:(void (^)(NSArray *results))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"contact_keys" containsAllObjectsInArray:@[userId]];
    [query whereKey:@"status" equalTo:status];
    [query whereKey:@"objectId" notContainedIn:excludedKeys];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
}

- (void) apiSaveChat:(ChatVO *)chat callback:(void (^)(PFObject *object))callback{
    
    PFObject *data = [PFObject objectWithClassName:kChatDB];
    
    if (chat.system_id != nil) {
        data.objectId = chat.system_id;
    }
    if (chat.name != nil) {
        data[@"name"] = chat.name;
    }
    if (chat.status != nil) {
        data[@"status"] = chat.status;
    }
    data[@"user"] = [PFUser currentUser];
    data[@"contact_keys"] = chat.contact_keys;

    if (chat.removed_keys != nil) {
        data[@"removed_keys"] = chat.removed_keys;
    }
    if (chat.contact_names != nil) {
        data[@"contact_names"] = chat.contact_names;
    }
    
    
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved chat with objectId %@", data.objectId);
        callback(data);
    }];
}
- (void) apiUpdateChatCounter:(NSString *)chatKey {
    
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query getObjectInBackgroundWithId:chatKey block:^(PFObject *pfChat, NSError *error) {
        if (error) {
            NSLog(@"apiUpdateChatCounter error: %@", error);
        }
        if (pfChat) {
            [pfChat incrementKey:@"counter"];
            [pfChat saveInBackground];
        }
    }];
}
- (void) apiModifyChat:(NSString *)chatKey removeContact:(NSString *)contactKey callback:(void (^)(PFObject *pfChat))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"objectId" equalTo:chatKey];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfObject, NSError *error) {
        if (error) {
            return;
        }
        if (pfObject) {
            
            NSArray *contactKeys = (NSArray *) [pfObject valueForKey:@"contact_keys"];
            int index = 0;
            NSMutableArray *resultKeys = [[NSMutableArray alloc] init];
            @try {
                for (NSString *key in contactKeys) {
                    if (![key isEqualToString:contactKey]) {
                        [resultKeys addObject:key];
                    }
                    index++;
                }
            }
            @catch (NSException *exception) {
                NSLog(@"ERROR %@", exception);
            }
            
            pfObject[@"contact_keys"] = resultKeys;
            
            [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                callback(pfObject);
            }];
        }
    }];
}

- (void) apiFindChatsByContactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *results))callback {
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"contact_keys" containsAllObjectsInArray:contactKeys];
//    [query whereKey:@"removed_keys" notContainedIn:@[contactKey]];
    [query whereKey:@"status" notEqualTo:[NSNumber numberWithInt:ChatType_GROUP]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
}
/*
 Method for sending a message to a contact and you don't know if a chat exists already.
 */
- (void) apiSendMessageToContact:(ChatMessageVO *)msg contact:(ContactVO *)contact callback:(void (^)(ChatVO *chat))callback{
    FormManager *formSvc = [[FormManager alloc] init];
    
    NSArray *contactKeys = @[contact.system_id, [DataModel shared].user.contact_key];
//    NSArray *contactKeys = [NSArray arrayWithObjects:contact.system_id, [DataModel shared].user.contact_key, nil];
    
    [self apiFindChatsByContactKeys:contactKeys callback:^(NSArray *results) {
        BOOL chatExists = NO;
        ChatVO *chat;
        if (results && results.count > 0) {
            for (PFObject *pfChat in results) {
                if (pfChat[@"contact_keys"]) {
                    NSArray *keys =pfChat[@"contact_keys"];
                    if (keys.count == 2) {
                        // exact match.
                        chat = [ChatVO readFromPFObject:pfChat];
                        chatExists = YES;
                        break;
                    }
                }
            }
        }
        if (chatExists) {
            msg.chat_key = chat.system_id;
            [self apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                if (pfMessage) {
                    if (msg.form_key == nil || msg.form_key.length == 0 ) {
                        callback(chat);
                        
                    } else {
                        [formSvc apiLookupFormContacts:msg.form_key contactKeys:contactKeys callback:^(NSArray *savedKeys) {
                            
                            NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                            
                            for (NSString *key in chat.contact_keys) {
                                
                                if (![savedKeys containsObject:key]) {
                                    [unsavedKeySet addObject:key];
                                }
                            }
                            if (unsavedKeySet.count == 0) {
                                callback(chat);
                            } else {
                                [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                                    NSLog(@"Saved form contacts count %i", savedKeys.count);
                                    
                                    callback(chat);
                                    
                                }];
                            }
                        }];
                        
                    }
                    
                } else {
                    NSLog(@"Chat message was not saved");
                    callback(nil);
                }
            }];
            
            
            
        } else {
            ChatVO *chat = [[ChatVO alloc] init];
            
            chat.contact_keys = contactKeys;
            chat.status = [NSNumber numberWithInt:ChatType_INFORMAL];
            NSString *chatname = @"%@, %@";
            chatname = [NSString stringWithFormat:chatname, contact.fullname, [DataModel shared].myContact.fullname];
            chat.name = chatname;
            //            chat.name =
            [self apiSaveChat:chat callback:^(PFObject *pfChat) {
                
                // Adding push notifications subscription
                chat.system_id = pfChat.objectId;
                
                [self saveChat:chat];
                msg.chat_key = chat.system_id;
                [self apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                    if (pfMessage) {
                        if (msg.form_key == nil || msg.form_key.length == 0 ) {
                            callback(chat);
                            
                        } else {
                            [formSvc apiLookupFormContacts:msg.form_key contactKeys:contactKeys callback:^(NSArray *savedKeys) {
                                
                                NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                                
                                for (NSString *key in chat.contact_keys) {
                                    
                                    if (![savedKeys containsObject:key]) {
                                        [unsavedKeySet addObject:key];
                                    }
                                }
                                if (unsavedKeySet.count == 0) {
                                    callback(chat);
                                } else {
                                    [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                                        NSLog(@"Saved form contacts count %i", savedKeys.count);
                                        
                                        callback(chat);
                                        
                                    }];
                                }
                            }];
                            
                        }
                        
                    } else {
                        NSLog(@"Chat message was not saved");
                        callback(nil);
                    }
                }];
            }];
        }
    }];
    
    
}
- (void) apiSendMessageToGroup:(ChatMessageVO *)msg group:(GroupVO *)group callback:(void (^)(ChatVO *chat))callback{
    
    GroupManager *groupSvc = [[GroupManager alloc] init];
    FormManager *formSvc = [[FormManager alloc] init];
    
    if (group.chat_key != nil && group.chat_key.length > 0) {
        NSLog(@"Found existing chat_key=%@", group.chat_key);
        
        [self apiLoadChat:group.chat_key callback:^(ChatVO *chat) {
            // Send message
            msg.chat_key = chat.system_id;
            [self apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                if (pfMessage) {
                    if (msg.form_key == nil || msg.form_key.length == 0 ) {
                        callback(chat);
                        
                    } else {
                        [formSvc apiLookupFormContacts:msg.form_key contactKeys:chat.contact_keys callback:^(NSArray *savedKeys) {
                            
                            NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                            
                            for (NSString *key in chat.contact_keys) {
                                
                                if (![savedKeys containsObject:key]) {
                                    [unsavedKeySet addObject:key];
                                }
                            }
                            
                            if (unsavedKeySet.count == 0) {
                                callback(chat);
                            } else {
                                [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                                    NSLog(@"Saved form contacts count %i", savedKeys.count);
                                    
                                    callback(chat);
                                    
                                }];
                            }
                        }];
                        
                    }
                    
                } else {
                    NSLog(@"Chat message was not saved");
                    callback(nil);
                }
            }];
            
        }];
        
    } else {
        NSLog(@"Creating new chat");
        
        NSMutableArray *contactKeys = [groupSvc listGroupContactKeys:group.group_id];
        [contactKeys addObject:[DataModel shared].user.contact_key];
        
        ChatVO *chat = [[ChatVO alloc] init];
        chat.name = group.name;
        chat.status = [NSNumber numberWithInt:ChatType_GROUP];
        chat.contact_keys = contactKeys;
        
        [self apiSaveChat:chat callback:^(PFObject *pfChat) {
            
            if (!pfChat) {
                NSLog(@"apiSaveChat failed");
                callback(nil);
            } else {
                // Adding push notifications subscription
                NSLog(@"Saving group chat_key %@", pfChat.objectId);
                //                GroupVO *group = [DataModel shared].group;
                group.chat_key = pfChat.objectId;
                [groupSvc updateGroup:group];
                
                chat.system_id = pfChat.objectId;
                
                [self saveChat:chat];
                
                msg.chat_key = chat.system_id;
                
                [self apiSaveChatMessage:msg callback:^(PFObject *pfMessage) {
                    if (pfMessage) {
                        if (msg.form_key == nil || msg.form_key.length == 0 ) {
                            
                            callback(chat);
                        } else {
                            [formSvc apiLookupFormContacts:msg.form_key contactKeys:chat.contact_keys callback:^(NSArray *savedKeys) {
                                
                                NSMutableSet *unsavedKeySet = [[NSMutableSet alloc] init];
                                
                                for (NSString *key in chat.contact_keys) {
                                    
                                    if (![savedKeys containsObject:key]) {
                                        [unsavedKeySet addObject:key];
                                    }
                                }
                                
                                if (unsavedKeySet.count == 0) {
                                    callback(chat);
                                } else {
                                    [formSvc apiBatchSaveFormContacts:msg.form_key contactKeys:[unsavedKeySet allObjects] callback:^(NSArray *savedKeys) {
                                        NSLog(@"Saved form contacts count %i", savedKeys.count);
                                        callback(chat);
                                        
                                    }];
                                }
                            }];
                            
                        }
                        
                    } else {
                        NSLog(@"Chat message was not saved");
                    }
                }];
                
                
            }
        }];
    }
    
}

#pragma mark - ChatMessage API

- (void) apiSaveChatMessage:(ChatMessageVO *)msg callback:(void (^)(PFObject *object))callback{
    
    PFObject *data = [PFObject objectWithClassName:kChatMessageDB];
    
    data[@"chat"] = [PFObject objectWithoutDataWithClassName:kChatDB objectId:msg.chat_key];
    
    if (msg.message) {
        data[@"message"]=msg.message;
    }
    data[@"contact_key"] = msg.contact_key;
    if (msg.form_key) {
        data[@"form_key"]=msg.form_key;
    }
    
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved message with objectId %@", data.objectId);
        [self apiUpdateChatCounter:msg.chat_key];
        callback(data);
    }];
}


- (void)apiSaveChatMessage:(ChatMessageVO *)msg withPhoto:(UIImage *)saveImage callback:(void (^)(PFObject *object))callback
{
    if (saveImage == nil) {
        NSLog(@"image required");
        return;
    }
    NSData *imageData = UIImagePNGRepresentation(saveImage);
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    NSString *filename = [NSString stringWithFormat:@"%f.png", seconds];
    
    NSLog(@"Save photo to parse");
    
    PFFile *fileObject = [PFFile fileWithName:filename data:imageData];
    
    [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFObject *data = [PFObject objectWithClassName:kChatMessageDB];
        
        data[@"chat"] = [PFObject objectWithoutDataWithClassName:kChatDB objectId:msg.chat_key];
        data[@"contact_key"] = msg.contact_key;
        if (msg.message) {
            data[@"message"]=msg.message;
        }
        data[@"photo"]=fileObject;
        
        [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Saved message with objectId %@", data.objectId);
            [self apiUpdateChatCounter:msg.chat_key];
            callback(data);
        }];
        
    }];
}

/*
 async nested PFQueries.
 -- get the list of chat messages and convert to array of ChatMessageVO
 -- Get list of unique contact_key values and query for list of matching contacts
 
 */
- (void) apiListChatMessages:(NSString *)chatKey afterDate:(NSDate *)date callback:(void (^)(NSArray *results))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kChatMessageDB];
    [query whereKey:@"chat"
            equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:chatKey]];
    if (date) {
        NSLog(@"Date filter is %@", date);
        [query whereKey:@"createdAt" greaterThan:date];
    }
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if (error) {
            NSLog(@">>>>>>>>>> ERROR %@", error);
        } else {
            NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:results.count];
            ChatMessageVO *msg;
            for (PFObject *result in results) {
                msg = [[ChatMessageVO alloc] init];
                msg = [ChatMessageVO readFromPFObject:result];
                
                if (result[@"photo"]) {
                    msg.pfPhoto = result[@"photo"];
                }
                [msgs addObject:msg];
            }
            
            
            callback([msgs copy]);
            
        }
        
        
    }];
}

#pragma mark - ChatForm API

- (void) apiSaveChatForm:(NSString *)chatId formId:(NSString *)formId callback:(void (^)(PFObject *object))callback{
    
    
    PFQuery *query = [PFQuery queryWithClassName:kChatFormDB];
    [query whereKey:@"chat" equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:chatId]];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formId]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfObject, NSError *error) {
        
        if (pfObject) {
            callback(pfObject);
        } else {
            PFObject *data = [PFObject objectWithClassName:kChatFormDB];
            
            data[@"chat"] = [PFObject objectWithoutDataWithClassName:kChatDB objectId:chatId];
            data[@"form"] = [PFObject objectWithoutDataWithClassName:kFormDB objectId:formId];
            
            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved chat-form with objectId %@", data.objectId);
                callback(data);
            }];
        }
        
    }];
    
}
- (void) apiListChatForms:(NSString *)chatId formKey:(NSString *)formId callback:(void (^)(NSArray *results))callback{
    PFQuery *query = [PFQuery queryWithClassName:kChatFormDB];
    
    if (chatId) {
        [query whereKey:@"chat" equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:chatId]];
    }
    if (formId) {
        [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kFormDB objectId:formId]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        callback(results);
    }];
    
    
}
#pragma mark - Synchronous API -- to be deprecated

//- (NSString *) apiSaveChat:(ChatVO *) chat {
//
//    PFObject *data = [PFObject objectWithClassName:kChatDB];
//
//    if (chat.name != nil) {
//        data[@"name"] = chat.name;
//    }
//    data[@"user"] = [PFUser currentUser];
//    data[@"contact_keys"] = chat.contact_keys;
//    [data save];
//
//    NSLog(@"Saved chat with objectId %@", data.objectId);
//    return data.objectId;
//    
//}





@end
