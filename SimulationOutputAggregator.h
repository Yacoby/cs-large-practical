#import <Foundation/Foundation.h>
#import "SimulationOutputWriter.h"
#import "TimeSpan.h"

/**
 * @brief Allows the aggregation of state changes
 * 
 * This provides a layer between the simulator and the output writer to allow
 * the state changes to be aggregated in some form to allow different output
 *
 * An example of what could be done is to only output the current state every
 * second
 */
@protocol SimulationOutputAggregator <NSObject>
- (id)initWithWriter:(id<SimulationOutputWriter>)writer;

/**
 * @brief Called by the simulator when the state changes
 * @param state the new state
 *
 * @note If you want to retain the state beyond the lifetime of the function
 * then you must make a copy of the state
 */
- (void)stateChangedTo:(SimulationState*)state;

- (void)simulationEnded;
@end

/**
 * @brief All state changes are written to the output
 */
@interface PassthroughAggregator : NSObject<SimulationOutputAggregator>{
    id<SimulationOutputWriter> mWriter;
}
- (id)initWithWriter:(id<SimulationOutputWriter>)writer;
- (void)dealloc;
- (void)stateChangedTo:(SimulationState*)state;
- (void)simulationEnded;
@end

/**
 * @brief This writes the state at maximum once every simulated 100ms
 */
@interface HundredMsAggregator : NSObject<SimulationOutputAggregator>{
    id<SimulationOutputWriter> mWriter;
    /**
     * @brief holds the simulation time of the last write. The epoch is the simulation start
     */
    TimeSpan* mLastLogTime;
}
- (id)initWithWriter:(id<SimulationOutputWriter>)writer;
- (void)dealloc;
- (void)stateChangedTo:(SimulationState*)state;
- (void)simulationEnded;
@end

/**
 * @brief This writes the state exactly once every simulated 100ms
 */
@interface ExactHundredMsAggregator : NSObject<SimulationOutputAggregator>{
    /**
     * Holds the last state of the simulation
     */
    SimulationState* mLastState;

    id<SimulationOutputWriter> mWriter;

    /**
     * @brief holds the simulation time of the last write. The epoch is the simulation start
     */
    TimeSpan* mLastLogTime;
}

- (id)initWithWriter:(id<SimulationOutputWriter>)writer;
- (void)dealloc;

/**
 * @brief writes the mLastState from mLastLogTime until the current state
 */
- (void)stateChangedTo:(SimulationState*)state;

/**
 * @brief writes mLastState as it is currently unwritten
 */
- (void)simulationEnded;
@end
