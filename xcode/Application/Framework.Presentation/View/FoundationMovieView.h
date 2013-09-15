//
//  FoundationMovieView.h
//  Presentation Framework
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol FoundationMovieViewDelegate;

typedef enum {
    FoundationMovieViewStatusUnknown,
    FoundationMovieViewStatusPaused,
    FoundationMovieViewStatusPlaying,
    FoundationMovieViewStatusStopped
} FoundationMovieViewStatus;

@interface FoundationMovieView : UIView {
    int _playCount;
}

@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, readonly, strong) NSURL *movieURL;
@property (nonatomic, weak) IBOutlet id <FoundationMovieViewDelegate> delegate;
@property (assign) BOOL isInlinePlayer;
@property (assign) BOOL shouldAutoPlay;
@property (assign) BOOL shouldLoop;
@property (assign) FoundationMovieViewStatus status;

@property (nonatomic, assign) BOOL playerIsPaused;

- (id)initWithFrame:(CGRect)frame andPath:(NSString *)moviePath;
- (void)loadPath:(NSString *)moviePath;
- (void)loadURL:(NSURL *)movieURL;
- (void)loadPath:(NSString *)moviePath autoPlay:(BOOL)autoPlay;
- (void)loadURL:(NSURL *)movieURL autoPlay:(BOOL)autoPlay;
- (void)addMarker:(NSTimeInterval)marker;
- (void)resetMarkerFlags;
- (void)clearMarkerFlags;
- (void)play;
- (void)restart;

/**
 * Seek to the seektime
 * @param seekTime in seconds
 * @returns 
 */
- (void)seekTo:(NSTimeInterval)seekTime;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (void)loadPlayer;
- (Float64)currentTimeInSeconds;
- (void)cleanupPlayer;
@end

@protocol FoundationMovieViewDelegate<NSObject>

@optional
- (void)foundationMovieView:(FoundationMovieView *)foundationMovieView playerIsReady:(AVPlayer *)player;
- (void)foundationMoviePlayerDidFinish:(FoundationMovieView *)foundationMovieView;
- (void)foundationMoviePlayer:(FoundationMovieView *)foundationMovieView didReachMarker:(NSTimeInterval)marker;
@end