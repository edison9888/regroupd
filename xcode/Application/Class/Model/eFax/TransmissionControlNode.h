//
//  TransmissionControl.h
//  eAttending
//
//  Created by Hugh Lang on 7/17/13.
//
//

#import <Foundation/Foundation.h>

@interface TransmissionControlNode : NSObject {

    @protected
    NSString *TransmissionID;
    NSString *Resolution;
    NSString *Priority;
    NSString *SelfBusy;
    NSString *FaxHeader;
}

@property (nonatomic, copy) NSString *TransmissionID;
@property (nonatomic, copy) NSString *Resolution;
@property (nonatomic, copy) NSString *Priority;
@property (nonatomic, copy) NSString *SelfBusy;
@property (nonatomic, copy) NSString *FaxHeader;

//<TransmissionID>1000</TransmissionID>
//<Resolution>STANDARD</Resolution>
//<Priority>NORMAL</Priority>
//<SelfBusy>ENABLE</SelfBusy>
//<FaxHeader>"@DATE1 @TIME3 @ROUTETO{26} @RCVRFAX Pg%P/@TPAGES"</FaxHeader>

@end
