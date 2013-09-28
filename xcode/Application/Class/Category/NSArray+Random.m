#import "NSArray+Random.h"
#include <stdlib.h>

@implementation NSArray (Random)

- (id)randomObject {
    int randomIndex = arc4random() % [self count];
	
    return [self objectAtIndex:randomIndex];
}

@end
