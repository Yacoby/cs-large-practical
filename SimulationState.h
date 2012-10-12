#import <Foundation/Foundation.h>
#import "TimeSpan.h"

/**
 * @brief Represents a state (molecule counts) at a spesific point in time from the start of the simulation
 */
@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSMutableDictionary* mMoleculeCount;
}
- (id)initWithTime:(TimeSpan*)time moleculeCount:(NSMutableDictionary*)counts;
- (void)dealloc;

- (NSMutableDictionary*)moleculeCounts;
- (uint)moleculeCount:(NSString*)moleculeName;
- (TimeSpan*)timeSinceSimulationStart;
@end
