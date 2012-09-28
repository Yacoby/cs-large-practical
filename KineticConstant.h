#import <Foundation/Foundation.h>

/**
 * @brief Immutable KineticConstant, which is used in the simulation calculations
 */
@interface KineticConstant : NSObject{
    double mValue;
}

- (id)initWithDouble:(double)value;
- (double)doubleValue;
@end
