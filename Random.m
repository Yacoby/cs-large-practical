#import "Random.h"

@implementation StaticRandom
- (id)initWithStaticNumber:(double)number{
    self = [super init];
    if ( self != nil ){
        mStaticNumber = number;
    }
    return self;
}
- (double)next{
    return mStaticNumber;
}
@end

@implementation UniformRandom
- (id)initWithSeed:(uint)seed{
    self = [super init];
    if ( self != nil ){
        mSeed = seed;
    }
    return self;
}
- (double)next{
    return ((double)rand_r(&mSeed))/RAND_MAX;
}
@end

