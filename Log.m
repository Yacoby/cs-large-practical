#import "Log.h"

@implementation Log

- (void)setLogLevel:(LogLevel)level{
    mLogLevel = level;
}
- (LogLevel)logLevel{
    return mLogLevel;
}
- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments{
    if ( level >= [self logLevel] ){
        [self logLevelImpl:level withFormat:format arguments:arguments];
    }
}

- (void)logLevelImpl:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments{
    NSException* exception = [NSException exceptionWithName: @"ProgrammerError"
                                                     reason: @"Only the subclass of this class should be used and it should override this method"
                                                   userInfo: nil];
    [exception raise];
}

@end

@implementation StreamLog

- (id)initWithStream:(id<OutputStream>)stream{
    self = [super init];
    if ( self ){
        [stream retain];
        mStream = stream;
    }
    return self;
}

- (void)dealloc{
    [mStream release];
    [super dealloc];
}

- (void)logLevelImpl:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments{
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    [mStream write:msg];
    [mStream write:@"\n"];
    [msg release];
}
@end
