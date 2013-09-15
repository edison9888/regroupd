//
//  APITests.h
//  APITests
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "OutboundRequest.h"

@interface APITests : SenTestCase<NSURLConnectionDelegate>

@property (nonatomic,retain) NSMutableData *connectionData;
@property (nonatomic,retain) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;

- (NSString *) buildXml:(OutboundRequest *)request;

@end
