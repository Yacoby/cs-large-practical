#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"
#import "CommandLineOptionParser.h"
#import "Simulator.h"

#import "OutputStream.h"
#import "OutputWriter.h"

void countAllocationsForAllClasses(){
    int numClasses;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class* classes = malloc(sizeof(Class) * numClasses);
        (void) objc_getClassList (classes, numClasses);
        int i;
        for (i = 0; i < numClasses; i++) {
            GSDebugAllocationActiveRecordingObjects(classes[i]);
        }
        free(classes);
    }
}

void printAllocatedClasses(){
    printf(GSDebugAllocationList(false));
}

int main(void){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CommandLineOptionParser* cmdLineParser = [[CommandLineOptionParser alloc] init];
    [cmdLineParser addArgumentWithName:@"trackalloc" isBoolean:YES];
    [cmdLineParser addArgumentWithName:@"seed" andShortName:@"s"];

    NSArray* processArguments = [[NSProcessInfo processInfo] arguments];
    NSArray* cmdLineArgs = [processArguments subarrayWithRange:NSMakeRange(1, [processArguments count] - 1)];

    NSError* err;
    CommandLineOptions* options = [cmdLineParser parse:cmdLineArgs error:&err];
    [cmdLineParser release];

    if ( options == nil ){
        NSString* errDescription = [err localizedDescription];
        fprintf(stderr, "%s\n", [errDescription cStringUsingEncoding:NSASCIIStringEncoding]);
        return 1;
    }

    BOOL trackObjectAllocations = [[options getOptionWithName:@"trackalloc"] boolValue];
    GSDebugAllocationActive(trackObjectAllocations);

    NSArray* remainingArguments = [options getRemainingArguments];
    NSString* inputFile = [remainingArguments objectAtIndex:0];

    NSString *fileString = [NSString stringWithContentsOfFile:inputFile];
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:fileString];
    Simulator* simulator = [[Simulator alloc] initWithCfg:cfg outputWriter:nil];
    [simulator runSimulation];

    //MemoryOutputStream* os = [[MemoryOutputStream alloc] init];
    //[SimpleOutputWriter writeToStream:os simulationConfiguration:cfg stateHistory:simulationStates];
    //fprintf(stdout, "%s\n", [[os memory] cStringUsingEncoding:NSASCIIStringEncoding]);

    [simulator release];
    //[os release];

    [pool drain];

    if ( trackObjectAllocations ){
        printAllocatedClasses();
    }

    return 0;
}
