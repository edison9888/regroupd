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

@end
