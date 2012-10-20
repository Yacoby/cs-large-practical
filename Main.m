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
    [cmdLineParser setHelpStringForArgumentKey:@"trackalloc" help:@"Tracks object allocations"];

    [cmdLineParser addArgumentWithName:@"--seed" andShortName:@"-s" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"seed" help:@"The seed to initialize the random number generator with."];

    [cmdLineParser addArgumentWithName:@"--output" andShortName:@"-o" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"output" help:@"The file to output the results of the simulation to. If not set output will be sent to stdout"];

    [cmdLineParser addArgumentWithName:@"input" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"input" help:@"The path to the input script. If not set the input will be read from stdin"];
    [cmdLineParser setRequiredForArgumentKey:@"input" required:NO];

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

    if ( [options shouldPrintHelpText] ){
        fprintf(stdout, "%s\n", [[options helpText] cStringUsingEncoding:NSASCIIStringEncoding]);
        return 0;
    }

    if ( [[options getOptionWithName:@"help"] boolValue] ){
        fprintf(stderr, "%s\n", [[cmdLineParser helpText] cStringUsingEncoding:NSASCIIStringEncoding]);
        return 0;
    }

    BOOL trackObjectAllocations = [[options getOptionWithName:@"trackalloc"] boolValue];
    GSDebugAllocationActive(trackObjectAllocations);

    NSString* rawCfgFile = nil;
    if ( [options getOptionWithName:@"input"] != nil ){
        NSString* inputFile = [options getOptionWithName:@"input"];
        rawCfgFile = [NSString stringWithContentsOfFile:inputFile];
    }else{
        NSFileHandle* stdinHandle = [NSFileHandle fileHandleWithStandardInput];
        NSData* cfgData = [NSData dataWithData:[stdinHandle readDataToEndOfFile]];
        rawCfgFile = [[[NSString alloc] initWithData:cfgData encoding:NSASCIIStringEncoding] autorelease];
    }
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:rawCfgFile];

    uint seed = time(NULL);
    if ( [options getOptionWithName:@"seed"] != nil ){
        seed = [[options getOptionWithName:@"seed"] intValue];
    }
    UniformRandom* random = [[UniformRandom alloc] initWithSeed:seed];


    FileHandleOutputStream* os = nil;
    if ( [options getOptionWithName:@"output"] ){
        NSString* outputFile = [options getOptionWithName:@"output"];
        [[NSFileManager defaultManager] createFileAtPath:outputFile contents:nil attributes:nil];
        os = [[FileOutputStream alloc] initWithFileName:@"output"];
    }else{
        os = [[FileHandleOutputStream alloc] initWithFileHandle:[NSFileHandle fileHandleWithStandardOutput]];
    }
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
