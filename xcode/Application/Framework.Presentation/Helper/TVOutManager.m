//
//  TVOutManager.m
//  Presentation Framework
//
//  Created by Rob Terrell (rob@touchcentric.com) on 8/16/10.
//  Copyright 2010 TouchCentric LLC. All rights reserved.
//
// http://www.touchcentric.com/blog/


#import <QuartzCore/QuartzCore.h>
#import "TVOutManager.h"
#import "UIAlertView+Helper.h"

#define kFPS 60
#define kUseBackgroundThread	NO

//
// Warning: once again, we can't use UIGetScreenImage for shipping apps (as of late July 2010)
// however, it gives a better result (shows the status bar, UIKit transitions, better fps) so 
// you may want to use it for non-app-store builds (i.e. private demo, trade show build, etc.)
// Just uncomment both lines below.
//
#define USE_UIGETSCREENIMAGE 
CGImageRef UIGetScreenImage();
//


@interface TVOutManager ()
- (void) screenDidConnectNotification: (NSNotification*) notification;
- (void) screenDidDisconnectNotification: (NSNotification*) notification;
- (void) screenModeDidChangeNotification: (NSNotification*) notification;
- (void) deviceOrientationDidChange: (NSNotification*) notification;

@property (nonatomic, strong) NSString *vcNibName;
@end
	

@implementation TVOutManager

@synthesize tvSafeMode;
@synthesize mirror = _mirror;
@synthesize projectorConnected = _projectorConnected;
@synthesize projectorIsMirror = _projectorIsMirror;
@synthesize supportsVideoMirror = _supportsVideoMirror;
@synthesize vcNibName = _vcNibName;

+ (TVOutManager *)sharedInstance
{
	static TVOutManager *sharedInstance;
	
	@synchronized(self)
	{
		if (!sharedInstance)
			sharedInstance = [[TVOutManager alloc] init];
		return sharedInstance;
	}
}


- (id) init
{
    self = [super init];
    if (self) {
		// can't imagine why, but just in case
		[[NSNotificationCenter defaultCenter] removeObserver: self];
		
		// catch screen-related notifications
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(screenDidConnectNotification:) name: UIScreenDidConnectNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(screenDidDisconnectNotification:) name: UIScreenDidDisconnectNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(screenModeDidChangeNotification:) name: UIScreenModeDidChangeNotification object: nil];

		// we don't care to catch orientation changes in this app
		
		// catch orientation notifications
//		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];		
    }
    return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (UIWindow*) startTVOutAllowMirror:(BOOL)allowMirror {
	// you need to have a main window already open when you call start
	if ([[UIApplication sharedApplication] keyWindow] == nil) {
		return nil;
	}

	if (_tvoutWindow) {
		// tvoutWindow already exists, so this is a re-connected cable, or a mode chane
		[self stopTVOut];
	}
		
	NSArray *screens = [UIScreen screens];
	if ([screens count] <= 1) {
		NSLog(@"TVOutManager: startTVOut failed (no external screens detected)");
		return nil;	
	}
	
	_allowVideoMirror = allowMirror;
	_projectorIsMirror = NO;
	// check for mirror screen
	for (UIScreen *aScreen in screens) {
		if ([aScreen respondsToSelector:@selector(mirroredScreen)] && [aScreen mirroredScreen] == [UIScreen mainScreen]) {
			_supportsVideoMirror = YES;
			if (_allowVideoMirror) {
				_projectorIsMirror = YES;
				NSLog(@"TVOutManager: startTVOut aborting (automatic mirroring enabled)");
				return nil;
			}
		}
	}
	
	CGSize max = { 0, 0 };
	UIScreenMode *maxScreenMode = nil;
	UIScreen *external = [[UIScreen screens] objectAtIndex: 1];
	for(int i = 0; i < [[external availableModes] count]; i++)
	{
		UIScreenMode *current = [[[[UIScreen screens] objectAtIndex:1] availableModes] objectAtIndex: i];
		if (current.size.width > max.width)
		{
			max = current.size;
			maxScreenMode = current;
		}
	}
	external.currentMode = maxScreenMode;
	
	_tvoutWindow = [[UIWindow alloc] initWithFrame: CGRectMake(0,0, max.width, max.height)];
	_tvoutWindow.userInteractionEnabled = NO;
	_tvoutWindow.screen = external;
	
	[_tvoutWindow makeKeyAndVisible];
	return _tvoutWindow;
}

- (UIViewController*) startTVOutWithVCClass:(Class)vcClass vcNibName:(NSString*)nibName allowVideoMirror:(BOOL)allowMirror
{
	[self startTVOutAllowMirror:allowMirror];
	_vcClass = vcClass;
	self.vcNibName = nibName;		
	
	if (_tvoutWindow) {
		_projectorConnected = YES;

		if (!_mirror) {
			id mirror = [[vcClass alloc] initWithNibName:nibName bundle:nil];
            self.mirror = mirror;
		}

		[_tvoutWindow addSubview:_mirror.view];
		_mirror.view.center = _tvoutWindow.center;
		_mirror.view.clipsToBounds = YES;
		
		// this could be expanded to handle other orientations
//		UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
		UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
		float scale = MIN(_tvoutWindow.frame.size.height / mainWindow.frame.size.height,
						  _tvoutWindow.frame.size.width / mainWindow.frame.size.width);
		_mirror.view.transform = CGAffineTransformScale(_mirror.view.transform, scale, scale);

//		NSString *message = [NSString stringWithFormat:@"mainWindow: %@, tvoutWindow: %@ scale: %.2f", [mainWindow description], [_tvoutWindow description], scale];
//		UIAlertViewQuick(@"TVOut", message, @"OK");
		
		return _mirror;
	}
	
	return nil;
}

- (void) stopTVOut;
{
	_done = YES;
    _projectorConnected = NO;

	if (_tvoutWindow) {
		_tvoutWindow = nil;
		_mirror = nil;
	}
}

-(void) screenDidConnectNotification: (NSNotification*) notification
{
	[self startTVOutWithVCClass:_vcClass vcNibName:_vcNibName allowVideoMirror:_allowVideoMirror];
}

-(void) screenModeDidChangeNotification: (NSNotification*) notification
{
	[self startTVOutWithVCClass:_vcClass vcNibName:_vcNibName allowVideoMirror:_allowVideoMirror];
}

-(void) screenDidDisconnectNotification: (NSNotification*) notification
{
	[self stopTVOut];
}

-(void) deviceOrientationDidChange: (NSNotification*) notification
{
	if (_mirror == nil || _done == YES) {
		return;	
	}
	
	if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
		[UIView beginAnimations:@"turnLeft" context:nil];
		_mirror.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 1.5);			
		[UIView commitAnimations];
	} else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
		[UIView beginAnimations:@"turnRight" context:nil];
		_mirror.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * -1.5);
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"turnUp" context:nil];
		_mirror.view.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
	}	
}


-(void) setTvSafeMode:(BOOL) val
{
	if (_tvoutWindow) {
		if (_tvSafeMode == YES && val == NO) {
			[UIView beginAnimations:@"zoomIn" context: nil];
			_tvoutWindow.transform = CGAffineTransformScale(_tvoutWindow.transform, 1.25, 1.25);
			[UIView commitAnimations];
			[_tvoutWindow setNeedsDisplay];
		}
		else if (_tvSafeMode == NO && val == YES) {
			[UIView beginAnimations:@"zoomOut" context: nil];
			_tvoutWindow.transform = CGAffineTransformScale(_tvoutWindow.transform, .8, .8);
			[UIView commitAnimations];			
			[_tvoutWindow setNeedsDisplay];
		}
	}
	_tvSafeMode = val;
}

@end
