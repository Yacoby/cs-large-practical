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

    [SimpleOutputWriter write:stream simulationConfiguration:cfg simulationHistory:history];

    NSString* expectedOutput = @"t, A, B, C\n";

    PASS_EQUAL([stream memory], expectedOutput, "");
}

int main()
{
    START_SET("OutputWriter")
        writeToStream_WhenHasNoData_WritesOnlyHeaders;
    END_SET("OutputWriter")

    return 0;
}
