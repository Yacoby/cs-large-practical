#import <Foundation/Foundation.h>

/**
 * @brief Parsed command line options
 */
@interface CommandLineOptions : NSObject{
    NSDictionary* mOptions;
    NSString* mHelpText;
}
- (id)init;
- (id)initWithHelpText:(NSString*)helpText;
- (id)initWithCommandLineOptions:(NSDictionary*)options;
- (void)dealloc;

- (BOOL)shouldPrintHelpText;
- (NSString*)helpText;
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

    NSMutableArray* mPositionalArguments;

    NSMutableDictionary* mKeyToHelpText;
    NSMutableDictionary* mKeyToDefaultValue;

    NSMutableSet* mRequiredKeys;
}
- (id)init;
- (void)dealloc;

- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;

- (void)setHelpStringForArgumentKey:(NSString*)key help:(NSString*)help;
- (void)setDefaultValueForArgumentKey:(NSString*)key value:(id)defaultValue;
- (void)setRequiredForArgumentKey:(NSString*)key required:(BOOL)required;

- (CommandLineOptions*)parse:(NSArray*)arguments;
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type;
- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;
- (void)addPositionialArgumentForKey:(NSString*)key ofType:(CommandLineType)type;

- (id)convertString:(NSString*)str toType:(CommandLineType)type;

- (BOOL)isArgument:(NSString*)key ofType:(CommandLineType)type;
- (CommandLineType)getArgumentType:(NSString*)argumentKey;

- (BOOL)isOptionalArgument:(NSString*)argument;
- (BOOL)isPositionalArgument:(NSString*)name;

- (NSString*)toKeyFromLongName:(NSString*)name;
- (NSString*)getKeyFromArgument:(NSString*)argument;

- (void)makeError:(NSError**)err withDescription:(NSString*)description;

- (void)setDefaultValues:(NSMutableDictionary*)args;

- (NSString*)helpText;
@end
