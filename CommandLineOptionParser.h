/** @file */
#import <Foundation/Foundation.h>

/**
 * @brief Holds the key/value pair of a command line option (the key) and the value it has been set to (the value)
 */
@interface CommandLineKeyValue : NSObject{
    NSString* mKey;
    /**
     * @brief represents the value associated with the key.
     *
     * This is of type id as it could either be the converted or string representation of
     * a configuration option
     */
    id mValue;
}
- (id)initWithKey:(NSString*)key value:(id)value;
- (void)dealloc;

- (NSString*)key;
- (id)value;
@end

/**
 * @brief Parsed command line options held in a dictionary and accessible via the option name (key)
 *
 * This holds one of two states, either the command line options
 * have been parsed or the help text that the user requested through the -h parameter.
 * These states are mutually exclusive
 */
@interface CommandLineOptions : NSObject{
    NSDictionary* mOptions;
    NSString* mHelpText;
}
- (id)init;

/**
 * @brief init with help text to display
 */
- (id)initWithHelpText:(NSString*)helpText;

/**
 * @brief init with a dictionary of key -> argument value
 */
- (id)initWithCommandLineOptions:(NSDictionary*)options;
- (void)dealloc;

/**
 * @brief Returns the state of the class (if it has help text or options)
 * @return True if there is help text to print
 * 
 * If there is help text to print then there will be no options that can be retrieved
 */
- (BOOL)shouldPrintHelpText;

/**
 * @brief returns the help text or nil if there is no help text
 * 
 * There will be no help text if the user hasn't requested it by 
 * specifying -h or --help on the command line
 *
 * @return the help text or nil if there is no help text
 */
- (NSString*)helpText;

/**
 * @brief retrieves an option with the given argument key
 * @param name the name of the argument to get
 * @return the value for that argument or nil if it doesn't exist
 */
- (id)getOptionWithName:(NSString*)name;
@end


/**
 * Represents the type of command line options. This allows a basic form
 * of type checking as well as being able to provide the parsed argument with
 * the correct type
 */
typedef enum {
    Boolean,
    String,
    Integer
} CommandLineType;

/**
 * The prefix appended to the start of arguments used from the command line. In
 * most applications it is --
 */
extern NSString* const COMMAND_LINE_LONG_PREFIX;
/**
 * The prefix appended to the start of one letter arguments used from the command line. In
 * most applications it is -
 */
extern NSString* const COMMAND_LINE_SHORT_PREFIX;

/**
 * @brief Parser for command line options
 *
 * Options can be optional or positional. Optional arguments are one prefixed by
 * -- or - and can be omitted.  Positional arguments are those that must be included
 * for the correct functioning of the program. Optional arguments have names starting
 * with -- and can have a short name starting with -. Positional arguments don't.
 *
 * Positional arguments are ordered. So the order of adding positional arguments is
 * critial to the usage of the program.
 *
 * Each argument has an associated key. This is generated from the argument name (minus
 * the -- if required). When parsed this is the key used to retrieve the options.
 *
 * Each argument must have a type. This allows a basic type checking and the
 * returning of the correct type of object. If the type is primitive, then it will
 * be wrapped by an object such as NSNumber.
 *
 * There is one option that is always set, and that is --help. If this is encountered
 * in the arguments then the result of the argument parser is the help text
 *
 * All options can have default values, hover booleans automatically have the default
 * value of NO.
 *
 * By default options are not required and positional arguments are required. This
 * is possible to alter, although be note that it is not possible to have a required
 * positional argument after an optional positional argument.
 */
@interface CommandLineOptionParser : NSObject{
    NSMutableDictionary* mShortArgumentNameToKey;
    NSMutableDictionary* mLongArgumentNameToKey;
    NSMutableDictionary* mKeyToType;

    NSMutableSet* mKeys;

    NSMutableArray* mPositionalArguments;

    NSMutableDictionary* mKeyToHelpText;
    NSMutableDictionary* mKeyToDefaultValue;

    NSMutableSet* mRequiredKeys;
}
- (id)init;
- (void)dealloc;

/**
 * @brief adds an argument, with the type of argument depending on the name
 * @param name This is the name of the argument. If specified with the "--" prefix
 *             then it becomes a optional argument with the key being the name
 *             without the prefix.
 *             If specified without the -- prefix then it becomes a positional
 *             argument.
 * @param type this specifies the type of the argument. To avoid any checking specify
 *             the String type
 */
- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type;

/**
 * @see addArgumentWithName:ofType:
 *
 * @param name the name of the argument to add. See addArgumentWithName:ofType: for more info
 * @param shortName this is the short name for an optional argument. This must
 *                  start with a "-"
 * @param type the type of the argument. See addArgumentWithName:ofType: for more info
 */
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;

/**
 * @brief Sets the help text for the argument
 *
 * If the key doesn't exist this will raise an exception
 */
- (void)setHelpStringForArgumentKey:(NSString*)key help:(NSString*)help;

/**
 * @brief Sets the default value for an argument.
 *
 * In some cases, this is already set, for example Boolean arguments have
 * the default to NO.
 *
 * If the key doesn't exist this will raise an exception
 *
 * @param key the key of the argument
 * @param defaultValue The default value for the argument, which is set if the
                        user doesn't specify a value
 */
- (void)setDefaultValueForArgumentKey:(NSString*)key value:(id)defaultValue;

/**
 * @brief Sets the argument to required/not required
 *
 * By default positional arguments are required and optional arguments are not
 * required. Given how positional arguments work, only the last argument can be
 * set to not required. This restriction is not enforced.
 *
 * If the key doesn't exist this will raise an exception
 *
 * @param key the key of the argument
 * @param required Set to YES if the argument is required
 */
- (void)setRequiredForArgumentKey:(NSString*)key required:(BOOL)required;

/**
 * @brief same as parse:error: but does not record the details of any error that occurs
 * @see parse:error:
 */
- (CommandLineOptions*)parse:(NSArray*)arguments;

/**
 * @brief parses the command line arguments passed in an array
 * @param arguments The array of arguments (excluding program name)
 * @param err a pointer to a unallocated NSError* object
 * @return The command line options if parsing succeeded or nil if they failed.
 *              In the event of parsing failing the object passed to error will
 *              be created.
 *
 * This should be called when parsing command line options and deals with calling the
 * subfunctions parse* (such as parseCommandLineArgumentFromStack). It first parses
 * the arguments and then provides validation of what was parsed.
 */
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;

/**
 * @brief Parses all the arguments given into a dictionary 
 * @param arguments a list of all the arguments given to the program excluding the program name
 * @param err the variable that is filled if an error occurs 
 * @return a NSMutableDictionary* of NSString* to id of arguments 
 *
 * @note this method is only called from parse:error: and is only intended to be used by that method
 */
- (NSMutableDictionary*)parseAllCommandLineArguments:(NSArray*)arguments error:(NSError**)err;

/**
 * @brief parses a single command line argument from the stack of available arguments
 * @param argumentStack an ordered list of arguments yet to parse
 * @param remaingPositionalArgs the positional arguments that have yet to be parsed
 * @param err the variable that will be filled if an error occurs (ie if the method returns nil)
 * @return the parsed option, with the value converted to the appropriate type or nil if an error occurred
 *
 * @note this method is only called from parseAllCommandLineArguments:error: and is 
 *       only intended to be used by that method
 */
- (CommandLineKeyValue*)parseCommandLineArgumentFromStack:(NSMutableArray*)argumentStack
                             remainingPositionalArguments:(NSMutableArray*)remaingPositionalArgs
                                                    error:(NSError**)err;
/**
 * @brief Parses an optional argument and alters the argumentStack
 * @param argument the first bit of the optional argument (--foo for example).
 * @param argumentStack the remaining argument stack, this is updated depending on argument
 *        (boolean arguments don't need to read any more information for the argumentStack).
 * @param err this is filled with error information if an error occurs
 * @return a parsed option or nil if there was an error. The option value will not have been converted from a NSString
 *
 * @note this method is called from parseCommandLineArgumentFromStack:remainingPositionalArguments:error:
 *       and so is only intended to be used by that method
 */
- (CommandLineKeyValue*)parseOptionalArgument:(NSString*)argument
                        withRemainingStack:(NSMutableArray*)argumentStack
                                     error:(NSError**)err;
/** 
 * @brief Parses a positional argument and alters the remaingPositionalArgs
 * @param argument the value of the positional argument
 * @param remaingPositionalArgs the keys of the remaining positional arguments
 * @param err this is filled with error information if an error occurs
 * @return a parsed option or nil if there was an error
 *
 * @note this method is called from parseCommandLineArgumentFromStack:remainingPositionalArguments:error:
 *       and so is only intended to be used by that method
 */
- (CommandLineKeyValue*)parsePositionalArgument:(NSString*)argument
                remainingPositionalArguments:(NSMutableArray*)remaingPositionalArgs
                error:(NSError**)err;

/**
 * @brief Allows adding an optional argument while specifying a key
 *
 * @see addArgumentWithName:ofType:
 *
 * This allows adding an argument with more control as you can specify exactly
 * what type of argument you want to add as well as the key that it should
 * be associated with
 */
- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type;

/**
 * @see addOptionalArgumentForKey:withName:ofType:
 */
- (void)addOptionalArgumentForKey:(NSString*)key
                         withName:(NSString*)name
                     andShortName:(NSString*)shortName
                           ofType:(CommandLineType)type;

/**
 * @brief Adds a positional argument for a given key.
 *
 * This is no different from addArgumentWithName when specifying a name without
 * a "--" prefix, however by this point we know that it is an positional argument.
 */
- (void)addPositionialArgumentForKey:(NSString*)key ofType:(CommandLineType)type;

/**
 * @brief Converts the string str to the requested type.
 * @param str The string representation of the type
 * @param type The type to attempt to convert str to
 * @return str converted to the new type, possibly wrapped if the type is a primative.
 *          If conversion failed nil is returned
 */
- (id)convertString:(NSString*)str toType:(CommandLineType)type;

/**
 * @param key The argument key to check
 * @param type The type to compare the argument against
 * @return True if the the argument is of the given type
 *
 * @todo should we be uisng getArgumentType rather than this
 */
- (BOOL)isArgument:(NSString*)key ofType:(CommandLineType)type;

/**
 * @brief gets the type of the argument
 */
- (CommandLineType)getArgumentType:(NSString*)argumentKey;

/**
 * @brief Checks if a string looks like an optional argument by looking at the strings
 *        leading characters 
 *
 * @note This just does a string check and is used when working out what type of
 *      argument the programmer wants. @see addArgumentWithName:ofType:
 */
- (BOOL)isOptionalArgument:(NSString*)argument;

/**
 * @brief checks that the string looks like a positional argument by looking at the strings
 *        leading characters
 */
- (BOOL)isPositionalArgument:(NSString*)name;

/**
 * @brief Converts an argument name in the form of "--name" to "name"
 * @param name The name starting with COMMAND_LINE_LONG_PREFIX
 * @return the string without COMMAND_LINE_LONG_PREFIX
 */
- (NSString*)toKeyFromLongName:(NSString*)name;

/**
 * @brief Looks up the argument name in the relevant dictionary (based on the prefix) and  returns the key
 * @param argument The argument including the prefix. E.g. "--foo"
 * @return The key for the argument or nil if there is no key for that argument
 */
- (NSString*)getKeyFromArgument:(NSString*)argument;

/**
 * @brief helper function to make a new NSError object with the given description
 */
- (void)makeError:(NSError**)err withDescription:(NSString*)description;

/**
 * @brief Inserts entries for arguments that have a default value but have no user value set
 * @param args A dictionary of (ArgumentKey, ArgumentValue) that is altered
 */
- (void)setDefaultValues:(NSMutableDictionary*)args;

/**
 * @brief generates help text from the arguments
 */
- (NSString*)helpText;
@end
