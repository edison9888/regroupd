//
//  AnimationModel.m
//  PresentationExample
//
//

#import "AnimationModel.h"


@implementation AnimationModel
@synthesize duration = _duration;
@synthesize delay = _delay;
@synthesize hold = _hold;
@synthesize options = _options;

@synthesize execute = _execute;
@synthesize complete = _complete;

- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options
{
	return [self initWithDuration:duration delay:delay options:options hold:-1.0];
}


- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options hold:(NSTimeInterval)hold
{
	if ((self = [super init])) {
		_duration = duration;
		_delay = delay;
		_hold = hold;
		_options = options;
	}
	
	return self;
}


+ (AnimationModel*)animationModelWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
									  options:(UIViewAnimationOptions)options
{
	AnimationModel *animModel = [[AnimationModel alloc] initWithDuration:duration delay:delay options:options];
	return animModel;
}

+ (AnimationModel*)animationModelWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
									  options:(UIViewAnimationOptions)options 
										 hold:(NSTimeInterval)hold
{
	AnimationModel *animModel = [[AnimationModel alloc] initWithDuration:duration delay:delay options:options hold:hold];
	return animModel;
}


@end
