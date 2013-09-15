//
//  HelpCopy.h
//  Blocpad
//
//  Created by Hugh Lang on 4/9/13.
//
//

#import <Foundation/Foundation.h>

@interface HelpCopy : NSObject {
    NSString *key;
    NSString *title;
    NSString *description;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;

- (id)initWithKey:(NSString *)_key title:(NSString *)_title desc:(NSString *)_desc;

@end
