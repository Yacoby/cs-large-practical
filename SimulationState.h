#import <Foundation/Foundation.h>
#import "TimeSpan.h"

@interface SimulationState : NSObject{
    TimeSpan* mTimeSinceSimulationStart;
    NSCountedSet* mMoleculeCount;
}
@end
