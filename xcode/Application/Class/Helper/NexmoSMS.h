//
//  NexmoSMS.h
//  Regroupd
//
//  Created by Hugh Lang on 12/21/13.
//
//

#import <Foundation/Foundation.h>

@interface NexmoSMS : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *responseData;
    NSURLConnection  *_connection;
}

-(void)sendAuthMessageTo:(NSString *)toPhone pin:(NSString *)pin callback:(void (^)(NSString *result))callback;

-(void)sendTextMessageTo:(NSString *)toPhone from:(NSString *)senderId message:(NSString *)text
                callback:(void (^)(NSString *response))callback;


@end
