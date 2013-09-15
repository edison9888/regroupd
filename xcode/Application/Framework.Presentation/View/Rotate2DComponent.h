//
//  Rotate2DComponent.h
//  Incivek
//
//

#import <Foundation/Foundation.h>
#import "PopOverComponent.h"

@interface Rotate2DComponent : PopOverComponent {
	UIView			*_rotateView;
    CGFloat			_velocity;
    CGFloat         _orgVelocity;
    CGFloat         _angle;
    
    CGFloat         _velocityDampen;
}

@property (nonatomic, strong) IBOutlet UIView *rotateView;

/*
 * angular velocity in rotations/second
 */
@property (nonatomic, assign) CGFloat velocity;

/*
 * dampening factor, the inverse of which is multiplicative per frame
 */
@property (nonatomic, assign) CGFloat velocityDampen;


@end
