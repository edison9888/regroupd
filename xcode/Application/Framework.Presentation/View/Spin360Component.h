//
//  Spin360Component.h
//  Presentation
//
//

#import <UIKit/UIKit.h>
#import "PopOverComponent.h"

@interface Spin360Component : PopOverComponent {
    UIImageView *_imageView;
	CGFloat _velocity;
	CGFloat   _offset;
	
	NSString *_imageNameFormatString;
	NSInteger _iCurrentFrame;
	NSInteger _nFrames;
    NSInteger _iFirstFrame;
	NSInteger _iFrameAtTouch;
    
    NSInteger _autoSpinStartFrame;
    NSInteger _autoSpinNFrames;
    NSDate      *_autoSpinStartDate;
}

@property (nonatomic, strong) NSString *imageNameFormatString;
@property (nonatomic, assign) NSInteger iCurrentFrame;
@property (nonatomic, assign) NSInteger nFrames;
@property (nonatomic, assign) NSInteger iFirstFrame;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (void)autoSpinToIndex:(NSInteger)frame;

@end
