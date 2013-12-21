//
//  ChatManager.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>
#import "ChatVO.h"
#import "ChatMessageVO.h"

@interface ChatManager : NSObject

- (ChatVO *) loadChatByKey:(NSString *)chatKey;
- (ChatVO *) loadChat:(int)_chatId;
- (ChatVO *) loadChat:(int)_chatId fetchAll:(BOOL)all;
- (int) saveChat:(ChatVO *) chat;
- (void) deleteChat:(ChatVO *)chat;
- (void) updateChat:(ChatVO *)chat;
- (void) updateChatStatus:(NSString *)chatKey name:(NSString *)name readtime:(NSNumber *)readtime;
- (void) updateClearTimestamp:(NSString *)chatKey cleartime:(NSNumber *)cleartime;
- (NSMutableArray *) listChats:(int)type;

- (ChatMessageVO *) loadChatMessage:(int)_msgId;
- (int) saveChatMessage:(ChatMessageVO *) msg;
- (void) deleteChatMessage:(ChatMessageVO *)msg;
- (void) updateChatMessage:(ChatMessageVO *)msg;
- (NSMutableArray *) listChatMessages:(int)type;

// System ID lookup
- (ChatVO *) findChatBySystemId:(NSString *)objectId;
- (ChatMessageVO *) findChatMessageBySystemId:(NSString *)objectId;

// API functions
- (void)apiLoadChat:(NSString *)objectId callback:(void (^)(ChatVO *chat))callback;
- (void) apiListChats:(NSString *)userId callback:(void (^)(NSArray *results))callback;
- (void) apiSaveChat:(ChatVO *)chat callback:(void (^)(PFObject *object))callback;
- (void) apiUpdateChatCounter:(NSString *)chatId;

- (void) apiFindChatsByContactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *results))callback;

- (void) apiSaveChatMessage:(ChatMessageVO *)msg callback:(void (^)(PFObject *object))callback;
- (void)apiSaveChatMessage:(ChatMessageVO *)msg withPhoto:(UIImage *)saveImage callback:(void (^)(PFObject *object))callback;

// Syncrhonous API functions
- (NSString *) apiSaveChat:(ChatVO *) chat;

- (void) apiListChatMessages:(NSString *)objectId afterDate:(NSDate *)date callback:(void (^)(NSArray *results))callback;
- (NSMutableArray *) asyncListChatMessages:(NSString *)objectId afterDate:(NSDate *)date;
- (NSMutableArray *) asyncListChatContacts:(NSArray *)objectIds;

// ChatForm API
- (void) apiSaveChatForm:(NSString *)chatId formId:(NSString *)formId callback:(void (^)(PFObject *object))callback;
- (void) apiListChatForms:(NSString *)chatId formKey:(NSString *)formId callback:(void (^)(NSArray *results))callback;
@end
