//
//  Page.m
//  Regroupd
//
//  Created by Hugh Lang on 9/28/13.
//
//

#import "Page.h"

@implementation Page

- (id) init {
    
	if(self = [super init]) {
		self.params = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSString *) getParam: (NSString*) key {
	return [self.params objectForKey: key];
}
@end
