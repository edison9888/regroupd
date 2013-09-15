//
//  Spin360Component.m
//  Presentation
//
//

#import "Spin360Component.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+InvocationHelper.h"

#define kPixelsToImages		0.2

@interface Spin360Component ()

- (void)setImageIndex:(NSInteger)index;
- (void)setImageIndexNumber:(NSNumber *)indexNumber;

@end

@implementation Spin360Component
@synthesize imageView = _imageView;
@synthesize imageNameFormatString = _imageNameFormatString;
@synthesize iCurrentFrame = _iCurrentFrame;
@synthesize nFrames  =_nFrames;
@synthesize iFirstFrame = _iFirstFrame;

- (void)setImageIndexNumber:(NSNumber *)indexNumber
{
    [self setImageIndex:(NSInteger)[indexNumber intValue]];
}

- (void)setImageIndex:(NSInteger)index
{
    NSNumber *indexNumber = [NSNumber numberWithInt:index];
    NSInvocation *spinInvocation = [self invocationWithSelector:@selector(setImageIndexNumber:) object:indexNumber];
    [self sendMirrorNotification:spinInvocation];
    
	while (index < 0) {
		index += _nFrames;
	}
	while (index > _nFrames - 1) {
		index -= _nFrames;
	}
	if (_iCurrentFrame == index) {
		return;
	}
	
	NSString *imageName = [NSString stringWithFormat:_imageNameFormatString, index + _iFirstFrame];
	imageName = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:imageName];
	_imageView.image = image;
	_iCurrentFrame = index;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)setnFrames:(NSInteger)nFrames
{
	_nFrames = nFrames;
    _iCurrentFrame = -1;
	if (nFrames > 0 && _imageNameFormatString) {
		[self setImageIndex:0];
	}
}

- (void)setiFirstFrame:(NSInteger)iFirstFrame
{
	_iFirstFrame = iFirstFrame;
    _iCurrentFrame = -1;
	if (_nFrames > 0 && _imageNameFormatString) {
		[self setImageIndex:0];
	}
}

- (void)dealloc
{
	[self stopFrameUpdates];	
	
}


- (void)onPanGesture:(UIPanGestureRecognizer*)recognizer {    
    NSInvocation *panInvocation = [self invocationWithSelector:@selector(onPanGesture:) object:recognizer];
    [self sendMirrorNotification:panInvocation];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self stopFrameUpdates];	
		_velocity = 0;
		_iFrameAtTouch = _iCurrentFrame;
		[super startComponent];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
		_offset = [recognizer translationInView:self].x;
		NSInteger newIndex = (int)(_iFrameAtTouch + _offset * kPixelsToImages);
		[self setImageIndex:newIndex];
	}
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
		_velocity = [recognizer velocityInView:self].x * (1.0 / 30);
        [self startFrameUpdates];	
	}
}

- (void)updateAnimation:(CADisplayLink*)displayLink
{
    if (_autoSpinStartDate) {
        CGFloat uSpin = [[NSDate date] timeIntervalSinceDate:_autoSpinStartDate] / ((float)abs(_autoSpinNFrames) / _nFrames * 2);
        if (uSpin > 1) {
            uSpin = 1;
            _autoSpinStartDate = nil;
            [self stopFrameUpdates];	
            [super stopComponent];
        }   
        uSpin = (1 + cos(M_PI + M_PI * uSpin)) / 2;
        NSInteger newIndex = _autoSpinStartFrame + uSpin * _autoSpinNFrames;
        [self setImageIndex:newIndex];
        return;
    }
    
	_offset += _velocity;
	_velocity *= 0.85;
	NSInteger newIndex = (int)(_iFrameAtTouch + _offset * kPixelsToImages);
	[self setImageIndex:newIndex];
    
	if (fabs(_velocity) < 1.0) {
		_velocity = 0;
        [self stopFrameUpdates];	
		[super stopComponent];
	}
}

- (void)autoSpinToIndex:(NSInteger)frame
{
    _autoSpinStartFrame = _iCurrentFrame;
    frame = frame % _nFrames;
    _autoSpinNFrames = frame - _iCurrentFrame;
    if (fabs(_autoSpinNFrames) > _nFrames / 2) {
        if (_autoSpinNFrames > 0) {
            _autoSpinNFrames = _autoSpinNFrames - _nFrames;
        } else {
            _autoSpinNFrames = _nFrames + _autoSpinNFrames;
        }
    }
    
    if (_autoSpinNFrames) {
        _autoSpinStartDate = [NSDate date];
        if (_displayLink) {
            _velocity = 0;
        } else {
            [self startFrameUpdates];	
			[super startComponent];
        }
    }
}

@end
