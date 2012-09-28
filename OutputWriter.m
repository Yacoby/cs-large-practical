#import <Foundation/Foundation.h>
#import "OutputWriter.h"

@implementation SimpleOutputWriter
+ (void)writeToStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg stateHistory:(NSArray*)stateHistory{
    NSArray* orderedMolecules = [[[cfg molecules] allObjects] sortedArrayUsingSelector:@selector(compare:)];

    [stream write:@"t"];
    for ( NSString* molecule in orderedMolecules ){
        [stream write:[NSString stringWithFormat:@", %@", molecule]];
    }
    [stream write:@"\n"];

    for ( SimulationState* state in stateHistory ){
        TimeSpan* time = [state timeSinceSimulationStart];
        [stream write:[NSString stringWithFormat:@"%f", [time totalSeconds]]];

        NSDictionary* moleculeCounts = [state moleculeCounts];
        for ( NSString* molecule in orderedMolecules ){
            uint count = [[moleculeCounts objectForKey:molecule] intValue];
            [stream write:[NSString stringWithFormat:@", %i", count]];
        }
        [stream write:@"\n"];
    }
}
@end
