//
//  NSObject+InvocationHelper.h
//  Presentation Framework
//
//

#import <Foundation/Foundation.h>


@interface NSObject (NSObject_InvocationHelper)

- (NSInvocation*) invocationWithSelector:(SEL)selector object:(NSObject*)object;
- (NSInvocation*) invocationWithSelector:(SEL)selector objects:(NSArray*)objects; 
- (NSInvocation*) invocationWithSelector:(SEL)selector primitive:(void*)object;

@end
