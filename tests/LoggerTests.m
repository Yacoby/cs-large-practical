#import "Testing.h"
#import "TestingExtension.h"
#import "Logger.h"

void warn_WhenCallsWarn_PassesMsgToLog(){
    Logger* underTest = [[Logger alloc] init];

    MemoryOutputStream* os = [[[MemoryOutputStream alloc] init] autorelease];
    Log* log = [[[StreamLog alloc] initWithStream:os] autorelease];

    [underTest addLog:log];
    [Logger warn:@"foo"];

    PASS_EQUAL([os memory], @"foo\n", "Should have passed ouptut to logs");

    [underTest release];
}

void warn_WhenCallsWarnWithFromat_FormatsStringAndPassesMsgToLog(){
    Logger* underTest = [[Logger alloc] init];

    MemoryOutputStream* os = [[[MemoryOutputStream alloc] init] autorelease];
    Log* log = [[[StreamLog alloc] initWithStream:os] autorelease];

    [underTest addLog:log];
    [Logger warn:@"foo %@", @"bar"];

    PASS_EQUAL([os memory], @"foo bar\n", "Should have passed ouptut to logs");

    [underTest release];
}

void warn_WhenHasGlobalLevelSetToError_DoesNothing(){
    Logger* underTest = [[Logger alloc] init];

    [underTest setGlobalLogLevel:LL_ERROR];

    MemoryOutputStream* os = [[[MemoryOutputStream alloc] init] autorelease];
    Log* log = [[[StreamLog alloc] initWithStream:os] autorelease];

    [underTest addLog:log];
    [Logger warn:@"foo %@", @"bar"];

    PASS_EQUAL([os memory], @"", "Should do nothing due to log level");

    [underTest release];
}

void instance_WhenHasNoInstance_ReturnsNil(){
    PASS([Logger instance] == nil, "When there is no logger it should be nil");
}

void instance_WhenLoggerCreated_ReturnsThatLogger(){
    Logger* underTest = [[Logger alloc] init];
    
    PASS_EQUAL([Logger instance], underTest, "Instance should be the created instance");
    [underTest release];
}

void instance_WhenLoggerCreatedWhenAlreadyExists_ReturnsNil(){
    Logger* logger = [[Logger alloc] init];
    Logger* underTest = [[Logger alloc] init];
    PASS(underTest == nil, "If an instance exists, then we shouldn't be able to create more");
    [logger release];
}

void logLevelFromString_whenHasValidWarnString_ReturnsLLWARN(){
    PASS_INT_EQUAL([Logger logLevelFromString:@"warn"], LL_WARN, "");
}
void logLevelFromString_whenHasValidWarnStringInOtherCase_ReturnsLLWARN(){
    PASS_INT_EQUAL([Logger logLevelFromString:@"WARN"], LL_WARN, "");
    PASS_INT_EQUAL([Logger logLevelFromString:@"WaRn"], LL_WARN, "");
}
void logLevelFromString_whenHasInvalidString_ReturnsLLUNKNOWN(){
    PASS_INT_EQUAL([Logger logLevelFromString:@"foo"], LL_UNKNOWN, "");
}

int main(){
    START_SET("RandomTests")
        warn_WhenCallsWarn_PassesMsgToLog();
        warn_WhenCallsWarnWithFromat_FormatsStringAndPassesMsgToLog();
        warn_WhenHasGlobalLevelSetToError_DoesNothing();

        instance_WhenHasNoInstance_ReturnsNil();
        instance_WhenLoggerCreated_ReturnsThatLogger();

        logLevelFromString_whenHasValidWarnString_ReturnsLLWARN();
        logLevelFromString_whenHasValidWarnStringInOtherCase_ReturnsLLWARN();
        logLevelFromString_whenHasInvalidString_ReturnsLLUNKNOWN();
    END_SET("RandomTests")

    return 0;
}
