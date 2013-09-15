//
//  AnimationModel.h
//  PresentationExample
//
//

#import <Foundation/Foundation.h>


@interface AnimationModel : NSObject {
	NSTimeInterval			_duration;
	NSTimeInterval			_delay;
	NSTimeInterval			_hold;
	UIViewAnimationOptions	_options;
	
	void					(^_execute)(void);
	void					(^_complete)(BOOL finished);
}

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval hold;
@property (nonatomic, assign) UIViewAnimationOptions options;
@property (nonatomic, copy) void (^execute)(void);
@property (nonatomic, copy) void (^complete)(BOOL finished);

- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options;
- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options 
				  hold:(NSTimeInterval)hold;

+ (AnimationModel*)animationModelWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
									  options:(UIViewAnimationOptions)options;
+ (AnimationModel*)animationModelWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
									  options:(UIViewAnimationOptions)options 
										 hold:(NSTimeInterval)hold;
@end
