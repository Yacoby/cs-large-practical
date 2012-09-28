#import <Foundation/Foundation.h>

/**
 * @brief Represents a time interval

 * This represents a time interval, in this case this is mostly used to 
 * represent the time since the simulation start
 */
@interface TimeSpan : NSObject{
    double mTimeSpanSeconds;
}

- (id)initFromSeconds:(double)seconds;
- (double)totalSeconds;
@end
