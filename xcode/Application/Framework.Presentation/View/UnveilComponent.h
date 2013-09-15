//
//  UnveilComponent.h
//  Incivek
//
//

#import <Foundation/Foundation.h>
#import "PopOverComponent.h"

typedef enum {
	kUnveilComponentUnvealLeft =		0x0001,
	kUnveilComponentUnvealRight =		0x0002,
	kUnveilComponentUnvealUp =			0x0003,
	kUnveilComponentUnvealDown =		0x0004,
	kUnveilComponentUnvealRadial =		0x0005,		// unsupported
    
	kUnveilComponentUnvealEaseIn =		0x0010,
	kUnveilComponentUnvealEaseOut =		0x0020,
	kUnveilComponentUnvealEaseInOut =	0x0030,
    
	kUnveilComponentUnvealTypeMask =	0x000F,    
	kUnveilComponentUnvealEaseMask =	0x00F0,
} UnveilComponentFlags;


@interface UnveilComponent : PopOverComponent {
	UIView			*_unveilView;
    UIImage			*_maskImage;
	
	UnveilComponentFlags _unveilFlags;
	CGFloat			_softness;
	CGFloat			_speed;
}

@property (nonatomic, strong) IBOutlet UIView *unveilView;
@property (nonatomic, strong) UIImage *maskImage;

/*
 * determines the linear direction of the unveiling
 */
@property (nonatomic, assign) UnveilComponentFlags unveilFlags;

/*
 * the softness of the mask edge, in pixesl
 */
@property (nonatomic, assign) CGFloat softness;

/*
 * the speed of the unveiling, in pixels/second
 */
@property (nonatomic, assign) CGFloat speed;

/*
 * the duration of the unveiling, in seconds (is converted to speed)
 */
@property (nonatomic, assign) CGFloat duration;


@end
