#import "Testing.h"
#import "OutputWriter.h"
#import "SimulationConfiguration.h"

void writeToStream_WhenHasNoData_WritesOnlyHeaders(){
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];
    [cfg addMoleculeCount:@"A" count:1];
    [cfg addMoleculeCount:@"B" count:0];
    [cfg addMoleculeCount:@"C" count:5];

    NSArray* history = [[[NSArray alloc] init] autorelease];

    MemoryOutputStream* stream = [[[MemoryOutputStream alloc] init] autorelease];

    [SimpleOutputWriter writeToStream:stream simulationConfiguration:cfg stateHistory:history];

    NSString* expectedOutput = @"t, A, B, C\n";

    PASS_EQUAL([stream memory], expectedOutput, "");
}

void writeToStream_WhenHasOneItemOfHistory_WritesHeadersAndThatItem(){
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];
    [cfg addMoleculeCount:@"A" count:1];
    [cfg addMoleculeCount:@"B" count:0];

    TimeSpan* timeSpan = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    NSNumber* aCount = [[[NSNumber alloc] initWithInt:1] autorelease];
    NSNumber* bCount = [[[NSNumber alloc] initWithInt:2] autorelease];
    NSDictionary* state = [[[NSDictionary alloc] initWithObjectsAndKeys:aCount, @"A", bCount, @"B", nil] autorelease];
    SimulationState* historyItem = [[[SimulationState alloc] initWithTime:timeSpan moleculeCount:state] autorelease];

    NSArray* history = [[[NSMutableArray alloc] initWithObjects:historyItem, nil] autorelease];

    MemoryOutputStream* stream = [[[MemoryOutputStream alloc] init] autorelease];

    [SimpleOutputWriter writeToStream:stream simulationConfiguration:cfg stateHistory:history];

    NSString* expectedOutput = @"t, A, B\n0.000000, 1, 2\n";

    PASS_EQUAL([stream memory], expectedOutput, "");
}
int main()
{
    START_SET("OutputWriter")
        writeToStream_WhenHasNoData_WritesOnlyHeaders();
        writeToStream_WhenHasOneItemOfHistory_WritesHeadersAndThatItem();
    END_SET("OutputWriter")

    return 0;
}
