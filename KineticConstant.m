#import "KineticConstant.h"

@implementation KineticConstant
- (id)initWithDouble:(double)value{
    self = [super init];
    if ( self != nil ){
        mValue = value;
    }
    return self;
}

- (double)doubleValue{
    return mValue;
}
@end
