//
//  ImageRollComponent.m
//  Presentation Framework
//
//

#import "ImageRollComponent.h"


@implementation ImageRollComponent
@synthesize imageRollView = _imageRollView;


- (void) initializeImageView 
{
//	self.imageRollView.animationDuration = [[self.componentData objectForKey:@"durationSeconds"] doubleValue];
//	self.imageRollView.animationRepeatCount = 1;
	
	_nFrames = [[self.componentData objectForKey:@"frameCount"] intValue];
	_iFirstFrame = [[self.componentData objectForKey:@"firstFrame"] intValue];
	_frameRate = [[self.componentData objectForKey:@"durationSeconds"] doubleValue] / _nFrames;
	
	NSString *fileTemplate = [self.componentData objectForKey:@"fileTemplate"];
	
	_imageArray = [[NSMutableArray alloc] initWithCapacity:_nFrames];

	for (int i = _iFirstFrame; i < _iFirstFrame + _nFrames; i++) {
		NSString *imageName = [NSString stringWithFormat:fileTemplate, i];
		imageName = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
		[_imageArray addObject:[UIImage imageWithContentsOfFile:imageName]];
	}
	
	CGSize viewSize = ((UIImage*)[_imageArray objectAtIndex:0]).size;
	CGPoint viewCenter = self.imageRollView.center;
	self.imageRollView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
	self.imageRollView.center = viewCenter;
//	self.imageRollView.animationImages = imageArray;
}

- (id)initWithFrame:(CGRect)frame andComponentData:(NSDictionary*)componentData
{
    self = [super initWithFrame:frame andComponentData:componentData];
	
    if (self) {
        if ([[self.componentData objectForKey:@"playOnLoad"] boolValue]) {
            [self playMovie];
        }
    }
    
    return self;
}

- (void)dealloc
{
	[self stopMovie];
	
}

- (void)nextFrame:(NSTimer*)timer
{
	if (_iCurrentFrame < _nFrames - 1) {
		_iCurrentFrame++;
		[self.imageRollView setImage:[_imageArray objectAtIndex:_iCurrentFrame]];
	} else {
		[self stopMovie];
	}
}

- (void)playMovie
{
	[self stopMovie];
	if (!_imageArray) {
		[self initializeImageView];
		_iCurrentFrame = 0;
		[self.imageRollView setImage:[_imageArray objectAtIndex:_iCurrentFrame]];
	}

	_frameTimer = [NSTimer scheduledTimerWithTimeInterval:_frameRate target:self selector:@selector(nextFrame:) userInfo:nil repeats:YES];
//	[self.imageRollView startAnimating];
}

- (void)stopMovie
{
	[_frameTimer invalidate];
	_frameTimer = nil;
//	[self.imageRollView stopAnimating];
}

- (void)resetMovie 
{
	if (!_imageArray) {
		[self initializeImageView];
	} else {
		[self stopMovie];
	}
	
	_iCurrentFrame = 0;
	[self.imageRollView setImage:[_imageArray objectAtIndex:_iCurrentFrame]];
}

#pragma mark - Component life cycle
- (void)startComponent 
{
    [super startComponent];
    [self playMovie];
}

- (void)stopComponent 
{
	[super stopComponent];
	[self stopMovie];
}



@end
