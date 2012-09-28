#import "SimulationState.h"

@implementation SimulationState

- (NSDictionary*)moleculeCounts{
    return mMoleculeCount;
}
- (TimeSpan*)timeSinceSimulationStart{
    return mTimeSinceSimulationStart;
}

@end
