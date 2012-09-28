#import <Foundation/Foundation.h>
#import "TimeSpan.h"

/**
 * @brief Represents a state (molecule counts) at a spesific point in time from the start of the simulation
 */
@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSDictionary* mMoleculeCount;
}
- (id)initWithTime:(TimeSpan*)time moleculeCount:(NSDictionary*)counts;
- (void)dealloc;

- (NSDictionary*)moleculeCounts;
- (TimeSpan*)timeSinceSimulationStart;
@end
