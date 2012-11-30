#import <Foundation/Foundation.h>
#import "SimulationOutputWriter.h"

@implementation SimpleSimulationOutputWriter
- (id)initWithStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg{
    self = [super init];
    if ( self != nil ){
        [stream retain];
        mOutputStream = stream;

        mOrderedMolecules = [[cfg orderedMolecules] retain];
        [mOutputStream write:@"t"];
        for ( NSString* molecule in mOrderedMolecules ){
            [mOutputStream write:[NSString stringWithFormat:@", %@", molecule]];
        }
        [mOutputStream write:@"\n"];
    }
    return self;
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
