#import "CommandLineOptionParser.h"
#import "ErrorConstants.h"

@implementation CommandLineOptions
- (id)initWithCommandLineOptions:(NSDictionary*)options{
    self = [super init];
    if ( self != nil ){
        [options retain];
        mOptions = options;
    }
    return self;
}
- (void)dealloc{
    [mOptions release];
    [super dealloc];
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

        mPositionalArguments = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc{
    [mShortArgumentNameToKey release];
    [mLongArgumentNameToKey release];
    [mKeyToType release];
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

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type{
    [mKeyToType setObject:[NSNumber numberWithInteger:type] forKey:key];
    [mLongArgumentNameToKey setObject:key forKey:name];
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

    if ( [remaingPositionalArgs count] > 0 ){
        NSString* remainingArgs = [remaingPositionalArgs componentsJoinedByString:@","];
        [remainingArgs retain];
        [pool drain];

        NSString* description = [NSString stringWithFormat:@"There were still positional arguments required: %@", remainingArgs];
        [remainingArgs release];
        [self makeError:err withDescription:description];
        return nil;
    }
    [self setUnsetBooleansToFalse:parsedArguments];

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

- (void)setUnsetBooleansToFalse:(NSMutableDictionary*)args{
    for ( NSString* argumentName in mLongArgumentNameToKey ){
        NSString* argumentKey = [mLongArgumentNameToKey objectForKey:argumentName];
        if ( [self isArgument:argumentKey ofType:Boolean] &&
             [args objectForKey:argumentKey] == nil ){
            [args setObject:[NSNumber numberWithBool:NO] forKey:argumentKey];
        }
    }
}

@end
