/** @file */
#import <Foundation/Foundation.h>
#import "OutputStream.h"

/**
 * @brief A list of all log levels
 *
 * The LL_UNKNOWN level isn't intended to be used as a log level but rather
 * as a error condition. I would prefer to use something like Haskells Maybe
 * however it isn't possible to do for enums in a generic way using Objective-C.
 *
 * @see Logger:logLevelFromString
 */
typedef enum {
    LL_UNKNOWN,
    LL_DEBUG,
    LL_INFO,
    LL_WARN,
    LL_ERROR
} LogLevel;

/**
 * @brief base class for logging classes to inherit from. Not intended to be used directly
 *
 * Provides common functions and functions that sub classes should override.
 */
@interface Log : NSObject{
    LogLevel mLogLevel;
}

- (void)setLogLevel:(LogLevel)level;
- (LogLevel)logLevel;

/**
 * @brief Write to a log file. This calls logLevelImpl if the message should be written
 *
 * This is not intended to be used by the user, but rather this should be used by
 * the Logger class which provides a better interface.
 *
 * @param level the log level for this message
 * @param format the format string
 * @param arguments the variable list of arguments
 */
- (void)logLevel:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments;

/**
 * @brief functiont that does the work of logging. Should be overwritten by subclasses

 * @param level the log level for this message
 * @param format the format string
 * @param arguments the variable list of arguments
 */
- (void)logLevelImpl:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments;
@end

/**
 * @brief Log to an output stream of some form
 */
@interface StreamLog : Log{
    id<OutputStream> mStream;
}
- (id)initWithStream:(id<OutputStream>)stream;
- (void)dealloc;

- (void)logLevelImpl:(LogLevel)level withFormat:(NSString*)format arguments:(va_list)arguments;
@end
