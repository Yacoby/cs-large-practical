#import "CommandLineOptionParser.h"
#import "ErrorConstants.h"

@implementation CommandLineOptions
- (id)init{
    self = [super init];
    if ( self != nil ){
        mOptions = nil;
        mHelpText = nil;
    }
    return self;
}
- (id)initWithCommandLineOptions:(NSDictionary*)options{
    self = [self init];
    if ( self != nil ){
        [options retain];
        mOptions = options;
    }
    return self;
}
- (id)initWithHelpText:(NSString*)helpText{
    self = [super init];
    if ( self != nil ){
        [helpText retain];
        mHelpText = helpText;
    }
    return self;
}
- (void)dealloc{
    [mOptions release];
    [super dealloc];
}

- (BOOL)shouldPrintHelpText{
    return mHelpText != nil;
}

- (NSString*)helpText{
    return mHelpText;
}

- (id)getOptionWithName:(NSString*)name{
    return [mOptions objectForKey:name];
}
@end

NSString* const COMMAND_LINE_LONG_PREFIX = @"--";
NSString* const COMMAND_LINE_SHORT_PREFIX = @"-";

@implementation CommandLineOptionParser
- (id)init{
    self = [super init];
    if ( self != nil ){
        mShortArgumentNameToKey = [[NSMutableDictionary alloc] init];
        mLongArgumentNameToKey = [[NSMutableDictionary alloc] init];
        mKeyToType = [[NSMutableDictionary alloc] init];
        mKeyToHelpText = [[NSMutableDictionary alloc] init];
        mKeyToDefaultValue = [[NSMutableDictionary alloc] init];

        mPositionalArguments = [[NSMutableArray alloc] init];
    }
    [self addArgumentWithName:@"--help" andShortName:@"-h" ofType:Boolean];
    [self setHelpStringForArgumentKey:@"help" help:@"Prints this output"];
    return self;
}
- (void)dealloc{
    [mShortArgumentNameToKey release];
    [mLongArgumentNameToKey release];
    [mKeyToType release];
    [mKeyToHelpText release];
    [mKeyToDefaultValue release];
    [mPositionalArguments release];
    [super dealloc];
}

- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type{
    if ( [self isPositionalArgument:name] ){
        [self addPositionialArgumentForKey:name ofType:type];
    }else{
        NSString* key = [self toKeyFromLongName:name];
        [self addOptionalArgumentForKey:key withName:name ofType:type];
    }
}

- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type{
    if ( [self isPositionalArgument:name] ){
        [self addPositionialArgumentForKey:name ofType:type];
    }else{
        NSString* key = [self toKeyFromLongName:name];
        [self addOptionalArgumentForKey:key withName:name andShortName:shortName ofType:type];
    }
}

- (void)setHelpStringForArgumentKey:(NSString*)key help:(NSString*)help{
    [mKeyToHelpText setObject:help forKey:key];
}

- (void)setDefaultValueForArgumentKey:(NSString*)key value:(id)defaultValue{
    [mKeyToDefaultValue setObject:defaultValue forKey:key];
}

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type{
    [mKeyToType setObject:[NSNumber numberWithInteger:type] forKey:key];
    [mLongArgumentNameToKey setObject:key forKey:name];

    if ( type == Boolean ){
        [self setDefaultValueForArgumentKey:key value:[NSNumber numberWithBool:NO]];
    }
}

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type{
    [mShortArgumentNameToKey setObject:key forKey:shortName];
    [self addOptionalArgumentForKey:key withName:name ofType:type];
}

- (void)addPositionialArgumentForKey:(NSString*)key ofType:(CommandLineType)type{
    [mKeyToType setObject:[NSNumber numberWithInteger:type] forKey:key];
    [mPositionalArguments addObject:key];
}


- (NSString*)toKeyFromLongName:(NSString*)name{
    return [name substringFromIndex:[COMMAND_LINE_LONG_PREFIX length]];
}
- (BOOL)isPositionalArgument:(NSString*)name{
    return ![name hasPrefix: COMMAND_LINE_SHORT_PREFIX];
}

- (BOOL)isOptionalArgument:(NSString*)argument{
    return [argument hasPrefix:COMMAND_LINE_SHORT_PREFIX];
}

- (CommandLineOptions*)parse:(NSArray*)arguments{
    NSError* err;
    return [self parse:arguments error:&err];
}

- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err{

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    NSMutableArray* remaingPositionalArgs = [[mPositionalArguments mutableCopy] autorelease];
    NSMutableArray* mutableArguments = [[arguments mutableCopy] autorelease];
    NSMutableDictionary* parsedArguments = [[[NSMutableDictionary alloc] init] autorelease];

    while ( [mutableArguments count] ){
        NSString* argument = [mutableArguments objectAtIndex:0];
        [mutableArguments removeObjectAtIndex: 0];

        if ([self isOptionalArgument:argument] ){
            NSString* key = [self getKeyFromArgument:argument];
            if ( key == nil ){
                [pool drain];

                NSString* description = [NSString stringWithFormat:@"Unknown argument %@", argument];
                [self makeError:err withDescription:description];

                return nil;
            }

            NSString* result = nil;
            if ( ![self isArgument:key ofType:Boolean] ){
                result = [mutableArguments objectAtIndex:0];
                [mutableArguments removeObjectAtIndex: 0];
            }else{
                result = @"Y";
            }

            id convertedArgument = [self convertString:result toType:[self getArgumentType:key]];
            [parsedArguments setObject:convertedArgument forKey:key];
        }else{
            if ( [remaingPositionalArgs count] == 0 ){
                [pool drain];

                NSString* description = [NSString stringWithFormat:@"Unexpected positional argument %@", argument];
                [self makeError:err withDescription:description];

                return nil;
            }
            NSString* positionalArgumentKey = [remaingPositionalArgs objectAtIndex:0];
            [remaingPositionalArgs removeObjectAtIndex:0];

            id convertedArgument = [self convertString:argument toType:[self getArgumentType:positionalArgumentKey]];
            [parsedArguments setObject:convertedArgument forKey: positionalArgumentKey];
        }
    }

    if ( [parsedArguments objectForKey:@"help"] ){
        [pool drain];
        return [[CommandLineOptions alloc] initWithHelpText:[self helpText]];
    }

    if ( [remaingPositionalArgs count] > 0 ){
        NSString* remainingArgs = [remaingPositionalArgs componentsJoinedByString:@","];
        [remainingArgs retain];
        [pool drain];

        NSString* description = [NSString stringWithFormat:@"There were still positional arguments required: %@", remainingArgs];
        [remainingArgs release];
        [self makeError:err withDescription:description];
        return nil;
    }
    [self setDefaultValues:parsedArguments];

    CommandLineOptions* toReturn = [[CommandLineOptions alloc] initWithCommandLineOptions:parsedArguments];
    [pool drain];
    [toReturn autorelease];
    return toReturn;
}

- (BOOL)isArgument:(NSString*)key ofType:(CommandLineType)type{
    NSNumber* wrappedType = [mKeyToType objectForKey:key];
    return type == [wrappedType intValue];
}

- (id)convertString:(NSString*)str toType:(CommandLineType)type{
    switch(type){
        case Integer:
            return [NSNumber numberWithInteger:[str intValue]];
        case Boolean:
            return [NSNumber numberWithBool:[str boolValue]];
        case String:
            return str;
        default:
            return nil;
    }
}

- (CommandLineType)getArgumentType:(NSString*)argumentKey{
   return [[mKeyToType objectForKey:argumentKey] intValue];
}

- (NSString*)getKeyFromArgument:(NSString*)argument{
    NSMutableDictionary* lookupDict = [argument hasPrefix:COMMAND_LINE_LONG_PREFIX] ? mLongArgumentNameToKey : mShortArgumentNameToKey;
    NSString* key = [lookupDict objectForKey:argument];
    return key;
}

- (void)makeError:(NSError**)err withDescription:(NSString*)description{
    NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                    initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                    autorelease];
    *err = [NSError errorWithDomain:ERROR_DOMAIN code:CONFIG_ERROR userInfo:errorDictionary];
}

- (void)setDefaultValues:(NSMutableDictionary*)args{
    for ( NSString* argumentKey in mKeyToDefaultValue ){
        if ( [args objectForKey:argumentKey] == nil ){
            id defaultValue = [mKeyToDefaultValue objectForKey:argumentKey];
            [args setObject:defaultValue forKey:argumentKey];
        }
    }
}

- (NSString*)helpText{
    NSMutableString* helpText = [[[NSMutableString alloc] init] autorelease];

    [helpText appendString:@"Usage:"];
    if ( [mLongArgumentNameToKey count] ){
        [helpText appendString:@" [options] "];
    }
    [helpText appendString:[mPositionalArguments componentsJoinedByString:@" "]];
    [helpText appendString:@"\n"];

    if ( [mLongArgumentNameToKey count] ){
        [helpText appendString:@"Options\n"];
        for (NSString* argumentName in  mLongArgumentNameToKey ){
            [helpText appendString:@"\t"];
            [helpText appendString:argumentName];

            NSString* key = [mLongArgumentNameToKey objectForKey:argumentName];

            NSArray* objectsForKey = [mShortArgumentNameToKey allKeysForObject:key];
            if ( [objectsForKey count] ){
                [helpText appendString:@", "];
                [helpText appendString:[objectsForKey objectAtIndex:0]];
            }

            NSString* helpTextForKey = [mKeyToHelpText objectForKey:key];
            if ( helpTextForKey ){
                [helpText appendString:@"\t\t"];
                [helpText appendString:helpTextForKey];
            }

            [helpText appendString:@"\n"];
        }
    }

    if ( [mPositionalArguments count] ){
        [helpText appendString:@"\n"];
        [helpText appendString:@"Positional Arguments\n"];
        for (NSString* argumentName in  mPositionalArguments){
            [helpText appendString:@"\t"];
            [helpText appendString:argumentName];

            NSString* helpTextForKey = [mKeyToHelpText objectForKey:argumentName];
            if ( helpTextForKey ){
                [helpText appendString:@"\t\t"];
                [helpText appendString:helpTextForKey];
            }
            [helpText appendString:@"\n"];
        }
    }

    return helpText;
}


@end
