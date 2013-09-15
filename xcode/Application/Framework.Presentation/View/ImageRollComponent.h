//
//  ImageRollComponent.h
//  Presentation Framework
//
//

#import <UIKit/UIKit.h>
#import "PopOverComponent.h"


@interface ImageRollComponent : PopOverComponent {
    UIImageView		*_imageRollView;
	NSTimer			*_frameTimer;
	NSMutableArray	*_imageArray;
	
	double			_frameRate;
	NSInteger		_iFirstFrame;
	NSInteger		_nFrames;
	NSInteger		_iCurrentFrame;
	
    BOOL			_isMoviePlaying;
    BOOL			_isAutoplay;
}

@property (strong) IBOutlet UIImageView *imageRollView;


- (void)playMovie;
- (void)stopMovie;
- (void)resetMovie;


@end
