//
//  NexmoSMS.m
//  Regroupd
//
//  Created by Hugh Lang on 12/21/13.
//
//

#import "NexmoSMS.h"

#define kAuthShortCode @"31089"
#define kNexmoAccountKey @"4036d73f"
#define kNexmoAccountSecret @"fdfcb142"
#define kRestApiSendSMSUrl @"https://rest.nexmo.com/sms/json?api_key=%@&api_secret=%@&from=%@&to=%@&text=%@"
#define kTwoFactorAuthSMSUrl @"https://rest.nexmo.com/sc/us/2fa/json?api_key=%@&api_secret=%@&to=%@&pin=%@"

@implementation NexmoSMS

-(void)sendAuthMessageTo:(NSString *)toPhone pin:(NSString *)pin callback:(void (^)(NSString *result))callback
{
    NSLog(@"%s", __FUNCTION__);
    
    
    NSString *apiUrl = [NSString stringWithFormat:kTwoFactorAuthSMSUrl, kNexmoAccountKey, kNexmoAccountSecret, toPhone, pin];
    
    NSLog(@"Ready to send request %@", apiUrl);
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSURL *url=[NSURL URLWithString:apiUrl];//encoding:STRING_ENCODING_IN_THE_SERVER
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *result = [NSString stringWithUTF8String:[data bytes]];
    
    callback(result);
    
}

-(void)sendTextMessageTo:(NSString *)toPhone from:(NSString *)senderId message:(NSString *)text
                    callback:(void (^)(NSString *result))callback
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *apiUrl = [NSString stringWithFormat:kRestApiSendSMSUrl, kNexmoAccountKey, kNexmoAccountSecret, senderId, toPhone, text];
    
    NSLog(@"Ready to send request %@", apiUrl);
    NSHTTPURLResponse *response;
    NSError *error;

    NSURL *url=[NSURL URLWithString:apiUrl];//encoding:STRING_ENCODING_IN_THE_SERVER
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *result = [NSString stringWithUTF8String:[data bytes]];

    callback(result);
    
}




@end
