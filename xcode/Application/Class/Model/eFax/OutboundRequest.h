//
//  OutboundRequest.h
//  eAttending
//
//  Created by Hugh Lang on 7/17/13.
//
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface OutboundRequest : NSObject {
    
    NSString *faxHeader;
    
    NSString *recipientName;
    NSString *recipientCompany;
    NSString *recipientFax;

    NSString *dispositionName;
    NSString *dispositionEmail;

    File *file;
    
    NSMutableArray *fileArray;

}

@property (nonatomic, copy) NSString *faxHeader;
@property (nonatomic, copy) NSString *recipientName;
@property (nonatomic, copy) NSString *recipientCompany;
@property (nonatomic, copy) NSString *recipientFax;
@property (nonatomic, copy) NSString *dispositionName;
@property (nonatomic, copy) NSString *dispositionEmail;
@property (nonatomic, retain) File *file;

@property (nonatomic, retain) NSMutableArray *fileArray;


@end
