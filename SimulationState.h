#import <Foundation/Foundation.h>
#import "TimeSpan.h"

@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSCountedSet* mMoleculeCount;
}
- (NSCountedSet*)moleculeCounts;
- (TimeSpan*)timeSinceSimulationStart;
@end
