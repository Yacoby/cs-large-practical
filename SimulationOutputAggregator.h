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
- (void)stateChangedTo:(SimulationState*)state;
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
@end

@interface HundredMsAggregator : NSObject<SimulationOutputAggregator>{
    id<SimulationOutputWriter> mWriter;
    TimeSpan* mLastLogTime;
}
- (id)initWithWriter:(id<SimulationOutputWriter>)writer;
- (void)dealloc;
- (void)stateChangedTo:(SimulationState*)state;
@end
