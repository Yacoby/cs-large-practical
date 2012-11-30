#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"
#import "CommandLineOptionParser.h"
#import "Simulator.h"

#import "OutputStream.h"
#import "OutputWriter.h"

#import "Logger.h"

void printAllocatedClasses(){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    printf(GSDebugAllocationList(false));
    [pool drain];
}

CommandLineOptionParser* getOptionsParser(){
    CommandLineOptionParser* cmdLineParser = [[[CommandLineOptionParser alloc] init] autorelease];
    [cmdLineParser addArgumentWithName:@"--trackalloc" ofType:Boolean];
    [cmdLineParser setHelpStringForArgumentKey:@"trackalloc" help:@"Tracks object allocations"];

    [cmdLineParser addArgumentWithName:@"--seed" andShortName:@"-s" ofType:Integer];
    [cmdLineParser setHelpStringForArgumentKey:@"seed" help:@"The seed to initialize the random number generator with."];

    [cmdLineParser addArgumentWithName:@"--output" andShortName:@"-o" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"output" help:@"The file to output the results of the simulation to. If not set output will be sent to stdout"];

    [cmdLineParser addArgumentWithName:@"input" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"input" help:@"The path to the input script. If not set the input will be read from stdin"];
    [cmdLineParser setRequiredForArgumentKey:@"input" required:NO];
    return cmdLineParser;
}

SimulationConfiguration* getSimulationConfiguration(CommandLineOptions* options, NSError** err){
    NSString* rawCfgFile = nil;
    if ( [options getOptionWithName:@"input"] != nil ){
        NSString* inputFile = [options getOptionWithName:@"input"];
        rawCfgFile = [NSString stringWithContentsOfFile:inputFile];
    }else{
        NSFileHandle* stdinHandle = [NSFileHandle fileHandleWithStandardInput];
        NSData* cfgData = [NSData dataWithData:[stdinHandle readDataToEndOfFile]];
        rawCfgFile = [[[NSString alloc] initWithData:cfgData encoding:NSASCIIStringEncoding] autorelease];
    }
    return [ConfigurationTextSerilizer deserilize:rawCfgFile error:err];
}

SimpleOutputWriter* getOutputWriter(CommandLineOptions* options, SimulationConfiguration* cfg){
    FileHandleOutputStream* os = nil;
    if ( [options getOptionWithName:@"output"] ){
        NSString* outputFile = [options getOptionWithName:@"output"];
        [[NSFileManager defaultManager] createFileAtPath:outputFile contents:nil attributes:nil];
        os = [[[FileOutputStream alloc] initWithFileName:@"output"] autorelease];
    }else{
        os = [[[FileHandleOutputStream alloc] initWithFileHandle:[NSFileHandle fileHandleWithStandardOutput]] autorelease];
    }
    return [[[SimpleOutputWriter alloc] initWithStream:os simulationConfiguration:cfg] autorelease];
}

UniformRandom* getRandomNumberGenerator(CommandLineOptions* options){
    uint seed = time(NULL);
    if ( [options getOptionWithName:@"seed"] != nil ){
        seed = [[options getOptionWithName:@"seed"] intValue];
    }
    return [[[UniformRandom alloc] initWithSeed:seed] autorelease];
}

int main(void){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    Logger* logger = [[[Logger alloc] init] autorelease];
    [[NSFileManager defaultManager] createFileAtPath:@"simulation.log" contents:nil attributes:nil];
    FileOutputStream* fs = [[FileOutputStream alloc] initWithFileName:@"simulation.log"];
    Log* fileLog = [[StreamLog alloc] initWithStream:fs];
    [logger addLog:fileLog];

    [fs release];
    [fileLog release];

    [Logger error:@"Starting Up"];

    CommandLineOptionParser* cmdLineParser = getOptionsParser();
    NSArray* processArguments = [[NSProcessInfo processInfo] arguments];
    NSArray* cmdLineArgs = [processArguments subarrayWithRange:NSMakeRange(1, [processArguments count] - 1)];

    NSError* err;
    CommandLineOptions* options = [cmdLineParser parse:cmdLineArgs error:&err];
    if ( options == nil ){
        NSString* errDescription = [err localizedDescription];
        fprintf(stderr, "%s\n", [errDescription cStringUsingEncoding:NSASCIIStringEncoding]);
        return 1;
    }

    if ( [options shouldPrintHelpText] ){
        fprintf(stdout, "%s\n", [[options helpText] cStringUsingEncoding:NSASCIIStringEncoding]);
        return 0;
    }

    BOOL trackObjectAllocations = [[options getOptionWithName:@"trackalloc"] boolValue];
    GSDebugAllocationActive(trackObjectAllocations);

    NSError* cfgError;
    SimulationConfiguration* cfg = getSimulationConfiguration(options, &cfgError);
    if ( cfg == nil ){
        NSString* errDescription = [cfgError localizedDescription];
        fprintf(stderr, "%s\n", [errDescription cStringUsingEncoding:NSASCIIStringEncoding]);
        return 2;
    }
    NSError* validateError = [cfg validate];
    if ( validateError ){
        NSString* errDescription = [validateError localizedDescription];
        fprintf(stderr, "%s\n", [errDescription cStringUsingEncoding:NSASCIIStringEncoding]);
        return 3;
    }

    SimpleOutputWriter* writer = getOutputWriter(options, cfg);
    UniformRandom* random = getRandomNumberGenerator(options);

    Simulator* simulator = [[[Simulator alloc] initWithCfg:cfg randomGen:random outputWriter:writer] autorelease];
    [simulator runSimulation];

    [pool drain];

    if ( trackObjectAllocations ){
        printAllocatedClasses();
    }

    return 0;
}
