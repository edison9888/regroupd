//
//  TraccsWebService.h
//  Blocpad
//
//  Created by Hugh Lang on 4/16/13.
//
//

#import <Foundation/Foundation.h>

#import "OutboundRequest.h"
#import "File.h"
#import "GDataXMLNode.h"
#import "QSUtilities.h"

@interface EFaxService : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *responseData;
    NSURLConnection  *_connection;
    NSString *username;
    NSString *password;
}

-(NSData *)callWebService:(OutboundRequest *)outboundRequest;

@end


