//
//  AccessControl.h
//  eAttending
//
//  Created by Hugh Lang on 7/17/13.
//
//

#import <Foundation/Foundation.h>

@interface AccessControlNode : NSObject {
    @protected
    NSString *UserName;
    NSString *Password;
}

@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, copy) NSString *Password;

@end
