#import "Logger.h"

static Logger* logger = nil;

@implementation Logger

- (id)init{
    if ( logger == nil ){
        logger = self = [super init];
        if ( self ){
            mLogs = [[NSMutableSet alloc] init];
        }
        return self;
    }
    return nil;
}

- (void)dealloc{
    [mLogs release];
    [super dealloc];
    logger = nil;
}

- (NSSet*)logs{
    return mLogs;
}
- (void)addLog:(Log*)log{
    [mLogs addObject:log];
}

+ (Logger*)instance{
    return logger;
}

- (void)setGlobalLogLevel:(LogLevel)lvl{
    mGlobalLogLevel = lvl;
}
- (LogLevel)globalLogLevel{
    return mGlobalLogLevel;
}

+ (void)error:(NSString*)msg, ...{
    Logger* instance = [self instance];
    if ( instance &&  [instance globalLogLevel] <= LL_ERROR ){
        va_list va;
        va_start(va, msg);
        for ( Log* log in [instance logs] ){
            [log logLevel:LL_ERROR withFormat:msg arguments: va];
        }
        va_end(va);
    }
}

+ (void)warn:(NSString*)msg, ...{
    Logger* instance = [self instance];
    if ( instance &&  [instance globalLogLevel] <= LL_WARN ){
        va_list va;
        va_start(va, msg);
        for ( Log* log in [instance logs] ){
            [log logLevel:LL_WARN withFormat:msg arguments: va];
        }
        va_end(va);
    }
}

+ (void)info:(NSString*)msg, ...{
    Logger* instance = [self instance];
    if ( instance &&  [instance globalLogLevel] <= LL_INFO ){
        va_list va;
        va_start(va, msg);
        for ( Log* log in [instance logs] ){
            [log logLevel:LL_INFO withFormat:msg arguments: va];
        }
        va_end(va);
    }
}

+ (void)debug:(NSString*)msg, ...{
    Logger* instance = [self instance];
    if ( instance &&  [instance globalLogLevel] <= LL_DEBUG ){
        va_list va;
        va_start(va, msg);
        for ( Log* log in [instance logs] ){
            [log logLevel:LL_DEBUG withFormat:msg arguments: va];
        }
        va_end(va);
    }
}

+ (LogLevel)logLevelFromString:(NSString*)strLevel{
    if ( [strLevel caseInsensitiveCompare:@"debug"] == NSOrderedSame ){
        return LL_DEBUG;
    }else if ( [strLevel caseInsensitiveCompare:@"info"] == NSOrderedSame ){
        return LL_INFO;
    }else if ( [strLevel caseInsensitiveCompare:@"warn"] == NSOrderedSame ){
        return LL_WARN;
    }else if ( [strLevel caseInsensitiveCompare:@"error"] == NSOrderedSame ){
        return LL_ERROR;
    }
    return LL_UNKNOWN;
}
@end
