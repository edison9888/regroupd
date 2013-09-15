//
//  TraccsWebService.m
//  Blocpad
//
//  Created by Hugh Lang on 4/16/13.
//
//

#import "EFaxService.h"
#import "OutboundRequest.h"

@implementation EFaxService

static NSString *acctUsername = @"sanjeevd";
static NSString *acctPassword = @"sanjeevd";

static NSString *acctId = @"8555465470";
static NSString *apiUrl = @"https://secure.efaxdeveloper.com/EFax_WebFax.serv";

static NSString *params = @"id=%@&xml=%@&respond=XML";

- (id)init
{
    self = [super init];
    return self;
}

-(NSData *)callWebService:(OutboundRequest *)outboundRequest
{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *xml = [self buildXml:outboundRequest];
    
    
    NSURL *URL = [NSURL URLWithString:apiUrl];
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[URL standardizedURL]];
    
    
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setURL:URL];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    xml = [QSStrings urlEncode:xml usingEncoding:NSUTF8StringEncoding];
    
    NSString *postData = [NSString stringWithFormat:params, acctId, xml];
    
    NSLog(@"length = %i", postData.length);
    
    //    NSLog(@"postData = %@", postData);
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Read to post #############################
    NSHTTPURLResponse *response;
    NSError *error;
    NSLog(@"Ready to POST");
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseXml = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"responseXml %@", responseXml);
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {        
        NSData *xmlData = [responseXml dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:&error];
        NSString *text;
        
        GDataXMLElement* statusValue = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/Response/StatusDescription" error:nil] objectAtIndex:0];
        text = statusValue.stringValue;
        
        NSLog(@"value = %@", text);
        
        if ([text caseInsensitiveCompare:@"Success"] == NSOrderedSame) {
            GDataXMLElement* docIdXml = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/TransmissionControl/DOCID" error:nil] objectAtIndex:0];
            text = docIdXml.stringValue;
            NSLog(@"docId = %@", text);
            
            // TODO: post notification with docID?
            NSNotification* faxSuccessNotification = [NSNotification notificationWithName:@"faxSuccessNotification" object:text];
            [[NSNotificationCenter defaultCenter] postNotification:faxSuccessNotification];
            return nil;
            
        } else {
            @try {
                GDataXMLElement* errorMsg = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/Response/ErrorMessage" error:nil] objectAtIndex:0];
                
                NSLog(@"Error: %@", errorMsg.stringValue);
                
                NSNotification* faxFailureNotification = [NSNotification notificationWithName:@"faxFailureNotification" object:errorMsg.stringValue];
                [[NSNotificationCenter defaultCenter] postNotification:faxFailureNotification];
                return nil;
            }
            @catch (NSException *exception) {
                NSLog(@"Failed again with exception %@", exception);
            }
        }
        
    }
        
    return nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__);
	[responseData setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%s", __FUNCTION__);
    
    
    NSString *xml = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"xml=%@", xml);
    
    NSData *xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    NSString *text;
    
    GDataXMLElement* statusValue = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/Response/StatusDescription" error:nil] objectAtIndex:0];
    text = statusValue.stringValue;
    
    NSLog(@"value = %@", text);
    
    if ([text caseInsensitiveCompare:@"Success"] == NSOrderedSame) {
        GDataXMLElement* docIdXml = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/TransmissionControl/DOCID" error:nil] objectAtIndex:0];
        text = docIdXml.stringValue;
        NSLog(@"docId = %@", text);
        
        // TODO: post notification with docID?
        NSNotification* faxSuccessNotification = [NSNotification notificationWithName:@"faxSuccessNotification" object:text];
        [[NSNotificationCenter defaultCenter] postNotification:faxSuccessNotification];

        
    } else {
        @try {
            GDataXMLElement* errorMsg = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/Response/ErrorMessage" error:nil] objectAtIndex:0];

            NSLog(@"Error: %@", errorMsg.stringValue);
            
            NSNotification* faxFailureNotification = [NSNotification notificationWithName:@"faxFailureNotification" object:errorMsg.stringValue];
            [[NSNotificationCenter defaultCenter] postNotification:faxFailureNotification];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Failed again with exception %@", exception);
        }
    }
    
}

- (NSString *) buildXml:(OutboundRequest *)request {
    GDataXMLElement *textElement = nil;
    GDataXMLElement *container = nil;
    
    GDataXMLElement *outboundRequest = [GDataXMLNode elementWithName:@"OutboundRequest"];
    GDataXMLElement *accessControl = [GDataXMLNode elementWithName:@"AccessControl"];
    
    textElement = [GDataXMLNode elementWithName:@"UserName" stringValue:acctUsername];
    [accessControl addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"Password" stringValue:acctPassword];
    [accessControl addChild:textElement];
    
    [outboundRequest addChild:accessControl];
    
    GDataXMLElement *transmission = [GDataXMLNode elementWithName:@"Transmission"];
    
    container = [GDataXMLNode elementWithName:@"TransmissionControl"];
    textElement = [GDataXMLNode elementWithName:@"TransmissionID" stringValue:@"1000"];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"Resolution" stringValue:@"FINE"];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"Priority" stringValue:@"NORMAL"];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"SelfBusy" stringValue:@"ENABLE"];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"FaxHeader" stringValue:request.faxHeader];
    [container addChild:textElement];
    
    [transmission addChild:container];
    
    GDataXMLElement *dispositionControl = [GDataXMLNode elementWithName:@"DispositionControl"];
    
    textElement = [GDataXMLNode elementWithName:@"DispositionLevel" stringValue:@"BOTH"];
    [dispositionControl addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"DispositionMethod" stringValue:@"EMAIL"];
    [dispositionControl addChild:textElement];
    
    GDataXMLElement *dispositionEmails = [GDataXMLNode elementWithName:@"DispositionEmails"];
    
    // foreach email recipient
    container = [GDataXMLNode elementWithName:@"DispositionEmail"];
    textElement = [GDataXMLNode elementWithName:@"DispositionRecipient" stringValue:request.dispositionName];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"DispositionAddress" stringValue:request.dispositionEmail];
    [container addChild:textElement];
    
    [dispositionEmails addChild:container];
    [dispositionControl addChild:dispositionEmails];
    [transmission addChild:dispositionControl];
    
    
    GDataXMLElement *recipients = [GDataXMLNode elementWithName:@"Recipients"];
    
    container = [GDataXMLNode elementWithName:@"Recipient"];
    textElement = [GDataXMLNode elementWithName:@"RecipientName" stringValue:request.recipientName];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"RecipientCompany" stringValue:request.recipientCompany];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"RecipientFax" stringValue:request.recipientFax];
    [container addChild:textElement];
    
    [recipients addChild:container];
    [transmission addChild:recipients];
    
    
    GDataXMLElement *files = [GDataXMLNode elementWithName:@"Files"];
    
    container = [GDataXMLNode elementWithName:@"File"];
    textElement = [GDataXMLNode elementWithName:@"FileContents" stringValue:request.file.fileContents];
    [container addChild:textElement];
    textElement = [GDataXMLNode elementWithName:@"FileType" stringValue:request.file.fileType];
    [container addChild:textElement];
    
    [files addChild:container];
    [transmission addChild:files];
    
    [outboundRequest addChild:transmission];
    
    
    // AND FINALLY
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:outboundRequest];
    NSData *xmlData = document.XMLData;
    NSString *outxml = [[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding];
    
    return outxml;
    
}



@end
