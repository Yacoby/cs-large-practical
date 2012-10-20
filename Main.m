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
    [cmdLineParser addArgumentWithName:@"--trackalloc" ofType:Boolean];
    [cmdLineParser addArgumentWithName:@"--seed" andShortName:@"-s" ofType:String];
    [cmdLineParser addArgumentWithName:@"input" ofType:String];

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

    NSString* inputFile = [options getOptionWithName:@"input"];

    uint seed = time(NULL);
    if ( [options getOptionWithName:@"seed"] != nil ){
        seed = [[options getOptionWithName:@"seed"] intValue];
    }
    UniformRandom* random = [[UniformRandom alloc] initWithSeed:seed];

    NSString *fileString = [NSString stringWithContentsOfFile:inputFile];
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:fileString];

    [[NSFileManager defaultManager] createFileAtPath:@"output" contents:nil attributes:nil];
    FileOutputStream* os = [[FileOutputStream alloc] initWithFileName:@"output"];
    SimpleOutputWriter* writer = [[SimpleOutputWriter alloc] initWithStream:os simulationConfiguration:cfg];

    Simulator* simulator = [[Simulator alloc] initWithCfg:cfg randomGen:random outputWriter:writer];
    [simulator runSimulation];

    [simulator release];
    [random release];
    [os release];
    [writer release];

    [pool drain];

    if ( trackObjectAllocations ){
        printAllocatedClasses();
    }

    return 0;
}
