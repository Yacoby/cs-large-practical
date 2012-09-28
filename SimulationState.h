#import <Foundation/Foundation.h>
#import "TimeSpan.h"

@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSDictionary* mMoleculeCount;
}
- (NSDictionary*)moleculeCounts;
- (TimeSpan*)timeSinceSimulationStart;
@end
