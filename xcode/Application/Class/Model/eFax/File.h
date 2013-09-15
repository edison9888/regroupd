//
//  File.h
//  eAttending
//
//  Created by Hugh Lang on 7/17/13.
//
//

#import <Foundation/Foundation.h>

@interface File : NSObject {
    NSString *fileType;
    NSString *fileContents;
}

@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *fileContents;


@end
