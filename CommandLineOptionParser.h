#import <Foundation/Foundation.h>

/**
 * @brief Parsed command line options
 */
@interface CommandLineOptions : NSObject{
    NSDictionary* mOptions;
}
- (id)initWithCommandLineOptions:(NSDictionary*)options;
- (void)dealloc;

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
 * with --. Positional arguments don't.
 *
 * Each argument has an associated key. This is generated from the argument name (minus
 * the -- if required). When parsed this is the key used to retrieve the options.
 *
 * Each argument must have a type. This allows a basic type checking and the
 * returning of the correct type of object. If the type is primative, then it will
 * be wrapped by an object such as NSNumber.
 */
@interface CommandLineOptionParser : NSObject{
    NSMutableDictionary* mShortNames;
    NSMutableDictionary* mLongNames;
    NSMutableDictionary* mTypes;

    NSMutableArray* mPositionalArguments;
}
- (id)init;
- (void)dealloc;

- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type;
- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type;
- (void)addPositionialArgumentForKey:(NSString*)key ofType:(CommandLineType)type;

- (CommandLineOptions*)parse:(NSArray*)arguments;
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;

- (id)convertString:(NSString*)str toType:(CommandLineType)type;
- (BOOL)isPositionalName:(NSString*)name;
- (NSString*)toKeyFromLongName:(NSString*)name;

- (BOOL)isArgument:(NSString*)key ofType:(CommandLineType)type;

- (CommandLineType)getArgumentType:(NSString*)argumentKey;

- (BOOL)isOption:(NSString*)argument;

- (NSString*)getKeyFromArgument:(NSString*)argument;

- (void)makeError:(NSError**)err withDescription:(NSString*)description;
@end
