#import <Foundation/Foundation.h>
#import "TimeSpan.h"

@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSDictionary* mMoleculeCount;
}
- (id)initWithTime:(TimeSpan*)time moleculeCount:(NSDictionary*)counts;
- (void)dealloc;
- (NSDictionary*)moleculeCounts;
- (TimeSpan*)timeSinceSimulationStart;
@end
