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
