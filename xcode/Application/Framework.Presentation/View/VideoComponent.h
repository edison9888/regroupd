//
//  VideoComponent.h
//  Presentation Framework
//
//

#import <UIKit/UIKit.h>
#import "PopOverComponent.h"
#import "FoundationMovieView.h"


@interface VideoComponent : PopOverComponent <FoundationMovieViewDelegate> {
    UIImageView *_videoStartFrame;
    UIImageView *_videoEndFrame;
    NSString *_videostartFrameImage;
    NSString *_videoEndFrameImage;
    FoundationMovieView *_moviePlayer;
    
    UITapGestureRecognizer *_resetGesture;
    
    NSString *_movieFilename;
    BOOL _isExiting;
    BOOL _isMoviePlaying;
    BOOL _isInlineMovie;
    BOOL _isAutoplay;
	BOOL _isLooping;
	BOOL _playFromRandom;
	NSArray *_cuePointsSeconds;
}

@property (strong) IBOutlet UIImageView *videoStartFrame;
@property (strong) IBOutlet UIImageView *videoEndFrame;
@property (strong) NSString *videostartFrameImage;
@property (strong) NSString *videoEndFrameImage;
@property (strong) FoundationMovieView *moviePlayer;
@property (strong) UITapGestureRecognizer *resetGesture;
@property (strong) NSString *movieFilename;
@property (nonatomic, assign) BOOL isExiting;
@property (assign, getter=isMoviePlaying) BOOL isMoviePlaying;
@property (assign, getter=isInlineMovie) BOOL isInlineMovie;
@property (assign, getter=isAutoplay) BOOL isAutoplay;
@property (assign, getter=isLooping) BOOL isLooping;

- (void)playMovie;
- (void)pauseMovie;
- (void)stopMovie;
- (void)resetMovie;

- (void)swapOutMovie;
- (BOOL)playInlineMovieWithName:(NSString *)movieName atFrame:(CGRect)movieFrame asSubviewOf:(UIView *)chosenSubview;
- (void)loadMoviePlayer:(NSString *)movieName withFrame:(CGRect)movieFrame andIsInline:(BOOL)isInline;

- (void)foundationMovieView:(FoundationMovieView *)foundationMovieView playerIsReady:(AVPlayer *)player;
- (void)foundationMoviePlayerDidFinish:(FoundationMovieView *)foundationMovieView;

@end
