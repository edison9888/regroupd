//
//  EasingFilter.m
//  Incivek
//
//

#import "EasingFilter.h"

@interface EasingFilter()
{
}

double  easeInQuad (double t, double b, double c, double d);
double  easeOutQuad (double t, double b, double c, double d);
double  easeInOutQuad (double t, double b, double c, double d);
@end

@implementation EasingFilter

+ (CGFloat)easeIn:(CGFloat)uVal
{
	return easeInQuad(uVal, 0, 1.0, 1.0);
}

+ (CGFloat)easeOut:(CGFloat)uVal
{
	return easeOutQuad(uVal, 0, 1.0, 1.0);
}

+ (CGFloat)easeInOut:(CGFloat)uVal
{
    return easeInOutQuad(uVal, 0, 1.0, 1.0);
}

/**
 * Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
double  easeInQuad (double t, double b, double c, double d) {
	return c*(t/=d)*t + b;
}

/**
 * Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
double  easeOutQuad (double t, double b, double c, double d) {
	return -c *(t/=d)*(t-2) + b;
}

/**
 * Easing equation function for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
double  easeInOutQuad (double t, double b, double c, double d) {
	if ((t/=d/2) < 1) return c/2*t*t + b;
	return -c/2 * ((--t)*(t-2) - 1) + b;
}

@end
