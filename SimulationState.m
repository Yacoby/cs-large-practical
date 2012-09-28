#import "SimulationState.h"

@implementation SimulationState

- (NSCountedSet*)moleculeCounts{
    return mMoleculeCount;
}
- (TimeSpan*)timeSinceSimulationStart{
    return mTimeSinceSimulationStart;
}

@end
