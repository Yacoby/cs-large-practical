#import <Foundation/Foundation.h>

/**
 * @brief Parsed command line options
 */
@interface CommandLineOptions : NSObject{
    NSDictionary* mOptions;
    NSArray* mRemainingArgs;
}
- (id)initWithOptions:(NSDictionary*)options andArgs:(NSArray*)args;
- (void)dealloc;

- (id)getOptionWithName:(NSString*)name;
- (NSArray*)getRemainingArguments;

@end

/**
 * @brief Parser for command line options
 */
@interface CommandLineOptionParser : NSObject{
    NSMutableDictionary* mShortNames;
    NSMutableDictionary* mLongNames;
    NSMutableDictionary* mIsBoolean;
}
- (id)init;
- (void)dealloc;

- (void)addArgumentWithName:(NSString*)name;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName isBoolean:(BOOL)isBool;

- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name;
- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName;
- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName isBoolean:(BOOL)isBool;

- (CommandLineOptions*)parse:(NSArray*)arguments;
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;

- (BOOL)isArgumentBool:(NSString*)name;
- (id)parseSingleArgument:(NSMutableArray*)arguments argumentName:(NSString*)argName;
@end
