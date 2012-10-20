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
        mShortNames = [[NSMutableDictionary alloc] init];
        mLongNames = [[NSMutableDictionary alloc] init];
        mTypes = [[NSMutableDictionary alloc] init];

        mPositionalArguments = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc{
    [mShortNames release];
    [mLongNames release];
    [mTypes release];
    [mPositionalArguments release];
    [super dealloc];
}

- (void)addArgumentWithName:(NSString*)name ofType:(CommandLineType)type{
    if ( [self isPositionalName:name] ){
        [self addPositionialArgumentForKey:name ofType:type];
    }else{
        NSString* key = [self toKeyFromLongName:name];
        [self addOptionalArgumentForKey:key withName:name ofType:type];
    }
}

- (void)addArgumentWithName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type{
    if ( [self isPositionalName:name] ){
        [self addPositionialArgumentForKey:name ofType:type];
    }else{
        NSString* key = [self toKeyFromLongName:name];
        [self addOptionalArgumentForKey:key withName:name andShortName:shortName ofType:type];
    }
}

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name ofType:(CommandLineType)type{
    [mTypes setObject:[NSNumber numberWithInteger:type] forKey:key];
    [mLongNames setObject:key forKey:name];
}

- (void)addOptionalArgumentForKey:(NSString*)key withName:(NSString*)name andShortName:(NSString*)shortName ofType:(CommandLineType)type{
    [mShortNames setObject:key forKey:name];
    [self addOptionalArgumentForKey:key withName:name ofType:type];
}

- (void)addPositionialArgumentForKey:(NSString*)key ofType:(CommandLineType)type{
    [mTypes setObject:[NSNumber numberWithInteger:type] forKey:key];
    [mPositionalArguments addObject:key];
}


- (NSString*)toKeyFromLongName:(NSString*)name{
    return [name substringFromIndex:[COMMAND_LINE_LONG_PREFIX length]];
}
- (BOOL)isPositionalName:(NSString*)name{
    return ![name hasPrefix: COMMAND_LINE_SHORT_PREFIX];
}

- (CommandLineOptions*)parse:(NSArray*)arguments{
    NSError* err;
    return [self parse:arguments error:&err];
}

- (CommandLineOptions*)parse:(NSArray*)arguments error:(NSError**)err{

    NSMutableArray* positionalArgsStack = [mPositionalArguments mutableCopy];
    NSMutableArray* mutableArguments = [arguments mutableCopy];
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];

    while ( [mutableArguments count] ){
        NSString* argument = [mutableArguments objectAtIndex:0];
        [mutableArguments removeObjectAtIndex: 0];

        //if ([argument hasPrefix:COMMAND_LINE_SHORT_PREFIX] ){
        if ([self isOption:argument] ){
            NSString* key = [self getKeyFromArgument:argument];
            if ( key == nil ){
                NSString* description = [NSString stringWithFormat:@"Unknown argument %@", argument];
                [self makeError:err withDescription:description];

                //TODO memory
                return nil;
            }

            NSString* result = nil;
            if ( ![self isArgument:key ofType:Boolean] ){
                result = [mutableArguments objectAtIndex:0];
                [mutableArguments removeObjectAtIndex: 0];
            }else{
                result = @"Y";
            }
            NSLog(key);
            NSLog(result);

            [args setObject:[self convertString:result toType:[self getArgumentType:key]] forKey: key];
        }else{
            if ( [positionalArgsStack count] == 0 ){
                NSString* description = [NSString stringWithFormat:@"Unexpected positional argument %@", argument];
                [self makeError:err withDescription:description];

                //TODO Mem
                return nil;
            }
            NSString* positionalArgumentKey = [positionalArgsStack objectAtIndex:0];
            [positionalArgsStack removeObjectAtIndex:0];
            [args setObject:argument forKey: positionalArgumentKey];
        }
    }


    if ( [positionalArgsStack count] > 0 ){
        NSString* description = [NSString stringWithFormat:@"There were still positional arguments required"];

        NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                        initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                        autorelease];
        *err = [NSError errorWithDomain:ERROR_DOMAIN code:CONFIG_ERROR userInfo:errorDictionary];

        //TODO Mem
        return nil;
    }

    //set all arguments that are booleans and unset to false
    for ( NSString* name in mLongNames ){
        if ( [self isArgument:name ofType:Boolean] ){
            if ( [args objectForKey:name] == nil ){
                [args setObject:[NSNumber numberWithBool:NO] forKey:name];
            }
        }
    }

    CommandLineOptions* toReturn = [[[CommandLineOptions alloc] initWithCommandLineOptions:args] autorelease];
    
    //TODO memroy
    return toReturn;
}

- (BOOL)isArgument:(NSString*)key ofType:(CommandLineType)type{
    NSNumber* wrappedType = [mTypes objectForKey:key];
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
   return [[mTypes objectForKey:argumentKey] intValue];
}


- (BOOL)isOption:(NSString*)argument{
    return [argument hasPrefix:COMMAND_LINE_SHORT_PREFIX];
}

- (NSString*)getKeyFromArgument:(NSString*)argument{
    NSMutableDictionary* lookupDict = [argument hasPrefix:COMMAND_LINE_LONG_PREFIX] ? mLongNames : mShortNames;
    NSString* key = [lookupDict objectForKey:argument];
    return key;
}

- (void)makeError:(NSError**)err withDescription:(NSString*)description{
    NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                    initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                    autorelease];
    *err = [NSError errorWithDomain:ERROR_DOMAIN code:CONFIG_ERROR userInfo:errorDictionary];
}

@end
