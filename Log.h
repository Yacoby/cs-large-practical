#import <Foundation/Foundation.h>
#import "OutputStream.h"

typedef enum {
    LL_DEBUG,
    LL_INFO,
    LL_WARN,
    LL_ERROR
} LogLevel;

@interface Log : NSObject{
    LogLevel mLogLevel;
}

- (void)setLogLevel:(LogLevel)level;
- (LogLevel)logLevel;

- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments;
@end

@interface StreamLog : Log{
    id<OutputStream> mStream;
}
- (id)initWithStream:(id<OutputStream>)stream;
- (void)dealloc;
- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments;
@end
