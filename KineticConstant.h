#import <Foundation/Foundation.h>

/**
 * @brief Immutable KineticConstant, which is used in the simulation calculations
 *
 * This thin wrapper around a primative type allows the abstraction of the underling
 * type and provides better code readability
 */
@interface KineticConstant : NSObject{
    double mValue;
}

- (id)initWithDouble:(double)value;
- (double)doubleValue;
@end
