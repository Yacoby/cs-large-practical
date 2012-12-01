#import <Foundation/Foundation.h>

/**
 * @brief Represents a time interval

 * This represents a time interval, in this case this is mostly used to 
 * represent the time since the simulation start. It is a thin wrapper
 * around a double to provide a more readable interface.
 */
@interface TimeSpan : NSObject{
    double mTimeSpanSeconds;
}

- (id)initFromSeconds:(double)seconds;
- (double)totalMilliseconds;
- (double)totalSeconds;

- (void)setTotalMilliseconds:(double)ms;
- (void)setTotalSeconds:(double)s;

- (void)addSeconds:(double)seconds;
@end
