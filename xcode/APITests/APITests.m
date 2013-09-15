//
//  APITests.m
//  APITests
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import "APITests.h"
#import "File.h"
#import "GDataXMLNode.h"
#import "QSUtilities.h"

@implementation APITests

static NSString *acctUsername = @"sanjeevd";
static NSString *acctPassword = @"sanjeevd";

static NSString *acctId = @"8555465470";
static NSString *apiUrl = @"https://secure.efaxdeveloper.com/EFax_WebFax.serv";

static NSString *params = @"id=%@&xml=%@&respond=XML";

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReadXML
{
    NSString *xml = @"<?xml version=\"1.0\"?><OutboundResponse><Transmission><TransmissionControl><TransmissionID>1000</TransmissionID><DOCID>82723108</DOCID></TransmissionControl><Response><StatusCode>1</StatusCode><StatusDescription>Success</StatusDescription></Response></Transmission></OutboundResponse>";
    
    NSData *xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
 
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    //NSLog(@"%@", doc.rootElement); // print the whole xml
    NSString *text;
    
    GDataXMLElement* statusValueEl = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/Response/StatusDescription" error:nil] objectAtIndex:0];
    text = statusValueEl.stringValue;
    NSLog(@"value = %@", text);
    
    GDataXMLElement* docIdXml = (GDataXMLElement*)[[doc nodesForXPath:@"//Transmission/TransmissionControl/DOCID" error:nil] objectAtIndex:0];
    text = docIdXml.stringValue;
    NSLog(@"docId = %@", text);
    
//    text = [statusValueEl valueForKey:<#(NSString *)#>]
    /*
     <?xml version="1.0"?>
     <OutboundResponse>
        <Transmission>
            <TransmissionControl>
                <TransmissionID>1000</TransmissionID>
                <DOCID>82723108</DOCID>
            </TransmissionControl>
            <Response>
                 <StatusCode>1</StatusCode>
                 <StatusDescription>Success</StatusDescription>
             </Response>
        </Transmission>
     </OutboundResponse>

     */

}
- (void)XtestSendFax
{
    NSString *filepath = @"/Sandbox/APPMOB/appmob-e-attending/xcode/NView/Resources/Images/fax_template_hires.png";
    
    UIImage *image = [UIImage imageWithContentsOfFile:filepath];
    NSString *encoded = nil;
    if (!image) {
        NSLog(@"Image not found: %@", filepath);
    } else {
        NSData* data = UIImagePNGRepresentation(image);
        encoded = [QSStrings encodeBase64WithData:data];
    }
    
    OutboundRequest *outboundRequest = [[OutboundRequest alloc] init];
    
    outboundRequest.faxHeader = @"@DATE1 @TIME3 @ROUTETO{26} @RCVRFAX Pg%P/@TPAGES";
    outboundRequest.dispositionEmail = @"hughlang@gmail.com";
    outboundRequest.dispositionName = @"Hugh";
    outboundRequest.recipientName = @"--HiRes Test--";
    outboundRequest.recipientFax = @"1-855-546-5470";
    outboundRequest.recipientCompany = @"2013";
    
    File *file = [[File alloc] init];
    file.fileType = @"png";
    file.fileContents = encoded;
    outboundRequest.file = file;

    NSString *xml = [self buildXml:outboundRequest];
    
    
    NSURL *URL = [NSURL URLWithString:apiUrl];
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[URL standardizedURL]];

    
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setURL:URL];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
//    NSMutableDictionary *postdata = [[NSMutableDictionary alloc] init];
//    [postdata setValue:acctId forKey:@"id"];
//    [postdata setValue:xml forKey:@"xml"];
//    [postdata setValue:@"XML" forKey:@"respond"];
//    [request setHTTPBody:];
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
//    request.HTTPMethod = @"POST";
//    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
//    [request setHTTPBody:[writer dataWithObject:postdata]];
    
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
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"returnString %@", returnString);
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"response %@", [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]);
        
    }
    
    NSLog(@"Keep alive");
    sleep(20);
    
/*  NOT FOR UNIT TEST */
//    //initialize a connection from request
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    self.connection = connection;
//    
//    //start the connection
//    [connection start];
    
    
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

#pragma mark - NSURLConnection delegate

/*
this method might be calling more than one times according to incoming data size
*/
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}
/*
 if there is an error occured, this method will be called by connection
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@" , error);
}

/*
 if data is successfully received, this method will be called by connection
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //initialize convert the received data to string with UTF8 encoding
    NSString *xml = [[NSString alloc] initWithData:self.receivedData
                                              encoding:NSUTF8StringEncoding];
    NSLog(@"%@" , xml);
    
    
}
@end
