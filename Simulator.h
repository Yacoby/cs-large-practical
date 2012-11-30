#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "SimulationOutputAggregator.h"
#import "Random.h"

@interface Simulator : NSObject {
    SimulationConfiguration* mCfg;
    NSMutableArray* mReactions;
    id <SimulationOutputAggregator> mAggregator;
    id <Random> mRandom;
}
- (id)initWithCfg:(SimulationConfiguration*)cfg randomGen:(id <Random>)random outputAggregator:(id <SimulationOutputAggregator>)aggregator;
- (void)dealloc;
- (void)runSimulation;
- (BOOL)runSimulationStep:(SimulationState*)state;
@end

