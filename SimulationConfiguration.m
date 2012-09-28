#import "SimulationConfiguration.h"

@implementation SimulationConfiguration

- (id) init {
    self = [super init];
    if (self != nil) {
        mKineticConstants = [[NSMutableDictionary init] alloc];
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
    [mKineticConstants release];
}

- (int)time {
    return mTime;
}
- (void)setTime:(int)time{
    mTime = time;
}

- (void)setKineticConstant:(NSString*)key value:(int)value{
    KineticConstant* kineticConstant = [[[KineticConstant alloc] initWithDouble:value] autorelease];
    [mKineticConstants setObject:kineticConstant forKey:key];
}

- (KineticConstant*)kineticConstant:(NSString*)key{
    return [mKineticConstants objectForKey:key];
}

@end
