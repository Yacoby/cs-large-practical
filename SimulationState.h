#import <Foundation/Foundation.h>

@interface SimulationState : NSObject{
    TimeSpan mTimeSinceSimulationStart;
    NSCountedSet* mMoleculeCount;
}
@end
