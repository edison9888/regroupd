//
//  ChatManager.m
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "ChatManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"
#import "DataModel.h"

@implementation ChatManager


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
        sql = @"INSERT into chat (system_id, name, type, status, created, updated) values (?, ?, ?, ?, ?, ?);";
        success = [[SQLiteDB sharedConnection] executeUpdate:sql,
                   chat.system_id,
                   chat.name,
                   [NSNumber numberWithInt:chat.type],
                   [NSNumber numberWithInt:chat.status],
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
    
}
- (void) updateChat:(ChatVO *) chat {
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
- (void) apiListChats:(NSString *)userId callback:(void (^)(NSArray *results))callback {
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"contact_keys" containsAllObjectsInArray:@[userId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        callback(results);
    }];
    
}

- (void) apiSaveChat:(ChatVO *)chat callback:(void (^)(PFObject *object))callback{
    
    PFObject *data = [PFObject objectWithClassName:kChatDB];
    
    if (chat.name != nil) {
        data[@"name"] = chat.name;
    }
    data[@"user"] = [PFUser currentUser];
    data[@"contact_keys"] = chat.contact_keys;
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved chat with objectId %@", data.objectId);
        callback(data);
    }];
}

- (void) apiFindChatsByContactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *results))callback {
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query whereKey:@"contact_keys" containsAllObjectsInArray:contactKeys];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        callback(results);
    }];
    
}

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
            callback(data);
        }];
        
    }];
}

/*
 async nested PFQueries.
 -- get the list of chat messages and convert to array of ChatMessageVO
 -- Get list of unique contact_key values and query for list of matching contacts
 
 */
- (NSMutableArray *) asyncListChatMessages:(NSString *)objectId {
    __block ChatVO *chat = [[ChatVO alloc] init];
    
    
    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        chat = [ChatVO readFromPFObject:object];
        
        PFQuery *query = [PFQuery queryWithClassName:kChatMessageDB];
        [query whereKey:@"chat"
                equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:objectId]];
        [query orderByAscending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:results.count];
            ChatMessageVO *msg;
            //            NSMutableArray *userKeys = [[NSMutableArray alloc] init];
            //
            for (PFObject *result in results) {
                msg = [[ChatMessageVO alloc] init];
                msg = [ChatMessageVO readFromPFObject:result];
                
                if (result[@"photo"]) {
                    msg.pfPhoto = result[@"photo"];
                }
                [msgs addObject:msg];                
            }
            
            //            NSLog(@"userKeys %@", userKeys);
            
            chat.messages = msgs;

            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_chatMessagesLoaded
                                                                                                 object:chat]];

            // IGNORE: This code was a mistake. It was overwriting the contactCache with pfContact data that does not have first/last name
            
//            PFQuery *query = [PFQuery queryWithClassName:kContactDB];
//            [query whereKey:@"objectId" containedIn:chat.contact_keys];
//            
//            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
//                NSMutableDictionary *contactMap = [[NSMutableDictionary alloc] initWithCapacity:results.count];
//                ContactVO *contact;
//                for (PFObject *result in results) {
//                    contact = [ContactVO readFromPFObject:result];
//                    [contactMap setObject:contact forKey:contact.system_id];
//                }
//                chat.contactMap = contactMap;
//                
//                [DataModel shared].contactCache = contactMap;
//                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_chatMessagesLoaded
//                                                                                                     object:chat]];
//            }];
            
            
        }];
        
    }];
    
    return nil;
}
- (NSMutableArray *) asyncListChatContacts:(NSArray *)objectIds {
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"objectId" containedIn:objectIds];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *msgs, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"chatContactsLoaded" object:msgs]];
    }];
    return nil;
}

#pragma mark - ChatForm API

- (void) apiSaveChatForm:(NSString *)chatId formId:(NSString *)formId callback:(void (^)(PFObject *object))callback{

    
    PFQuery *query = [PFQuery queryWithClassName:kChatFormDB];
    [query whereKey:@"chat" equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:chatId]];
    [query whereKey:@"form" equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:formId]];
    
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

- (ChatVO *) apiLoadChat:(NSString *)objectId {
    
    
    return [self apiLoadChat:objectId fetchAll:NO];
}
- (ChatVO *) apiLoadChat:(NSString *)objectId fetchAll:(BOOL)fetchAll {

    PFQuery *query = [PFQuery queryWithClassName:kChatDB];
    PFObject *data = [query getObjectWithId:objectId];
    // Do something with the returned PFObject .

    ChatVO *chat = [ChatVO readFromPFObject:data];
    
    if (fetchAll) {
        chat.messages = [[NSMutableArray alloc] init];
        ChatMessageVO *msg;
        
        query = [PFQuery queryWithClassName:kChatMessageDB];
        [query whereKey:@"chat" equalTo:data];
        [query orderByAscending:@"createdAt"];
        
        NSArray *results = [query findObjects];
        for (PFObject *msgdata in results) {
            msg = [ChatMessageVO readFromPFObject:msgdata];
            if (msg != nil) {
                [chat.messages addObject:msg];
            }
        }
        
    }
    
    return chat;
//    ChatVO *match = [self findChatBySystemId:data.objectId];
//    if (match == nil) {
//        // Save to database
//        [self saveChat:chat];
//    }
    return nil;

}
- (NSString *) apiSaveChat:(ChatVO *) chat {
    
    PFObject *data = [PFObject objectWithClassName:kChatDB];
    
    if (chat.name != nil) {
        data[@"name"] = chat.name;        
    }
    data[@"user"] = [PFUser currentUser];
    data[@"contact_keys"] = chat.contact_keys;
    [data save];
    
    NSLog(@"Saved chat with objectId %@", data.objectId);
    return data.objectId;
    
}





@end
