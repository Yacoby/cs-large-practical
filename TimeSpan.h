#import <Foundation/Foundation.h>

/**
 * @brief Represents a time interval

 * This represents a time interval, in this case this is mostly used to 
 * represent the time since the simulation start. It is a thin wrapper
 * around a double to provide a more readable interface.
 */
@interface TimeSpan : NSObject <NSMutableCopying>{
    double mTimeSpanSeconds;
}

/**
 * @brief creates a timespan object from the given number of seconds
 */
- (id)initFromSeconds:(double)seconds;

/**
 * @return gets the total number of milliseconds held by this time span
 */
- (double)totalMilliseconds;

/**
 * @return the total number of seconds held by this time span
 */
- (double)totalSeconds;

/**
 * @brief sets the current timespan from the given number of milliseconds
 */
- (void)setTotalMilliseconds:(double)ms;

/**
 * @brief sets the current timespan from the given number of seconds
 */
- (void)setTotalSeconds:(double)s;

/**
 * @brief adds a number of seconds to the TimeSpan
 */
- (void)addSeconds:(double)seconds;

- (id)mutableCopyWithZone:(NSZone*)zone;
@end
