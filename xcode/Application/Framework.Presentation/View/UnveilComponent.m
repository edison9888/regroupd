//
//  UnveilComponent.m
//  Incivek
//
//

#import "UnveilComponent.h"
#import "EasingFilter.h"

@implementation UnveilComponent
@synthesize unveilView = _unveilView;
@synthesize maskImage = _maskImage;
@synthesize unveilFlags = _unveilFlags;
@synthesize softness = _softness;
@synthesize speed = _speed;

- (void)buildMask
{
	NSInteger unveilType = _unveilFlags & kUnveilComponentUnvealTypeMask;
	
	CGPoint startPoint, endPoint;
    CGSize maskSize = _unveilView.bounds.size;
	
	switch (unveilType) {
		case kUnveilComponentUnvealLeft:
			maskSize.width += _softness;
			startPoint = CGPointZero;
			endPoint = CGPointMake(_softness, 0);
			break;
		case kUnveilComponentUnvealRight:
			maskSize.width += _softness;
			startPoint = CGPointMake(maskSize.width, 0);
			endPoint = CGPointMake(maskSize.width - _softness, 0);
			break;
		case kUnveilComponentUnvealDown:
			maskSize.height += _softness;
			startPoint = CGPointZero;
			endPoint = CGPointMake(0, _softness);
			break;
		case kUnveilComponentUnvealUp:
			maskSize.height += _softness;
			startPoint = CGPointMake(0, maskSize.height);
			endPoint = CGPointMake(0, maskSize.height - _softness);
			break;
		case kUnveilComponentUnvealRadial:
		default: {
			CGFloat maskDim = MAX(maskSize.width, maskSize.height) + 2 * _softness;
			maskSize.width = maskSize.height = maskDim;
			startPoint = CGPointMake(maskSize.width / 2, maskSize.height / 2);
		}
	}
	
    if (UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(maskSize, YES, 0);
    } else {
        UIGraphicsBeginImageContext(maskSize);
    }
	
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
	
    CGColorRef startColor = [[UIColor colorWithWhite:0 alpha:1] CGColor];
    CGColorRef endColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
    
    const CGFloat *startComps, *endComps;
	
	if (unveilType == kUnveilComponentUnvealRadial) {
		startComps = CGColorGetComponents(endColor);
		endComps = CGColorGetComponents(startColor);
	} else {
		startComps = CGColorGetComponents(startColor);
		endComps = CGColorGetComponents(endColor);
    }
	
    CGFloat components[4] = { startComps[0], startComps[1],  // Start color
        endComps[0], endComps[1] }; // End color
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    CGColorSpaceRelease(colorSpace);
	
	if (unveilType == kUnveilComponentUnvealRadial) {
		CGFloat endRadius = maskSize.width / 2;
		CGContextDrawRadialGradient(c, gradient, startPoint, endRadius - _softness, startPoint, endRadius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);    
	} else {
		CGContextDrawLinearGradient(c, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
	}
    CGGradientRelease(gradient);
    
    _maskImage = UIGraphicsGetImageFromCurrentImageContext();
    //    NSData *data = UIImagePNGRepresentation(_maskImage);
    
    
    UIGraphicsEndImageContext(); 
}

#pragma mark BaseViewController overrides

- (void)setComponentData:(NSMutableDictionary *)componentData
{
	[super setComponentData:componentData];
    
    _unveilFlags = [[componentData objectForKey:@"unveilFlags"] intValue];
	_softness = [[componentData objectForKey:@"softness"] floatValue];
	_speed = [[componentData objectForKey:@"speed"] intValue];
    NSNumber *durationValue = [componentData objectForKey:@"duration"];
    if (durationValue) {
        self.duration = [durationValue intValue];
    }
}

- (void)resetComponent
{
    [self stopFrameUpdates];
    self.clipsToBounds = YES;
    CGRect frame = _unveilView.frame;
    frame.origin.x += frame.size.width;
    _unveilView.frame = frame;
    [self setNeedsDisplay];
}

- (void)startComponent
{
	if (!_maskImage) {
		[self buildMask];
	}
	
    [super startComponent];
	[self startFrameUpdates];	
}

- (void)stopComponent
{
    [super stopComponent];
	[self stopFrameUpdates];

	_maskImage = nil;
}

- (void)frameUpdate:(CADisplayLink*)displayLink
{
    [self setNeedsDisplay];
}

#pragma mark UIView overrides

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!_maskImage) {
        CGContextClearRect(ctx, rect);
        return;
    }
    
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.dateStarted];	
	
	NSInteger unveilType = _unveilFlags & kUnveilComponentUnvealTypeMask;
	// calculate the pixel distance over which the animations occurs
	CGFloat animateDistance;
	if (unveilType == kUnveilComponentUnvealRadial) {
        animateDistance = sqrt(_maskImage.size.width * _maskImage.size.width * 2);
    }
    else if (unveilType == kUnveilComponentUnvealUp || unveilType == kUnveilComponentUnvealDown) {
        animateDistance = _maskImage.size.height;
    } else {
        animateDistance = _maskImage.size.width;
    }
//	animateDistance += _softness;
	
	// calculate the unveil progress
    CGFloat uUnveil = seconds * _speed / animateDistance;
	BOOL finished = NO;
	if (uUnveil > 1.0) {
		finished = YES;
		uUnveil = 1.0;
	}

    switch (_unveilFlags & kUnveilComponentUnvealEaseMask) {
        case kUnveilComponentUnvealEaseIn:
            uUnveil = [EasingFilter easeIn:uUnveil];
            break;
        case kUnveilComponentUnvealEaseOut:
            uUnveil = [EasingFilter easeOut:uUnveil];
            break;
        case kUnveilComponentUnvealEaseInOut:
            uUnveil = [EasingFilter easeInOut:uUnveil];
            break;
    }
    
	// calculate mask rect
	CGRect frame = CGRectMake(0, 0, _maskImage.size.width, _maskImage.size.height);
	switch (unveilType) {
		case kUnveilComponentUnvealLeft:	
			frame.origin.x = _unveilView.frame.size.width - animateDistance * uUnveil;
			break;
		case kUnveilComponentUnvealRight:
			frame.origin.x = -_maskImage.size.width + animateDistance * uUnveil;
			break;
		case kUnveilComponentUnvealUp:
			frame.origin.y = _unveilView.frame.size.height - animateDistance * uUnveil;
			break;
		case kUnveilComponentUnvealDown:
			break;
		case kUnveilComponentUnvealRadial: {
//			NSLog(@"uUnveil: %.2f", uUnveil);
//			frame.origin = CGPointMake(-frame.size.width / 2, <#CGFloat y#>)
			CGFloat offset = uUnveil * animateDistance * (_maskImage.size.width / animateDistance);
			frame.origin = CGPointMake(_unveilView.frame.size.width / 2 - offset, _unveilView.frame.size.height / 2 - offset);
			frame.size = CGSizeMake(offset * 2, offset * 2);
		}
	}
	// render the unveil view with masking
//	CGContextDrawImage(ctx, frame, [_maskImage CGImage]);
	CGContextClipToMask(ctx, frame, [_maskImage CGImage]);
	[_unveilView.layer renderInContext:ctx];
			
    
    if (finished) {
        [self stopComponent];
    }
}

#pragma mark Getter/Setter

- (void)setDuration:(CGFloat)duration
{
    UnveilComponentFlags typeFlags = _unveilFlags & kUnveilComponentUnvealTypeMask;
    if (typeFlags == kUnveilComponentUnvealLeft || typeFlags == kUnveilComponentUnvealRight) {
        _speed = (_unveilView.frame.size.width + _softness) / duration;
    }
    else if (typeFlags == kUnveilComponentUnvealRadial) {
        _speed = (MAX(_unveilView.frame.size.width, _unveilView.frame.size.height) + 2 * _softness) / duration;
    }
    else {
        _speed = (_unveilView.frame.size.height + _softness) / duration;
    }
}

- (CGFloat)duration
{
    UnveilComponentFlags typeFlags = _unveilFlags & kUnveilComponentUnvealTypeMask;
    if (typeFlags == kUnveilComponentUnvealLeft || typeFlags == kUnveilComponentUnvealRight) {
        return (_unveilView.frame.size.width + _softness) / _speed;
    }
    else if (typeFlags == kUnveilComponentUnvealRadial) {
        return (MAX(_unveilView.frame.size.width, _unveilView.frame.size.height) + _softness * 2) / _speed;
    }
    else {
        return (_unveilView.frame.size.height + _softness) / _speed;
    }
}

@end
