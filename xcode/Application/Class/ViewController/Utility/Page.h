//
//  Page.h
//  Regroupd
//
//  Created by Hugh Lang on 9/28/13.
//
//

#import <Foundation/Foundation.h>

#define kPhotoWidth 320
#define kPhotoHeight 300

@interface Page : NSObject

@property (nonatomic, retain) NSString* view;
@property (nonatomic, retain) NSMutableDictionary* params;
@property (nonatomic) int index;
@property (nonatomic) int indexInChapter;

- (NSString *) getParam: (NSString*) key;

@end
