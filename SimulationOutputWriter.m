#import <Foundation/Foundation.h>
#import "SimulationOutputWriter.h"

@implementation RfcCsvWriter
- (id)initWithStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg{
    self = [super init];
    if ( self != nil ){
        [stream retain];
        mOutputStream = stream;
        mOrderedMolecules = [[cfg orderedMolecules] retain];

        [self writeHeaders];
    }
    return self;
}

- (void)writeHeaders{
    [mOutputStream write:@"t"];
    if ( [mOrderedMolecules count] ){
        [mOutputStream write:@", "];
        [mOutputStream write:[mOrderedMolecules componentsJoinedByString:@", "]];
    }
    [mOutputStream write:@"\n"];
}

- (void)dealloc{
    [mOrderedMolecules release];
    [mOutputStream release];
    [super dealloc];
}

- (void)writeToStream:(SimulationState*)state{
    TimeSpan* time = [state timeSinceSimulationStart];
    [mOutputStream write:[NSString stringWithFormat:@"%f", [time totalSeconds]]];

    NSDictionary* moleculeCounts = [state moleculeCounts];
    for ( NSString* molecule in mOrderedMolecules ){
        uint count = [[moleculeCounts objectForKey:molecule] intValue];
        [mOutputStream write:[NSString stringWithFormat:@", %i", count]];
    }
    [mOutputStream write:@"\n"];
}
@end

@implementation AssignmentCsvWriter
- (void)writeHeaders{
    [mOutputStream write:@"#"];
    [super writeHeaders];
}
- (void)writeToStream:(SimulationState*)state{
    [super writeToStream:state];
}
@end
