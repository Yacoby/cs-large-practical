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

    if ( [stateTime totalMilliseconds] > [mLastLogTime totalMilliseconds] + 100 ){
        [mWriter writeToStream:state];
        double newLastLogMs = [stateTime totalMilliseconds] - floor(([stateTime totalMilliseconds]/100)*100);
        [mLastLogTime setTotalMilliseconds:newLastLogMs];
    }

}
@end
