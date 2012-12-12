#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "SimulationOutputAggregator.h"
#import "Random.h"

/**
 * @brief this holds the internal state of the simulator and is responsible for ensuring consistency
 * 
 * As the algorithm got more complex, we needed to be able to provide a simpler interface
 * that guaranteed state consistency
 *
 * Internally this implements Sorted Direct Method and has a dependency graph to
 * minimize propensity updates.
 */
@interface SimulatorInternalState : NSObject{
    /**
     * @brief an array of NSNumber that holds the rate for each reaction
     */
    NSMutableArray* mReactionRates;

    /**
     * @brief An array of all reactions. 
     *
     * This is stored in the same order as mReactionRates.
     */
    NSMutableArray* mReactions;

    /**
     * @brief a set of reactions that do not have a valid rate
     */
    NSMutableSet*   mDirtyReactions;

    /**
     * @brief A graph with ReactionDefinition as nodes, and edges for reaction rate dependency.
     *
     * This graph allows easy working out of what rate need to be updated when
     * the reaction is applied. If a reaction is applied then we need to update all
     * nodes of path length 1 away from the current reaction node
     * 
     * Using an adjacency list this is incredibly fast, so this is a dictionary
     * with keys as a NSValue pointer to the reaction and values as a set of dependant reactions
     */
    NSMutableDictionary* mReactionRateDepencies;

    /**
     * @brief dictionary of a pointer to a reaction to the current index in mReactions
     */
    NSMutableDictionary* mReactionToIdx;

    BOOL mUseSortedDirectMethod;
    BOOL mUseDependencyGraph;
}
- (id)init;
- (id)initWithSMO:(BOOL)smo dependencyGraph:(BOOL)graph;
- (void)dealloc;

- (void)setDirty:(ReactionDefinition*)reaction;
- (BOOL)isDirty:(ReactionDefinition*)reaction;
- (void)updateDirty:(SimulationState*)state;

- (void)addReaction:(ReactionDefinition*)reaction;
- (void)buildRequirementsGraph;

- (double)reactionRate:(SimulationState*)state;
- (ReactionDefinition*)reactionForValue:(double)upperBound simulationState:(SimulationState*)state;
@end

/**
 * @brief the simulator that runs the simulation on the given input
 */
@interface Simulator : NSObject {
    SimulatorInternalState* mInternalState;
    SimulationConfiguration* mCfg;
    id <SimulationOutputAggregator> mAggregator;
    id <Random> mRandom;
}
/**
 * @param cfg the simulation configuration file
 * @param random The random number generator to be used by the simulation
 * @param aggregator The aggregator where the state changes are sent
 */
- (id)initWithInternals:(SimulatorInternalState*)internals
                    cfg:(SimulationConfiguration*)cfg
              randomGen:(id <Random>)random
       outputAggregator:(id <SimulationOutputAggregator>)aggregator;
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

