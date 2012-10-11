#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"

@interface Simulator : NSObject {
    SimulationConfiguration* mCfg;
    NSMutableArray* mReactions;
}
- (id)initWithCfg:(SimulationConfiguration*)cfg;
- (void)dealloc;
- (NSArray*)runSimulation;
- (SimulationState*)runSimulationStep:(SimulationState*)state;
@end

