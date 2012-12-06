#import "Testing.h"
#import "SimulationOutputWriter.h"
#import "SimulationConfiguration.h"

void writeToStream_init_WritesOnlyHeaders(){
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];
    [cfg addMoleculeCount:@"A" count:1];
    [cfg addMoleculeCount:@"B" count:0];
    [cfg addMoleculeCount:@"C" count:5];

    MemoryOutputStream* stream = [[[MemoryOutputStream alloc] init] autorelease];

    [[[RfcCsvWriter alloc] initWithStream:stream simulationConfiguration:cfg] autorelease];
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
    NSMutableDictionary* state = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:aCount, @"A", bCount, @"B", nil] autorelease];
    SimulationState* historyItem = [[[SimulationState alloc] initWithTime:timeSpan moleculeCount:state] autorelease];

    MemoryOutputStream* stream = [[[MemoryOutputStream alloc] init] autorelease];
    RfcCsvWriter* outputWriter = [[[RfcCsvWriter alloc] initWithStream:stream simulationConfiguration:cfg] autorelease];
    [outputWriter writeToStream:historyItem];

    NSString* expectedOutput = @"t, A, B\n0.000000, 1, 2\n";

    PASS_EQUAL([stream memory], expectedOutput, "");
}

void assignmentCsvWriteToStream_init_WritesOnlyHeaders(){
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];
    [cfg addMoleculeCount:@"A" count:1];
    [cfg addMoleculeCount:@"B" count:0];
    [cfg addMoleculeCount:@"C" count:5];

    MemoryOutputStream* stream = [[[MemoryOutputStream alloc] init] autorelease];

    [[[AssignmentCsvWriter alloc] initWithStream:stream simulationConfiguration:cfg] autorelease];
    NSString* expectedOutput = @"#t, A, B, C\n";

    PASS_EQUAL([stream memory], expectedOutput, "");
}
int main(){
    START_SET("SimulationOutputWriter")
        writeToStream_init_WritesOnlyHeaders();
        writeToStream_WhenHasOneItemOfHistory_WritesHeadersAndThatItem();
        assignmentCsvWriteToStream_init_WritesOnlyHeaders();
    END_SET("SimulationOutputWriter")

    return 0;
}
