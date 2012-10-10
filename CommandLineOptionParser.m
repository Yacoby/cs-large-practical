#import "CommandLineOptionParser.h"

@implementation CommandLineOptions

- (id)initWithOptions:(NSDictionary*)options andArgs:(NSArray*)args{
    self = [super init];
    if ( self != nil ){
        [options retain];
        mOptions = options;

        [args retain];
        mRemainingArgs = args;
    }
    return self;
}
- (void)dealloc{
    [mOptions release];
    [mRemainingArgs release];
    [super dealloc];
}

- (id)getOptionWithName:(NSString*)name{
    return [mOptions objectForKey:name];
}
- (NSArray*)getRemainingArguments{
    return mRemainingArgs;
}
@end

@implementation CommandLineOptionParser
- (id)init{
    self = [super init];
    if ( self != nil ){
        mShortNames = [[NSMutableDictionary alloc] init];
        mLongNames = [[NSMutableDictionary alloc] init];
        mIsBoolean = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)dealloc{
    [mShortNames release];
    [mLongNames release];
    [mIsBoolean release];
    [super dealloc];
}

- (void)addArgumentWithName:(NSString*)name{
    [self addArgumentForKey:name withName:name];
}

- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName{
    [self addArgumentForKey:name withName:name andShortName:shortName];
}

- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName isBoolean:(BOOL)isBool{
    [self addArgumentForKey:name withName:name andShortName:shortName isBoolean:isBool];
}

- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name{
    [mLongNames setObject:key forKey:name];
}

- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName{
    [mShortNames setObject:key forKey: shortName];
    [self addArgumentForKey: key withName: name];
}

- (void)addArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName isBoolean:(BOOL)isBool{
    [mIsBoolean setObject:[NSNumber numberWithBool:isBool] forKey:name];
    [self addArgumentForKey:key withName:name andShortName:shortName];
}

- (CommandLineOptions*)parse:(NSArray*)arguments{
    NSError* err;
    return [self parse:arguments error:&err];
}

- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err{
    NSString* argument = [arguments objectAtIndex:0];
    if ([argument hasPrefix:@"--"] ){
        NSString* argName = [argument substringFromIndex:2];

    }else if ([argument hasPrefix:@"-"] ){
        NSString* argName = [argument substringFromIndex:1];

    }else{
        for ( NSString* arg in arguments ){
            if ([argument hasPrefix:@"-"] ){
                //problem, there are still options when there shouldn't be
            }
        }
    }
}

- (void)parseSingleArgument:(NSMutableArray*)arguments argumentName:(NSString*){
    if ( [self isArgumentBool:argName] ){
        //set arg 1
    }else{
        NSString* arg = [arguments objectAtIndex:1];
        //set arg to the value

    }
}

- (BOOL)isArgumentBool:(NSString*)name{
}

@end

