#import <Foundation/Foundation.h>
#import "OutputWriter.h"

@implementation SimpleOutputWriter
- (void)writeToStream:(id <OutputStream>)stream stateHistory:(NSArray*)stateHistory{

    SimulationState* firstState = [stateHistory objectAtIndex:0];

    NSArray* orderedMolecules = [[firstState moleculeCounts] allKeys];

    for ( SimulationState* state in stateHistory ){
        TimeSpan* time = [state timeSinceSimulationStart];
        [stream write:[NSString stringWithFormat:@"%f", [time totalSeconds]]];

        //TODO
        //NSDictionary* moleculeCounts = [state moleculeCounts];
        for ( NSString* molecule in orderedMolecules ){
            //write string and comma
        }
    }
}
@end
