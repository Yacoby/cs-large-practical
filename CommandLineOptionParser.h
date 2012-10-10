#import <Foundation/Foundation.h>

@interface CommandLineOptions : NSObject{
    NSDictionary* mOptions;
    NSArray* mRemainingArgs;
}
- (id) getOptionWithName:(NSString*)name;
- (NSArray*) getRemainingArguments;

@end

@interface CommandLineOptionParser : NSObject{
}
- (void)addArgumentWithName:(NSString*)name;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName;
- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName isBoolean:(BOOL)isBool;

- (CommandLineOptions*)parse:(NSArray*)arguments;
- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err;
@end
