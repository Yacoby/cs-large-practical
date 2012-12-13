#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "SimulationOutputAggregator.h"
#import "Random.h"

/**
 * @brief hold a reaction and its assoicated rates for use in an NSArray
 *
 * This is used to avoid having to maintian more than one NSMutable arrays for the reaction
 * and the rate which vaslty increasses the possibility for bugs.
 *
 * The partial sum is used for holding the sum of rates up to the point where
 * this reaction has been considered. As such it is only really useful when
 * in an array.
 */
@interface ReactionWithRate : NSObject{
    ReactionDefinition* mReaction;
    double mRate;
    double mPartialRate;
}
- (id)initWithReaction:(ReactionDefinition*)reaction rate:(double)rate;
- (void)dealloc;

- (ReactionDefinition*)reaction;

- (double)rate;
- (void)setRate:(double)rate;

/**
 * @brief sets the rate that has been calculated up to the point where this reaction is considered
 */
- (double)partialSum;
- (void)setPartialSum:(double)rate;
@end

/**
 * @brief this holds the internal state of the simulator and is responsible for ensuring consistency
 * 
 * As the algorithm got more complex, we needed to be able to provide a simpler interface
 * that guaranteed state consistency. 
 *
 * Internally this impelements SDM, LDM and DependencyGraph as methods of increasing
 * performance with larger systems.
 */
@interface SimulatorInternalState : NSObject{
    /**
     * @brief An array of all reactions and rates, held in ReactionWithRate
     */
    NSMutableArray* mReactions;

    /**
     * @brief a set of reactions that do not have a valid rate
     *
     * These are all of type ReactionWithRate*
     */
    NSMutableSet* mDirtyReactions;

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

    BOOL mUseSortedDirectMethod;
    BOOL mUseDependencyGraph;
    BOOL mUseLogrithmicDirectMethod;
}
- (id)init;
/**
 * @param sdm use Simple Direct Method to improve the performance of larger systems
 * @param ldm use Logrithmic Direct Method to improve the performance of very large systems by 
 *          performing binary search when finding what reaction to apply
 * @param dependencyGraph avoid updating reaction rates that haven't changed
 */
- (id)initWithSDM:(BOOL)sdm ldm:(BOOL)ldm dependencyGraph:(BOOL)graph;
- (void)dealloc;

/**
 * @brief sets all Reaction that use this reaction as being "dirty" and needing updating
 */
- (void)setDirty:(ReactionDefinition*)reaction;
/**
 * @return returns YES if the reaction is in the list of reactions with rates that need updating
 * @note this is only used for testing and so is a very slow function
 */
- (BOOL)isDirty:(ReactionDefinition*)reaction;

/**
 * @brief ensures all rates are up to date, using state to update them if required
 *
 * Depending on the settings used, this may not update all states, but the post condition
 * that all states are as they should be will hold
 */
- (void)updateRates:(SimulationState*)state;

/**
 * @brief adds a reaction to the internal state
 * @param reaction the reaction to add
 * 
 * This should be done intitially as adding reactions when the state is
 * anything but the start state is undefined
 */
- (void)addReaction:(ReactionDefinition*)reaction;
/**
 * @brief builds the graph of all the dependencies of the current reactions.
 * 
 * This should be called after all the reactions have been added to the object
 * if dependency-graph is enabled.
 */
- (void)buildRequirementsGraph;

/**
 * @brief gets the sum of all the reaction rates
 * @param state the current state of the system
 */
- (double)reactionRateSumForState:(SimulationState*)state;

/**
 * @brief gets the reaction for the given lower bound
 * @param lowerBound the value to get the reaction for
 */
- (ReactionDefinition*)reactionForBound:(double)lowerBound;

/**
 * @brief returns the reaction index that such that it is the lowest index greater than the upper bound
 * @param lowerBound the bound of the rate
 */
- (int)findReactionIndex:(double)lowerBound;
/**
 * @brief implementation of findReactionIndex
 * 
 * Preforms a linear search on the rates
 */
- (int)findReactionIndexWithLinearSearch:(double)lowerBound;
/**
 * @brief implementation of findReactionIndex, needs mUseLogrithmicDirectMethod to be enabled
 *
 * mUseLogrithmicDirectMethod ensures we have set the partial sums which allows
 * us to use a binary search. (The parital sums are guarentted to be increasing as the
 * rate is always positive)
 */
- (int)findReactionIndexWithBinarySearch:(double)lowerBound;
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
 * @return false if there was no reaction that it was possible to run or if the next reaction would exceed the stop time
 */
- (BOOL)runSimulationStep:(SimulationState*)state stopTime:(TimeSpan*)stopTime;
@end

