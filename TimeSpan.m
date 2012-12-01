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

- (double)totalMilliseconds{
    return [self totalSeconds]*1000;
}

- (void)setTotalMilliseconds:(double)ms{
   [self setTotalSeconds:ms/1000];
}
- (void)setTotalSeconds:(double)s{
    mTimeSpanSeconds = s;
}

- (void)addSeconds:(double)seconds{
    mTimeSpanSeconds += seconds;
}

- (id)mutableCopyWithZone:(NSZone*)zone{
    return [[TimeSpan alloc] initFromSeconds:[self totalSeconds]];
}
@end
