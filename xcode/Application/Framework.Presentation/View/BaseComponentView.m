//
//  BaseComponentView.m
//  Presentation Framework
//
//

#import "BaseComponentView.h"
#import "PresentationNotifications.h"

#define kProjectorPrefix @"__kProjector"

@implementation BaseComponentView
@synthesize componentData = _componentData;
@synthesize dateStarted = _dateStarted;
@synthesize frameInterval = _frameInterval;
@synthesize delegate = _delegate;
@synthesize breadCrumb = _breadCrumb;
@synthesize isMirror = _isMirror;

- (id)initWithFrame:(CGRect)frame andComponentData:(NSDictionary*)componentData
{
    if ((self = [self initWithFrame:frame])) {
        self.componentData = [NSMutableDictionary dictionaryWithDictionary:componentData];
    }
    return self;
}

- (void)setComponentData:(NSMutableDictionary *)componentData
{
	if (componentData == _componentData) {
		return;
	}
	_componentData = componentData;
    
	_frameInterval = [[componentData objectForKey:@"frameInterval"] intValue];
    [self resetComponent];
}

- (void)startComponent
{
    if ([_delegate respondsToSelector:@selector(componentStarted:)]) {
		[_delegate performSelector:@selector(componentStarted:) withObject:self];
	}
}

- (void)stopComponent
{
    if ([_delegate respondsToSelector:@selector(componentStopped:)]) {
		[_delegate performSelector:@selector(componentStopped:) withObject:self];
	}
}

- (void)resetComponent
{
}

- (void)startFrameUpdates
{
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameUpdate:)];
	_displayLink.frameInterval = _frameInterval ? _frameInterval : 1;
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	_dateStarted = [NSDate date];
}

- (void)stopFrameUpdates
{
	[_displayLink invalidate];
	_displayLink = nil;
	
	_dateStarted = nil;
}

- (void)frameUpdate:(CADisplayLink*)displayLink
{
	NSLog(@"Abstract component frameUpdate - should not be called");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
	[self stopFrameUpdates];
	[self stopComponent];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Procedural Mirroring

- (void)setIsMirror:(BOOL)isMirror {
	if (isMirror == _isMirror) {
		return;
	}
	
	NSString *notificationName = [kPresentationMirrorNotificationPrefix stringByAppendingString:_breadCrumb];
	if (isMirror) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMirrorNotification:) name:notificationName object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
	}
}

- (void)sendMirrorNotification:(NSInvocation *)invocation
{
	NSString *notificationName = [kPresentationMirrorNotificationPrefix stringByAppendingString:_breadCrumb];
    if ([[TVOutManager sharedInstance] projectorConnected] && !_isMirror) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:invocation, @"invocation", _breadCrumb, @"breadCrumb", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
    }
}

- (void)handleMirrorNotification:(NSNotification *)note
{
    NSDictionary *noteDict = [note userInfo];
	//	if ([_breadCrumb isEqual:[noteDict objectForKey:@"breadCrumb"]]) {
	NSInvocation *invocation = [noteDict objectForKey:@"invocation"];
	[invocation invokeWithTarget:self];
	//	}
}


@end
