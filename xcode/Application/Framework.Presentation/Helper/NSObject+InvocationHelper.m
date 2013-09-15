//
//  NSObject+InvocationHelper.m
//  Presentation Framework
//
//

#import "NSObject+InvocationHelper.h"


@implementation NSObject (NSObject_InvocationHelper)

- (NSInvocation*) invocationWithSelector:(SEL)selector object:(NSObject*)object
{
	NSArray *array = object ? [NSArray arrayWithObject:object] : nil;
	return [self invocationWithSelector:selector objects:array];
}

- (NSInvocation*) invocationWithSelector:(SEL)selector objects:(NSArray*)objects 
{
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
	for (int i = 0; i < objects.count; i++) {
		__unsafe_unretained NSObject *object = [objects objectAtIndex:i];
		[invocation setArgument:&object atIndex:i + 2];
	}

    return invocation;
}

- (NSInvocation*) invocationWithSelector:(SEL)selector primitive:(void*)object
{
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
	[invocation setArgument:object atIndex:2];
	
    return invocation;
}


@end
