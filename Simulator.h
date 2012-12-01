#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "SimulationOutputAggregator.h"
#import "Random.h"

/**
 * @brief the simulator that runs the simulation on the given input
 */
@interface Simulator : NSObject {
    SimulationConfiguration* mCfg;
    NSMutableArray* mReactions;
    id <SimulationOutputAggregator> mAggregator;
    id <Random> mRandom;
}
/**
 * @param cfg the simulation configuration file
 * @param random The random number generator to be used by the simulation
 * @param outputAggregator The aggregator where the state changes are sent
 */
- (id)initWithCfg:(SimulationConfiguration*)cfg randomGen:(id <Random>)random outputAggregator:(id <SimulationOutputAggregator>)aggregator;
- (void)dealloc;

/**
 * @brief runs the simulation with the objects given on object initialization
 * 
 * State updates are sent to the SimulationOutputAggregator
 */
- (void)runSimulation;

/**
 * @brief runs a single simulation step
 * @param state this is the state of the simulation before the call. This parameter will be updated to the current simulation state
 * @return false if there was no reaction that it was possible to run
 */
- (BOOL)runSimulationStep:(SimulationState*)state;
@end

