//
//  BaseComponentView.h
//  Presentation Framework
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TVOutManager.h"

@class BaseComponentView;

@protocol BaseComponentViewDelegate <NSObject>
@optional
- (void)componentStarted:(BaseComponentView*)component;
- (void)componentStopped:(BaseComponentView*)component;
@end

@interface BaseComponentView : UIView {
    NSMutableDictionary		*_componentData;
	id<BaseComponentViewDelegate> __weak _delegate;
	
@protected
	// frame animation
	CADisplayLink			*_displayLink;
	NSDate					*_dateStarted;
	NSInteger				_frameInterval;	
	
    // Programmatic display mirroring
	NSString				*_breadCrumb;
    BOOL                    _isMirror;
}

@property (nonatomic, strong) NSMutableDictionary *componentData;
@property (nonatomic, readonly) NSDate *dateStarted;
@property (nonatomic, weak) id<BaseComponentViewDelegate> delegate;
@property (nonatomic, strong) NSString *breadCrumb;
@property (nonatomic, assign) BOOL isMirror;

/*
 * for framewise animations: interval of native framerate (1 = every frame)
 */
@property (nonatomic, assign) NSInteger frameInterval;


- (id)initWithFrame:(CGRect)frame andComponentData:(NSDictionary*)componentData;
- (void)startComponent;
- (void)stopComponent;
- (void)resetComponent;

/*
 * called by framework only
 */
- (void)sendMirrorNotification:(NSInvocation *)invocation;

/*
 * called by framework only
 */
- (void)handleMirrorNotification:(NSNotification *)note;

/*
 * called by subclass implementations only
 */
- (void)startFrameUpdates;

/*
 * called by subclass implementations only
 */
- (void)stopFrameUpdates;


@end
