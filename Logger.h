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

/**
 * @brief sets the global log level
 * @see globalLogLevel
 */
- (void)setGlobalLogLevel:(LogLevel)lvl;

/**
 * @brief gets the global log level
 *
 * The global log level can be set to override the log level of all
 * Logs used by this Logger. Log messages will not be passed on to Logs unless they are equal to
 * or higher than the global level. So if the global level is LL_WARN then
 * LL_DEBUG messages will get dropped but LL_WARN and LL_ERROR messages will be
 * passed to the registered Log classes
 *
 * Note, Logs also have a simalar log level, so even if a message is passed to a
 * Log, it is up to that Log if it actually logs the message
 *
 * @return the current global log level
 */
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

/**
 * @see error:
 */
+ (void)warn:(NSString*)msg, ...;
/**
 * @see error:
 */
+ (void)info:(NSString*)msg, ...;
/**
 * @see error:
 */
+ (void)debug:(NSString*)msg, ...;

/**
 * @brief Given a string log level such as "WARN" this converts it to the appropriate LogLevel.
 *
 * This preforms a case insenstivie comparison, so that warn, Warn, WARN would match LL_WARN 
 *
 * @return The given LogLevel or LL_UNKNOWN if the parsing failed
 */
+ (LogLevel)logLevelFromString:(NSString*)strLevel;

@end
