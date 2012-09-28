#import <Foundation/Foundation.h>

/**
 * Immutable KineticConstant, which is used in the simulation calculations
 */
@interface KineticConstant : NSObject{
    double mValue;
}

- (id)initWithDouble:(double)value;
- (double)doubleValue;
@end
