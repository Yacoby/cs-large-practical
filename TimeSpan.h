#import <Foundation/Foundation.h>

@interface TimeSpan : NSObject{
    double mTimeSpanSeconds;
}

- (id) initFromSeconds:(double)seconds;
- (double)totalSeconds;
@end
