//
//  VideoComponent.m
//  Presentation Framework
//
//

#import "VideoComponent.h"


@interface VideoComponent(Private)
-(void)cleanupMovieView;
@end

@implementation VideoComponent

@synthesize videoStartFrame = _videoStartFrame;
@synthesize videoEndFrame = _videoEndFrame;
@synthesize videostartFrameImage = _videostartFrameImage;
@synthesize videoEndFrameImage = _videoEndFrameImage;
@synthesize moviePlayer = _moviePlayer;
@synthesize resetGesture = _resetGesture;
@synthesize movieFilename = _movieFilename;
@synthesize isExiting = _isExiting;
@synthesize isMoviePlaying = _isMoviePlaying;
@synthesize isInlineMovie = _isInlineMovie;
@synthesize isAutoplay = _isAutoplay;
@synthesize isLooping = _isLooping;

- (void)awakeFromNib 
{
    [super awakeFromNib];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isAutoplay = NO;
        _isMoviePlaying = NO;
        _isInlineMovie = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andComponentData:(NSMutableDictionary*)componentData
{
    self = [super initWithFrame:frame andComponentData:componentData];
	
    if (self) {
        [self setComponentData:componentData];
        if (_isAutoplay) {
            [self playMovie];
        }
    }
    
    return self;
}

#pragma mark BaseViewController overrides


- (void)setComponentData:(NSMutableDictionary *)componentData
{
    if (_componentData != componentData) {
        _componentData = componentData;
    }
    
    if ([[componentData objectForKey:@"isInline"] boolValue]) {
        _isInlineMovie = YES;
    }

    if ([[componentData objectForKey:@"isLooping"] boolValue]) {
        _isLooping = YES;
    }
	
    if ([[componentData objectForKey:@"playFromRandom"] boolValue]) {
        _playFromRandom = YES;
		_cuePointsSeconds = [componentData objectForKey:@"cuePointsSeconds"];
    }
    
    if ([componentData objectForKey:@"filename"]) {
        _movieFilename = [componentData objectForKey:@"filename"];
    }
    
    if([componentData objectForKey:@"movieStartFrame"]) {
        _videostartFrameImage = [componentData objectForKey:@"movieStartFrame"];
        [self.videoStartFrame setImage:[UIImage imageNamed:_videostartFrameImage]];
    }
    
    if([componentData objectForKey:@"movieEndFrame"]) {
        _videoEndFrameImage = [componentData objectForKey:@"movieEndFrame"];
       [self.videoEndFrame setImage:[UIImage imageNamed:_videoEndFrameImage]];
    }
    
    if ([[componentData objectForKey:@"playOnLoad"] boolValue]) {
        _isAutoplay = YES;
    }
}

- (void)startComponent 
{
    [super startComponent];
    [self playMovie];
}

- (void)stopComponent 
{
	[super stopComponent];
	_isExiting = YES;
	[self.moviePlayer stop];
}


#pragma mark - Movie Controls Methods

- (void)playMovie
{
    if (self.moviePlayer) {
        return;
    }
    
    [self playInlineMovieWithName:self.movieFilename
                          atFrame:self.bounds
                      asSubviewOf:self];
}

- (void)pauseMovie
{
    if (!_isMoviePlaying) {
        return;
    }
    
    [[self.moviePlayer player] pause];
}

- (void)resetMovie 
{
    if (!_isMoviePlaying) {
        return;
    }
    
	[[self.moviePlayer player] seekToTime:CMTimeMakeWithSeconds(0,1)];
	[[self.moviePlayer player] play];
}

- (void)stopMovie 
{
    if (!_isMoviePlaying) {
        return;
    }
    
    [self.moviePlayer stop];
}

#pragma mark - Cleanup Movie on Finish
- (void) swapOutMovie 
{
	_isMoviePlaying = NO;
	
    //view exiting no need to swap in endframe
	if (_isExiting) {
		[self cleanupMovieView]; 
		return;
	}

	if (_videoEndFrame) {
 	    [_videoEndFrame setAlpha:1.0f];
		[UIView animateWithDuration:0.33f 
							  delay:0.0f
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 self.moviePlayer.alpha = 0.f;
						 } 
						 completion:^(BOOL finished) {
							 [self.moviePlayer removeFromSuperview];
						 }];
	}
    
	[self cleanupMovieView];
}

- (void)cleanupMovieView {
	self.moviePlayer = nil;
}

- (BOOL) playInlineMovieWithName:(NSString *)movieName atFrame:(CGRect) movieFrame asSubviewOf:(UIView *)chosenSubview
{
    [self loadMoviePlayer:movieName withFrame:movieFrame andIsInline:YES];
	[_moviePlayer loadPlayer]; 
    _moviePlayer.alpha = 0.0;
    
	[UIView animateWithDuration:1.0 
						  delay:0.0 
						options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [_moviePlayer setAlpha:1.0f];
					 } 
					 completion:^(BOOL finished) {
						 [self.videoStartFrame setAlpha:0.0f];
					 }
     ];
    return YES;
}

- (void) loadMoviePlayer:(NSString *)movieName withFrame:(CGRect)movieFrame andIsInline:(BOOL)isInline {
    // Show movie
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:movieName];
	_moviePlayer = [[FoundationMovieView alloc] initWithFrame:movieFrame andPath:finalPath];
	
    _moviePlayer.isInlinePlayer = isInline;
	_moviePlayer.shouldLoop = _isLooping;
    [_moviePlayer setBackgroundColor:[UIColor clearColor]];
    _moviePlayer.tag = 100;
    [_moviePlayer setOpaque:NO];
	[_moviePlayer setDelegate:self];
	
    [self addSubview:_moviePlayer];
}

#pragma mark - FoundationMovieViewDelegate Methods

- (void)foundationMovieView:(FoundationMovieView *)foundationMovieView playerIsReady:(AVPlayer *)player {
	//NSLog(@"player ready in %@", self.movieFilename);
	
	if (!self.resetGesture && _isInlineMovie) {
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetInteraction)];
		[doubleTap setNumberOfTapsRequired:2];
		[_moviePlayer addGestureRecognizer:doubleTap];
		self.resetGesture = doubleTap;
	}
	
	_isMoviePlaying = YES;	
}

- (void)foundationMovieViewHasDuration:(FoundationMovieView *)foundationMovieView
{
/*	if (_playFromRandom) {
		NICUAppDelegate *appDelegate = (NICUAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSDate *datePlayed = [appDelegate.slideStates objectForKey:_movieFilename];
		if ([[NSDate date] timeIntervalSinceDate:datePlayed] > 5.0) {
//			double seconds = [self.moviePlayer currentTimeInSeconds];
			double seconds;
			if (_cuePointsSeconds.count) {
				seconds = [[_cuePointsSeconds objectAtIndex:random() % _cuePointsSeconds.count] floatValue];
			} else {
				seconds = self.moviePlayer.movieDuration.value / self.moviePlayer.movieDuration.timescale;
			}
			[[self.moviePlayer player] seekToTime:CMTimeMakeWithSeconds(seconds, 1)];
		} else {
			[appDelegate.slideStates setObject:[NSDate date] forKey:_movieFilename];
		}
	}*/
}


- (void)foundationMoviePlayerDidFinish:(FoundationMovieView *)foundationMovieView {
	//NSLog(@"player finish %@", self.movieFilename);
	[self swapOutMovie];
}

@end
