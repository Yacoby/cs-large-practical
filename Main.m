/**
 * @file 
 *
 * This is the main file with the entry point for the appliction. 
 *
 * NB: It is written using functions rather than using objects as there
 *      isn't anything to gain by using them.
 */
#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"
#import "CommandLineOptionParser.h"
#import "Simulator.h"

#import "OutputStream.h"
#import "SimulationOutputWriter.h"

#import "Logger.h"
#import "Factory.h"

void printAllocatedClasses(){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    printf("%s", GSDebugAllocationList(false));
    [pool drain];
}

CommandLineOptionParser* getOptionsParser(){
    CommandLineOptionParser* cmdLineParser = [[[CommandLineOptionParser alloc] init] autorelease];
    [cmdLineParser addArgumentWithName:@"--trackalloc" ofType:Boolean];
    [cmdLineParser setHelpStringForArgumentKey:@"trackalloc" help:@"Tracks object allocations"];

    [cmdLineParser addArgumentWithName:@"--logfname" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"logfname" help:@"The file name to log to"];

    [cmdLineParser addArgumentWithName:@"--logflevel" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"logflevel" help:@"The log level for the file log. One of debug, info, warn, error "];
    [cmdLineParser setDefaultValueForArgumentKey:@"logflevel" value:@"info"];

    [cmdLineParser addArgumentWithName:@"--logstderrlevel" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"logstderrlevel" help:@"The log level for the stderr log. One of debug, info, warn, error "];
    [cmdLineParser setDefaultValueForArgumentKey:@"logstderrlevel" value:@"error"];

    [cmdLineParser addArgumentWithName:@"--seed" andShortName:@"-s" ofType:Integer];
    [cmdLineParser setHelpStringForArgumentKey:@"seed" help:@"The seed to initialize the random number generator with."];

    [cmdLineParser addArgumentWithName:@"--strict" andShortName:@"-s" ofType:Integer];
    [cmdLineParser setHelpStringForArgumentKey:@"strict" help:@"The seed to initialize the random number generator with."];

    [cmdLineParser addArgumentWithName:@"--wall" ofType:Boolean];
    [cmdLineParser setHelpStringForArgumentKey:@"wall" help:@"Treats script warnings as errors"];

    [cmdLineParser addArgumentWithName:@"input" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"input" help:@"The path to the input script. If not set the input will be read from stdin"];
    [cmdLineParser setRequiredForArgumentKey:@"input" required:NO];

    [cmdLineParser addArgumentWithName:@"--writer" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"writer" help:@"The output writer that defines the format"];
    [cmdLineParser setDefaultValueForArgumentKey:@"writer" value:@"AssignmentCsvWriter"];

    [cmdLineParser addArgumentWithName:@"--aggregator" ofType:String];
    [cmdLineParser setHelpStringForArgumentKey:@"aggregator" help:@"Sets how the output is aggregated"];
    [cmdLineParser setDefaultValueForArgumentKey:@"aggregator" value:@"PassthroughAggregator"];

    return cmdLineParser;
}

SimulationConfiguration* getSimulationConfiguration(CommandLineOptions* options, NSError** err){
    NSString* rawCfgFile = nil;
    if ( [options getOptionWithName:@"input"] != nil ){
        NSString* inputFile = [options getOptionWithName:@"input"];
        rawCfgFile = [NSString stringWithContentsOfFile:inputFile];

        [Logger info:@"Using input from <%@>", inputFile];
    }else{
        NSFileHandle* stdinHandle = [NSFileHandle fileHandleWithStandardInput];
        NSData* cfgData = [NSData dataWithData:[stdinHandle readDataToEndOfFile]];
        rawCfgFile = [[[NSString alloc] initWithData:cfgData encoding:NSASCIIStringEncoding] autorelease];

        [Logger info:@"Using input from stdin"];
    }
    return [ConfigurationTextSerilizer deserilize:rawCfgFile error:err];
}

id<SimulationOutputWriter> getOutputWriter(CommandLineOptions* options, SimulationConfiguration* cfg, NSError** error){
    FileHandleOutputStream* os = nil;
    if ( [options getOptionWithName:@"output"] ){
        NSString* outputFile = [options getOptionWithName:@"output"];
        [[NSFileManager defaultManager] createFileAtPath:outputFile contents:nil attributes:nil];
        os = [[[FileOutputStream alloc] initWithFileName:outputFile] autorelease];

        [Logger info:@"Writing output to file: <%@>", outputFile];
    }else{
        os = [[[FileHandleOutputStream alloc] initWithFileHandle:[NSFileHandle fileHandleWithStandardOutput]] autorelease];
        [Logger info:@"Writing output to stdout"];
    }

    Factory* writerFactory = [[Factory alloc] initFromProtocol:@protocol(SimulationOutputWriter)];
    NSString* writerStr = [options getOptionWithName:@"writer"];
    Class writerClass = [writerFactory classFromString:writerStr error:error];
    if ( writerClass == nil ){
        return nil;
    }
    [writerFactory release];

    return [[[writerClass alloc] initWithStream:os simulationConfiguration:cfg] autorelease];
}

id<SimulationOutputAggregator> getOutputAggregator(CommandLineOptions* options,
                                                   SimulationConfiguration* cfg,
                                                   id<SimulationOutputWriter> writer,
                                                   NSError** error){
    Factory* writerFactory = [[Factory alloc] initFromProtocol:@protocol(SimulationOutputAggregator)];
    Class cls = [writerFactory classFromString:[options getOptionWithName:@"aggregator"] error:error];
    if ( cls == nil ){
        return nil;
    }
    [writerFactory release];
    return [[[cls alloc] initWithWriter:writer] autorelease];
}

UniformRandom* getRandomNumberGenerator(CommandLineOptions* options){
    uint seed = time(NULL);
    if ( [options getOptionWithName:@"seed"] != nil ){
        seed = [[options getOptionWithName:@"seed"] intValue];
    }
    return [[[UniformRandom alloc] initWithSeed:seed] autorelease];
}

void makeLogger(CommandLineOptions* options){
    Logger* logger = [[[Logger alloc] init] autorelease];
    {
        FileHandleOutputStream* os = [[FileHandleOutputStream alloc] initWithFileHandle:[NSFileHandle fileHandleWithStandardError]];
        Log* log = [[StreamLog alloc] initWithStream:os];
        [logger addLog:log];
        LogLevel level = [Logger logLevelFromString:[options getOptionWithName:@"logstderrlevel"]];
        if ( level == LL_UNKNOWN ){
            [log setLogLevel:LL_ERROR];
        }else{
            [log setLogLevel:level];
        }

        [os release];
        [log release];
    }

    NSString* logName = [options getOptionWithName:@"logfname"];
    if ( logName ){
        [[NSFileManager defaultManager] createFileAtPath:logName contents:nil attributes:nil];
        FileOutputStream* fs = [[FileOutputStream alloc] initWithFileName:logName];
        Log* log = [[StreamLog alloc] initWithStream:fs];
        [logger addLog:log];

        LogLevel level = [Logger logLevelFromString:[options getOptionWithName:@"logflevel"]];
        if ( level == LL_UNKNOWN ){
            [log setLogLevel:LL_INFO];
        }else{
            [log setLogLevel:level];
        }

        [fs release];
        [log release];
    }
}

int main(void){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

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

    makeLogger(options);


    NSError* cfgError;
    SimulationConfiguration* cfg = getSimulationConfiguration(options, &cfgError);
    if ( cfg == nil ){
        NSString* errDescription = [cfgError localizedDescription];
        [Logger error:errDescription];
        return 2;
    }
    ConfigurationValidation* validateError = [cfg validate];
    if ( [[validateError errors] count] > 0 ){
        NSString* strErr = [[[validateError errors] allObjects] componentsJoinedByString:@"\n"];
        [Logger error:strErr];
        return 3;
    }
    if ( [[validateError warnings] count] > 0 ){
        NSString* strWarnings = [[[validateError warnings] allObjects] componentsJoinedByString:@"\n"];
        if ( [[options getOptionWithName:@"wall"] boolValue] ){
            [Logger error:strWarnings];
            return 4;
        }else{
            [Logger warn:strWarnings];
        }
    }

    NSError* writerError;
    id<SimulationOutputWriter> writer = getOutputWriter(options, cfg, &writerError);
    if ( !writer ){
        NSString* errDescription = [NSString stringWithFormat:@"Invalid Writer Class: %@", [writerError localizedDescription]];
        [Logger error:errDescription];
        return 5;
    }

    NSError* aggregatorError;
    id<SimulationOutputAggregator> aggregator = getOutputAggregator(options, cfg, writer, &aggregatorError);
    if ( !aggregator ){
        NSString* errDescription = [NSString stringWithFormat:@"Invalid Aggregator Class: %@", [aggregatorError localizedDescription]];
        [Logger error:errDescription];
        return 6;
    }
    UniformRandom* random = getRandomNumberGenerator(options);

    Simulator* simulator = [[[Simulator alloc] initWithCfg:cfg randomGen:random outputAggregator:aggregator] autorelease];
    [simulator runSimulation];

    [pool drain];

    if ( trackObjectAllocations ){
        printAllocatedClasses();
    }

    return 0;
}
