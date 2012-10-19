#import "SimulationState.h"

@implementation SimulationState
- (id)initWithTime:(TimeSpan*)time moleculeCount:(NSMutableDictionary*)counts{
    self = [super init];
    if ( self != nil ){
        [time retain];
        mTimeSinceSimulationStart = time;

        [counts retain];
        mMoleculeCount = counts;
    }
    return self;
}

- (void)dealloc{
    [mTimeSinceSimulationStart release];
    [mMoleculeCount release];
    [super dealloc];
}

- (NSMutableDictionary*)moleculeCounts{
    return mMoleculeCount;
}
- (uint)moleculeCount:(NSString*)moleculeName{
    NSNumber* number = [mMoleculeCount objectForKey:moleculeName];
    return [number unsignedIntValue];
}
- (TimeSpan*)timeSinceSimulationStart{
    return mTimeSinceSimulationStart;
}

@end
