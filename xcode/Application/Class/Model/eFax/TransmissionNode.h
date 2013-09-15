//
//  Transmission.h
//  eAttending
//
//  Created by Hugh Lang on 7/17/13.
//
//

#import <Foundation/Foundation.h>
#import "TransmissionControlNode.h"
@interface TransmissionNode : NSObject {
    TransmissionControlNode *TransmissionControl;
}

@property (nonatomic, retain) TransmissionControlNode *TransmissionControl;

@end
