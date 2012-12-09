#import "SimulationOutputAggregator.h"

/**
 * @brief a "small" number used for float comparison
 *
 * Small is relative, in this case the 0.01 of a ms is fairly small and as it is
 * only used for deciding what to output it shouldn't effect the accuracy of the simulation
 */
const double EPSILON = 0.01;

@implementation PassthroughAggregator

- (id)initWithWriter:(id<SimulationOutputWriter>)writer{
    self = [super init];
    if ( self ){
        [writer retain];
        mWriter = writer;
    }
    return self;
}

-(void)dealloc{
    [mWriter release];
    [super dealloc];
}

- (void)stateChangedTo:(SimulationState*)state{
    [mWriter writeToStream:state];
}

- (void)simulationEnded{
}

@end

@implementation HundredMsAggregator
- (id)initWithWriter:(id<SimulationOutputWriter>)writer{
    self = [super init];
    if ( self ){
        [writer retain];
        mWriter = writer;
        mLastLogTime = [[TimeSpan alloc] initFromSeconds:-1]; //using -1 ensures we always log the first state change
    }
    return self;
}

-(void)dealloc{
    [mWriter release];
    [mLastLogTime release];
    [super dealloc];
}

- (void)stateChangedTo:(SimulationState*)state{
    TimeSpan* stateTime = [state timeSinceSimulationStart];

    BOOL hasHundredMsSinceLastLogTime = [stateTime totalMilliseconds] > [mLastLogTime totalMilliseconds] + 100;
    if ( hasHundredMsSinceLastLogTime ){
        [mWriter writeToStream:state];
        double newLastLogMs = [stateTime totalMilliseconds] - floor(([stateTime totalMilliseconds]/100)*100);
        [mLastLogTime setTotalMilliseconds:newLastLogMs];
    }
}
- (void)simulationEnded{
}
@end

@implementation ExactHundredMsAggregator
- (id)initWithWriter:(id<SimulationOutputWriter>)writer{
    self = [super init];
    if ( self ){
        [writer retain];
        mWriter = writer;
        mLastLogTime = [[TimeSpan alloc] initFromSeconds:0];
        mLastState = nil;
    }
    return self;
}

-(void)dealloc{
    [mWriter release];
    [mLastLogTime release];
    [mLastState release];
    [super dealloc];
}

- (void)stateChangedTo:(SimulationState*)state{
    TimeSpan* currentStateTime = [state timeSinceSimulationStart];

    while ( mLastState && [mLastLogTime totalMilliseconds] < [currentStateTime totalMilliseconds] ){
        [mLastState setTimeSinceSimulationStart:mLastLogTime];
        [mWriter writeToStream:mLastState];
        [mLastLogTime addMilliseconds:100];
    }
    [mLastState release];
    mLastState = [state mutableCopy];
}

- (void)simulationEnded{
    TimeSpan* lastStateTime = [mLastState timeSinceSimulationStart];

    TimeSpan* lastStateTimePastNextLogTime = [lastStateTime mutableCopy];
    [lastStateTimePastNextLogTime addMilliseconds:100];

    //EPSILON is required to add some small difference to the time to ensure that the floating point
    //comparison works when the numbers are the same. This issue was only reproducable on some Systems.
    while ( mLastState && [mLastLogTime totalMilliseconds] + EPSILON <  [lastStateTimePastNextLogTime totalMilliseconds] ){
        [mLastState setTimeSinceSimulationStart:mLastLogTime];
        [mWriter writeToStream:mLastState];
        [mLastLogTime addMilliseconds:100];
    }

    [lastStateTimePastNextLogTime release];
}
@end
