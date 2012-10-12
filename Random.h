#import <Foundation/Foundation.h>

@protocol Random <NSObject>
- (double)next;
@end

@interface StaticRandom : NSObject <Random>{
    double mStaticNumber;
}
- (id)initWithStaticNumber:(double)number;
- (double)next;
@end

@interface UniformRandom : NSObject <Random>{
    uint mSeed;
}
- (id)initWithSeed:(uint)seed;
- (double)next;
@end
