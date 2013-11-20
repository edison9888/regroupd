//
//  ChatManager.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>
#import "ChatVO.h"
#import "ChatMessageVO.h"

@interface ChatManager : NSObject

- (ChatVO *) loadChat:(int)_chatId;
- (ChatVO *) loadChat:(int)_chatId fetchAll:(BOOL)all;
- (int) saveChat:(ChatVO *) chat;
- (void) deleteChat:(ChatVO *)chat;
- (void) updateChat:(ChatVO *)chat;
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
- (void) apiListChats:(NSString *)userId callback:(void (^)(NSArray *results))callback;
- (void) apiSaveChat:(ChatVO *)chat callback:(void (^)(PFObject *object))callback;

- (void) apiFindChatsByContactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *results))callback;

- (void) apiSaveChatMessage:(ChatMessageVO *)msg callback:(void (^)(PFObject *object))callback;
- (void)apiSaveChatMessage:(ChatMessageVO *)msg withPhoto:(UIImage *)saveImage callback:(void (^)(PFObject *object))callback;
// Syncrhonous API functions
- (ChatVO *) apiLoadChat:(NSString *)objectId;
- (ChatVO *) apiLoadChat:(NSString *)objectId fetchAll:(BOOL)all;
- (NSString *) apiSaveChat:(ChatVO *) chat;

- (NSMutableArray *) asyncListChatMessages:(NSString *)objectId;
- (NSMutableArray *) asyncListChatContacts:(NSArray *)objectIds;

// ChatForm API
- (void) apiSaveChatForm:(NSString *)chatId formId:(NSString *)formId callback:(void (^)(PFObject *object))callback;
- (void) apiListChatForms:(NSString *)chatId callback:(void (^)(NSArray *results))callback;
@end
