#import <Foundation/Foundation.h>
#import "Log.h"

/**
 * @brief This is a singleton interface to a set of loggers to make them easier to use
 *
 * This isn't quite the same as the common singleton patterns as it requires explicit 
 * instantiation rather than the object being created when you call instance.
 * This is in my opinion a slightly cleaner method of doing things as it allows you
 * to reason about when things are created (as well as have a init parameters)
 *
 * This class holds a list of logs and a global log level. When calling a function
 * it first ensures that it should be logged using the global log level and
 * then passes on the message to all logs.
 */
@interface Logger : NSObject{
    NSMutableSet* mLogs;
    LogLevel mGlobalLogLevel;
}
/**
 * @brief Creates an instance of the Logger class if one doesn't exist already
 * 
 * @return A new instance of the Logger class or nil if one already exists
 */
- (id)init;

- (void)dealloc;

/** 
 * @brief Adds a log output to the list of logs to receive log messages
 */
- (void)addLog:(Log*)log;

/**
 * @return The set of logs currently held by the class
 */
- (NSSet*)logs;

- (void)setGlobalLogLevel:(LogLevel)lvl;
- (LogLevel)globalLogLevel;

/**
 * @brief gets the sole instance of this class if it exists
 * @return the instance of this class if it exists otherwise nil
 */
+ (Logger*)instance;

/**
 * @brief sends the message to all Logs
 *
 * If there is a Logger instance, this first checks if
 * the message should be logged using the global log level and 
 * then sends the message to every Log class registered with the 
 * Logger instance
 */
+ (void)error:(NSString*)msg, ...;
+ (void)warn:(NSString*)msg, ...;
+ (void)info:(NSString*)msg, ...;
+ (void)debug:(NSString*)msg, ...;

@end
