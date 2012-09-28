#include "OutputWriter.h"


@implementation SimpleOutputWriter
- (void)writeToStream:(NSOutputStream*)stream stateHistory:(NSArray*)stateHistory{

    SimulationState* firstState = [stateHistory objectAtIndex:0];

    NSArray* orderedMolecule = [[firstState moleculeCounts] allObjects];

    for ( SimulationState* state in stateHistory ){
        //TODO
        //write time

        //for all molecules, write count
    }

}
@end
