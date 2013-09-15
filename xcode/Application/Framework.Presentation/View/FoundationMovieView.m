//
//  FoundationMovieView.m
//  Presentation Framework
//
//

#import "FoundationMovieView.h"
#include <QuartzCore/QuartzCore.h>

@interface FoundationMovieView()
{
    NSMutableDictionary *_markerListMap;
    NSMutableArray *_markerList;
}

@property (nonatomic, strong) id timeObserver;

- (void)initParams;
- (void)cleanupPlayer;
- (void)addTimeObserver;
- (void)removeTimeObserver;
- (void)handlePlayerStatusDidChange;
- (void)handlePlayerError;
- (void)handlePlayerReady;
- (void)checkIfAtEndOfMovie;
- (void)checkForMarker;
- (void)setMarkerFlagStatus:(BOOL)hasPlayed before:(NSTimeInterval)time;
- (void)handleMovieDidFinish;
@end


@implementation FoundationMovieView

@synthesize player = _player;
@synthesize delegate = _delegate;
@synthesize isInlinePlayer = _isInlinePlayer;
@synthesize shouldAutoPlay = _shouldAutoPlay;
@synthesize shouldLoop = _shouldLoop;
@synthesize movieURL = _movieURL;
@synthesize timeObserver = _timeObserver;
@synthesize status = _status;

@synthesize playerIsPaused = _playerIsPaused;

#pragma mark -
#pragma mark Initialization Methods
- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andPath:nil];
}

- (id)initWithFrame:(CGRect)frame andPath:(NSString *)moviePath {
    self = [super initWithFrame:frame];
    if (self) {
        [self initParams];
		[self loadPath:moviePath];
    }
    return self;
}

- (void)awakeFromNib 
{
    [super awakeFromNib];
    self.alpha = 0;
    [self initParams];
}

- (void)initParams
{
    _playCount = 0;
    _shouldAutoPlay = YES;
    _status = FoundationMovieViewStatusUnknown;
    _markerList = [[NSMutableArray alloc] init];
    _markerListMap = [[NSMutableDictionary alloc] init];
}

+(Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - Memory Management

-(void)dealloc {
    [self cleanupPlayer];   // removes time observer
}

#pragma mark - Playback Control Methods
- (void)play {
    if(_player.status != AVPlayerStatusReadyToPlay){
        return;
    }
    [self.player play];
    _status = FoundationMovieViewStatusPlaying;
}

- (void)seekTo:(NSTimeInterval)seekTime 
{
	[self.player seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC)];
    [self setMarkerFlagStatus:YES before:seekTime];
}

-(void)pause {
    if(_player.status != AVPlayerStatusReadyToPlay){
        return;
    }
    [self.player pause];
    _status = FoundationMovieViewStatusPaused;
}

- (void)stop {
	[self.player pause];
	[self handleMovieDidFinish];
    _status = FoundationMovieViewStatusStopped;
}

- (void)restart
{
    if(_player.status != AVPlayerStatusReadyToPlay){
        return;
    }

    [self.player seekToTime:CMTimeMakeWithSeconds(0,1)];
    [self.player play];
}


#pragma mark - AVPlayer Setup and Configuration
-(void)loadPath:(NSString *)moviePath 
{
    [self loadPath:moviePath autoPlay:self.shouldAutoPlay];
}

-(void)loadPath:(NSString *)moviePath autoPlay:(BOOL)autoPlay 
{
    if (moviePath == nil) {
        _movieURL = nil;
        return;
    }
	[self loadURL:[NSURL fileURLWithPath:moviePath] autoPlay:autoPlay];
}

-(void)loadURL:(NSURL *)movieURL 
{
    [self loadURL:movieURL autoPlay:self.shouldAutoPlay];
}

-(void)loadURL:(NSURL *)movieURL autoPlay:(BOOL)autoPlay 
{
    self.shouldAutoPlay = autoPlay;
    if ([movieURL isEqual:_movieURL]) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 1)];
        [self handlePlayerReady];
        return;
    }
    
    _movieURL = movieURL;
    if (movieURL == nil) {
        return;
    }
    
    if (self.player.status == AVPlayerStatusFailed) {
        [self cleanupPlayer];
    }
    
    NSLog(@"Load URL in AVPlayer: %@", movieURL);
    if (self.player == nil) {
        [self loadPlayer];
    }else{
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:movieURL]];
    }
}

- (void)loadPlayer {
	NSLog(@"... creating AVPlayer");
	AVPlayer *player = [[AVPlayer alloc] initWithURL:self.movieURL];
    self.player = player;
	
	[self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
	[self.player addObserver:self forKeyPath:@"currentItem.error" options:0 context:nil];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    playerLayer.player = self.player; 
    [playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    
    
	[self addTimeObserver];
}

- (void)cleanupPlayer {
	NSLog(@"... cleaning Up AVPlayer");
	[self removeTimeObserver];
    [_markerList removeAllObjects];
    [_markerListMap removeAllObjects];
    
    if (!self.player) {
        return;
    }
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    [playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
    playerLayer.player = nil;

	[self.player removeObserver:self forKeyPath:@"status"];
	[self.player removeObserver:self forKeyPath:@"currentItem.error"];
    self.player = nil;
}

- (void)addTimeObserver {
	[self removeTimeObserver];
	self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.1, NSEC_PER_SEC) 
                                                                  queue:nil 
                                                             usingBlock:^(CMTime time) {
                                                                 [self checkIfAtEndOfMovie];
                                                                 [self checkForMarker];
                                                             }];
}

- (void)removeTimeObserver {
	if (self.timeObserver != nil) {
		[self.player removeTimeObserver:self.timeObserver];
		self.timeObserver = nil;
	}
}

#pragma mark - Accessor Methods
static Float64 secondsWithCMTimeOrZeroIfInvalid(CMTime time) {
	return CMTIME_IS_INVALID(time) ? 0.0f : CMTimeGetSeconds(time);
}


- (Float64)durationInSeconds {
	return secondsWithCMTimeOrZeroIfInvalid(self.player.currentItem.duration);
}


- (Float64)currentTimeInSeconds {
	return secondsWithCMTimeOrZeroIfInvalid([self.player currentTime]);
}


- (Float64)timeRemainingInSeconds {
	return [self durationInSeconds] - [self currentTimeInSeconds];
}

- (BOOL)playerIsPaused {
	return self.player.rate < 0.01;
}

- (BOOL)playerHasPlayedToEndOfMovie 
{
	if (![self playerIsPaused])
		return NO;
	Float64 currentTime = [self currentTimeInSeconds];
	Float64 duration = [self durationInSeconds];
	return currentTime > 0.01 && duration > 0.01 && ([self currentTimeInSeconds] >= [self durationInSeconds] - 0.1);
}

- (void)checkIfAtEndOfMovie {
    BOOL isFinished = [self playerHasPlayedToEndOfMovie];
	if (isFinished && _shouldLoop) {
        [self restart];
	} else if (isFinished) {
        [self handleMovieDidFinish];
    }
}

#pragma mark - Stop Points Methods
- (void)checkForMarker
{
    NSTimeInterval threshold = .1f;
    
    CMTime currentTime = [_player currentTime];
    NSTimeInterval timeInSec = CMTimeGetSeconds(currentTime);
    
    if (isnan(timeInSec)) {
        [self removeTimeObserver];
        return;
    }
    
    for (NSInteger index = 0; index < [_markerList count]; index++) {
        NSTimeInterval currentPoint = [(NSNumber *)[_markerList objectAtIndex:index] doubleValue];
		NSNumber *hasPlayed = [_markerListMap objectForKey:(NSNumber *)[_markerList objectAtIndex:index]];
		
        if ([hasPlayed intValue] == 0 && 
            currentPoint >= timeInSec - threshold && 
            currentPoint <= timeInSec + threshold
			) {
			[_markerListMap setObject:[NSNumber numberWithInt:1] forKey:(NSNumber *)[_markerList objectAtIndex:index]];
            
            if ([_delegate respondsToSelector:@selector(foundationMoviePlayer:didReachMarker:)]) {
                [_delegate foundationMoviePlayer:self didReachMarker:currentPoint];                
            }
            
            return;
        }
    }
}

- (void)addMarker:(NSTimeInterval)marker
{
    [_markerList addObject:[NSNumber numberWithDouble:marker]];
	[_markerListMap setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithDouble:marker]];
}

- (void)setMarkerFlagStatus:(BOOL)hasPlayed before:(NSTimeInterval)time 
{
	for (NSInteger index = 0; index < [_markerList count]; index++) {
		NSNumber *stopPoint = [_markerList objectAtIndex:index];
		
        if ([stopPoint floatValue] <= time) {
			[_markerListMap setObject:[NSNumber numberWithBool:hasPlayed] forKey:stopPoint];
        }
    }
}

- (void)resetMarkerFlags
{
    for (NSNumber *marker in _markerList) {
        [_markerListMap setObject:[NSNumber numberWithInt:0] forKey:marker];
    }
}

- (void)clearMarkerFlags
{
    [_markerList removeAllObjects];
    [_markerListMap removeAllObjects];
}

#pragma mark - Property Getter and Setters
- (BOOL)isPlaying 
{
    if(!self.player) {
        return NO;
    }
    
    CMTime cTime = [self.player currentTime];
    float currentTime = (cTime.value * 1.0f) / (cTime.timescale * 1.0f);
    float duration = 0.0f;
    
    NSArray *times = [self.player.currentItem seekableTimeRanges];
    if([times count] != 0) {
        NSValue *val = [times objectAtIndex:0];
        CMTimeRange range = [val CMTimeRangeValue];
        CMTime dTime = range.duration;
        duration = (dTime.value * 1.0f) / (dTime.timescale * 1.0f);
    }
    
    if(currentTime != 0 && currentTime != duration) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Player Notifications and Event Handlers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
	if ([keyPath isEqualToString:@"status"] && object == self.player) {
		[self handlePlayerStatusDidChange];
    } else if ([keyPath isEqualToString:@"currentItem.error"] && object == self.player && self.player.currentItem.error != nil) {
		[self handlePlayerError];
    }
    if ([keyPath isEqualToString:@"readyForDisplay"] && object == self.layer) {
        [self handlePlayerReady];
    }
}

- (void)handlePlayerStatusDidChange 
{
	if (self.player.status == AVPlayerStatusReadyToPlay) {
		[self handlePlayerReady];
	}
}

- (void)handlePlayerError 
{
    [self cleanupPlayer];
}

- (void) handlePlayerReady 
{
    if (self.player.status != AVPlayerStatusReadyToPlay || ![(AVPlayerLayer *)self.layer isReadyForDisplay]) {
        return;
    }
    
    
	if (self.shouldAutoPlay) {
		[self.player play];
        _status = FoundationMovieViewStatusPlaying;
	}else{
        _status = FoundationMovieViewStatusPaused;
    }
    
	if ([self.delegate respondsToSelector:@selector(foundationMovieView:playerIsReady:)]) {
		[self.delegate foundationMovieView:self playerIsReady:self.player];
	}
}

- (void)handleMovieDidFinish 
{
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(foundationMoviePlayerDidFinish:)]) {
		[self.delegate foundationMoviePlayerDidFinish:self];
	}
    _status = FoundationMovieViewStatusStopped;
    if (self.timeObserver) {
        //[self.player removeTimeObserver:self.timeObserver];
    }
}


@end
