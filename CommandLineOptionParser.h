/** @file */
#import <Foundation/Foundation.h>

/**
 * @brief Parsed command line options
 *
 * This holds one of two states, either the command line options
 * have been parsed or the help text that the user requested through the -h paramter.
 * These states are mutally exclusive
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
 * @brief True if there is help text to print
 */
- (BOOL)shouldPrintHelpText;

/**
 * @brief returns the help text or nil if there is no help text
 * 
 * There will be no help text if the user hasn't requested it by 
 * specifing -h or --help on the command line
 *
 * @return the help text or nil if there is no help text
 */
- (NSString*)helpText;

/**
 * @brief retrives an option with the given argument key
 * @param name the name of the argument to get
 * @return the value for that argument or nil if it doesn't exist
 */
- (id)getOptionWithName:(NSString*)name;
@end


typedef enum {
    Boolean,
    String,
    Integer
} CommandLineType;

extern NSString* const COMMAND_LINE_LONG_PREFIX;
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
 * returning of the correct type of object. If the type is primative, then it will
 * be wrapped by an object such as NSNumber.
 *
 * There is one option that is always set, and that is --help. If this is encounted
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
 * @param type this specifies the type of the arugment. To avoid any checking specify
 *             the String type
 */
- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type;

/**
 * @see addArgumentWithName:ofType:
 *
 * @param shortName this is the short name for an optional arugment. This must
 *                  start with a "-"
 */
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;

/**
 * @brief Sets the help text for the argument
 */
- (void)setHelpStringForArgumentKey:(NSString*)key help:(NSString*)help;

/**
 * @brief Sets the default value for an argument.
 *
 * In some cases, this is already set, for example Boolean arguments have
 * the defalut to NO.
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
 * @param key the key of the argument
 * @param required Set to YES if the argument is required
 */
- (void)setRequiredForArgumentKey:(NSString*)key required:(BOOL)required;

- (CommandLineOptions*)parse:(NSArray*)arguments;

/**
 * @brief parses the command line arguments passed in an array
 * @param arguments The array of arguments (excluding program name)
 * @param err a pointer to a unallocated NSError* object
 * @return The command line options if parsing sucseeded or nil if they failed.
 *              In the event of parsing failing the object passed to error will
 *              be created.
 *
 * This parses the command line options and handles things such the user asking
 * for help to be printed. @see CommandLineOptions
 */
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;

/**
 * @brief Allows adding an optional argument while specifing a key

 * @see addArgumentWithName:ofType:

 * This allows adding an argument with more control as you can specifiy exactly
 * what type of argument you want to add as well as the key that it should
 * be associated with
 */
- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type;

/**
 * @see addOptionalArgumentForKey:withName:ofType:
 */
- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;

/**
 * @brief Allows adding a positional argument for a given key. 
 *
 * This is no different from addArgumentWithName when specifing a name without
 * a "--" prefix, however by this point we know that it is an positonal argument.
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
 * @brief Checks if a string looks like an optional argument by looking at the name
 * @brief argument the argument name such as --foo
 *
 * @note This just does a string check and is used when working out what type of
 *      argument the programmer wants. @see addArgumentWithName:ofType:
 */
- (BOOL)isOptionalArgument:(NSString*)argument;
- (BOOL)isPositionalArgument:(NSString*)name;

/**
 * @brief Converts an argument name in the form of "--name" to "name"
 * @param name The name starting with COMMAND_LINE_LONG_PREFIX
 * @return the string without COMMAND_LINE_LONG_PREFIX
 */
- (NSString*)toKeyFromLongName:(NSString*)name;

/**
 * @brief Looks up the argument name in the relatant dictionary (based on the prefix) and  returns the key
 * @param argument The argument including the prefix. E.g. "--foo"
 * @return The key for the argument or nil if there is no key for that argument
 */
- (NSString*)getKeyFromArgument:(NSString*)argument;

/**
 * @brief helper function to make a new NSError object with the given description
 */
- (void)makeError:(NSError**)err withDescription:(NSString*)description;

/**
 * @brief Inserts ArgumentKeys that have a default value but have no user value set
 * @param args A dictionary of (ArgumentKey, ArgumentValue)
 */
- (void)setDefaultValues:(NSMutableDictionary*)args;

/**
 * @brief generates help text from the arguments
 */
- (NSString*)helpText;
@end
