#import <Foundation/Foundation.h>

/**
 * Immutable KineticConstant, which is used in the calculations.
 *
 * This is a simple wrapper around a numberic type to make the code more readable
 * and also to ensure that when changing the underlying type that I only have to change one
 * or two things
 */
@interface KineticConstant : NSObject{
    double mValue;
}

- (id) initWithDouble:(double)value;
- (double) doubleValue;
@end
