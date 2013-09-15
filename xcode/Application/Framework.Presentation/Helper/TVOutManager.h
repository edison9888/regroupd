//
//  TVOutManager.h
//  Presentation Framework
//
//  Created by Rob Terrell (rob@touchcentric.com) on 8/16/10.
//  Copyright 2010 TouchCentric LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+InvocationHelper.h"

#define kTVOutConnectionChangedNotification	@"__kTVOutConnectionChangedNotification"


@interface TVOutManager : NSObject {

	UIWindow			*_tvoutWindow;
	BOOL				_done;
	BOOL				_tvSafeMode;
	
	Class				_vcClass;
	NSString			*_vcNibName;
	BOOL				_allowVideoMirror;
    UIViewController	*_mirror;
	BOOL				_supportsVideoMirror;
    BOOL				_projectorConnected;
	BOOL				_projectorIsMirror;
}

@property (nonatomic, assign) BOOL tvSafeMode;
@property (strong) UIViewController *mirror;

@property (assign, readonly) BOOL supportsVideoMirror;
@property (assign, readonly) BOOL projectorConnected;
@property (assign, readonly) BOOL projectorIsMirror;

+ (TVOutManager *)sharedInstance;

- (UIViewController*) startTVOutWithVCClass:(Class)vcClass vcNibName:(NSString*)nibName allowVideoMirror:(BOOL)allowMirror;
- (UIWindow*) startTVOutAllowMirror:(BOOL)allowMirror;

- (void) stopTVOut;

@end
