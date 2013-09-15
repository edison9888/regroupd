//
//  HelpModel.h
//  Blocpad
//
//  Created by Hugh Lang on 4/9/13.
//
//

#import <Foundation/Foundation.h>

@interface HelpModel : NSObject {
    NSMutableDictionary *helpDB;
}

@property (nonatomic, retain) NSMutableDictionary *helpDB;

- (void) load;

@end
