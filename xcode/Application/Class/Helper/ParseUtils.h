//
//  ParseUtils.h
//  Re:group'd
//
//  Created by Hugh Lang on 11/16/13.
//
//

#import <Foundation/Foundation.h>

@interface ParseUtils : NSObject

+ (NSMutableDictionary *) readFormOptionDictFromPFObject:(PFObject *)data;

@end
