#import "SimulationOutputAggregator.h"

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

    while ( mLastState && [mLastLogTime totalMilliseconds] <  [lastStateTimePastNextLogTime totalMilliseconds] ){
        [mLastState setTimeSinceSimulationStart:mLastLogTime];
        [mWriter writeToStream:mLastState];
        [mLastLogTime addMilliseconds:100];
    }

    [lastStateTimePastNextLogTime release];
}
@end
