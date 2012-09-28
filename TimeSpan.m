#import "TimeSpan.h"

@implementation TimeSpan
- (id)initFromSeconds:(double)seconds{
    self = [super init];
    if ( self != nil ){
        mTimeSpanSeconds = seconds;
    }
    return self;
}

- (double)totalSeconds{
    return mTimeSpanSeconds;
}
@end
