//
//  Rotate2DComponent.m
//  Incivek
//
//

#import "Rotate2DComponent.h"


@implementation Rotate2DComponent
@synthesize velocity = _velocity;
@synthesize rotateView = _rotateView;
@synthesize velocityDampen = _velocityDampen;

#pragma mark BaseViewController overrides

- (void)setComponentData:(NSMutableDictionary *)componentData
{
	[super setComponentData:componentData];
    
	_velocity = [[componentData objectForKey:@"velocity"] floatValue];
	_velocityDampen = [[componentData objectForKey:@"velocityDampen"] floatValue];
    NSNumber *frameInterval = [componentData objectForKey:@"frameInterval"];
    if (frameInterval) {
        _frameInterval = [frameInterval intValue];
    } else {
        _frameInterval = 1;
    }
    _orgVelocity = _velocity;
}

- (void)startComponent
{
    [super startComponent];
	[self startFrameUpdates];
}

- (void)stopComponent
{
    [super stopComponent];
	[self stopFrameUpdates];
}

- (void)resetComponent
{
    _velocity = _orgVelocity;
}

- (void)frameUpdate:(CADisplayLink*)displayLink
{
    NSDate *dateNow = [NSDate date];
	NSTimeInterval tDelta = [dateNow timeIntervalSinceDate:_dateStarted];
    _dateStarted = dateNow;
	
    _angle = fmod(_angle + tDelta * _velocity, 1.0);
	CGFloat angle = _angle * 2 * M_PI;
	_rotateView.transform = CGAffineTransformMakeRotation(angle);
    _velocity *= (1.0 - _velocityDampen);
}

@end
