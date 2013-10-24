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
        [query orderByAscending:@"created"];
        
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
    
    data[@"name"] = chat.name;
    data[@"user"] = [PFUser currentUser];
    data[@"contact_keys"] = chat.contact_keys;
    [data save];
    
    NSLog(@"Saved chat with objectId %@", data.objectId);
    return data.objectId;
    
}
- (NSMutableArray *) apiListChats:(NSString *)userId {
    
    return nil;
}
- (void) apiDeleteChat:(ChatVO *)chat {
    
}

- (ChatMessageVO *) apiLoadChatMessage:(NSString *)objectId {
    
    return nil;
}
- (NSString *) apiSaveChatMessage:(ChatMessageVO *) msg {

    return nil;

}
- (void) apiDeleteChatMessage:(ChatMessageVO *)msg {
    
}

/*
 async nested PFQueries.
 -- get the list of chat messages and convert to array of ChatMessageVO
 -- Get list of unique contact_key values and query for list of matching contacts
 
 */
- (NSMutableArray *) asyncListChatMessages:(NSString *)objectId {
    PFQuery *query = [PFQuery queryWithClassName:kChatMessageDB];
    [query whereKey:@"chat"
            equalTo:[PFObject objectWithoutDataWithClassName:kChatDB objectId:objectId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:results.count];
        ChatMessageVO *msg;
        NSMutableArray *userKeys = [[NSMutableArray alloc] init];
        
        for (PFObject *result in results) {
            msg = [[ChatMessageVO alloc] init];
            msg = [ChatMessageVO readFromPFObject:result];
            [msgs addObject:msg];
            
            if (msg.user_key != nil) {
                if ([userKeys indexOfObject:msg.user_key] != NSNotFound) {
                    [userKeys addObject:msg.user_key];
                }
            }
        }
        __block ChatVO *chat = [[ChatVO alloc] init];
        chat.messages = msgs;
        PFQuery *query = [PFQuery queryWithClassName:kContactDB];
        [query whereKey:@"objectId" containedIn:[userKeys copy]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            NSMutableDictionary *contactMap = [[NSMutableDictionary alloc] initWithCapacity:results.count];
            ContactVO *contact;
            for (PFObject *result in results) {
                contact = [ContactVO readFromPFObject:result];
                [contactMap setObject:contact forKey:contact.system_id];
            }
            chat.contactMap = contactMap;
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"chatMessagesLoaded"
                                                                                                 object:chat]];
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
@end
