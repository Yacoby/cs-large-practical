#import "CommandLineOptionParser.h"
#import "ErrorConstants.h";

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
    NSMutableArray* mutableArguments = [arguments mutableCopy];
    NSMutableArray* remainingArgs = [[NSMutableArray alloc] init];
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];

    while ( [mutableArguments count] ){
        NSString* argument = [mutableArguments objectAtIndex:0];
        [mutableArguments removeObjectAtIndex: 0];

        if ([argument hasPrefix:@"-"] ){
        NSString* argName = nil;
        NSMutableDictionary* lookupDict = nil;

            if ([argument hasPrefix:@"--"] ){
                argName = [argument substringFromIndex:2];
                lookupDict = mLongNames;
            }else{
                argName = [argument substringFromIndex:1];
                lookupDict = mShortNames;
            }

            NSString* key = [lookupDict objectForKey: argName];
            if ( key == nil ){
                NSString* description = NSLocalizedString(@"Unknown argument ", @"");

                NSDictionary* errorDictionary = nil;// { NSLocalizedDescriptionKey : description };
                *err = [NSError errorWithDomain:ERROR_DOMAIN code:1 userInfo:errorDictionary];

                //TODO LEAK
                return nil;
            }

            [args setObject:[self parseSingleArgument:mutableArguments argumentName:argName]
                     forKey: [lookupDict objectForKey: argName]];
        }else{
            [remainingArgs addObject:argument];
            for ( NSString* arg in mutableArguments){
                if ([arg hasPrefix:@"-"] ){
                    //problem, there are still options when there shouldn't be
                }else{
                    [remainingArgs addObject:arg];
                }
            }

            break;
        }
    }

    CommandLineOptions* toReturn = [[[CommandLineOptions alloc] initWithOptions:args andArgs: remainingArgs] autorelease];
    
    [remainingArgs release];
    [args release];
    [mutableArguments release];

    return toReturn;
}

- (id)parseSingleArgument:(NSMutableArray*)arguments argumentName:(NSString*) argName{
    if ( [self isArgumentBool:argName] ){
        return @"1";
    }else{
        NSString* arg = [arguments objectAtIndex:0];
        [arguments removeObjectAtIndex: 0];
        return arg;
    }
}

- (BOOL)isArgumentBool:(NSString*)name{
    NSNumber* result = [mIsBoolean objectForKey:name];
    if ( result == nil ){
        return false;
    }
    return [result boolValue];
}

@end

