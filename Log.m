#import "Log.h"

@implementation Log

- (void)setLogLevel:(LogLevel)level{
    mLogLevel = level;
}
- (LogLevel)logLevel{
    return mLogLevel;
}

- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments{
    NSException* exception = [NSException exceptionWithName: @"ProgrammerError"
                                                 reason: @"Only the subclass of this class should be used"
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

- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments{
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    [mStream write:msg];
    [msg release];
}
@end
