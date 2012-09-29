#import "ConfigurationSerilizer.h"
#import "TimeSpan.h"

@implementation ConfigurationTextSerilizer
+ (ReactionComponents*)parseReactionComponents:(NSString*)reaction{
    NSArray* components = [reaction componentsSeparatedByString: @"->"];

    ReactionComponents* result = [[[ReactionComponents alloc] init] autorelease];

    NSString* requirementString = [components objectAtIndex:0];
    [result setRequirements:[self parsePartOfReactionComponents:requirementString]];

    NSString* resultString = [components objectAtIndex:1];
    [result setResult:[self parsePartOfReactionComponents:resultString]];

    return result;
}

+ (NSCountedSet*)parsePartOfReactionComponents:(NSString*)part{
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    part = [part stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    if ( [part length] == 0 ){
        return result;
    }

    if ([part rangeOfString:@"+"].location != NSNotFound ){
        NSArray* partReactionComponents = [part componentsSeparatedByString: @"+"];

        for ( NSString* component in partReactionComponents ){
            NSString* strippedString = [component stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [result addObject:strippedString];
        }
    }else{
        [result addObject:part];
    }

    return result;
}

+ (SimulationConfiguration*)deserilize:(NSString*)input{
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];

    NSArray* lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    NSMutableDictionary* kineticConstants = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* reactions = [[NSMutableDictionary alloc] init];

    for ( NSString* line in lines ){
        if ([line hasPrefix:@"#"]){
            continue;
        }

        if ([line rangeOfString:@"="].location != NSNotFound ){
            NSMutableArray* keyValue = [[line componentsSeparatedByString: @"="] mutableCopy];
            for ( int i = 0; i < [keyValue count]; ++i ){
                NSString* string = [keyValue objectAtIndex:i];
                [keyValue replaceObjectAtIndex:i withObject:[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
            }

            NSString* key = [keyValue objectAtIndex:0];
            NSString* value = [keyValue objectAtIndex:1];
            if ( [key isEqualToString:@"t"] ){
                TimeSpan* ts = [[TimeSpan alloc] initFromSeconds:[value doubleValue]];
                [cfg setTime:ts];
                [ts release];
            }else if ( [key characterAtIndex:0] == [[key uppercaseString] characterAtIndex:0]){
                [cfg addMoleculeCount:key count:[value intValue]];
            } else{
                KineticConstant* constant = [[KineticConstant alloc] initWithDouble:[value doubleValue] ];
                [kineticConstants setObject:constant forKey:key];
                [constant release];
            }
            [keyValue release];
        } else if ([line rangeOfString:@":"].location != NSNotFound ){
            NSArray* reactionNameAndDef = [line componentsSeparatedByString: @":"];
            NSString* reactionName = [reactionNameAndDef objectAtIndex:0];
            reactionName = [reactionName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

            NSString* reactionComponentStr = [reactionNameAndDef objectAtIndex:1];
            ReactionComponents* reactionComonents = [self parseReactionComponents:reactionComponentStr];

            [reactions setObject:reactionComonents forKey:reactionName];
        }

    }

    for (NSString* reactionName in  kineticConstants) {
        KineticConstant* constant = [kineticConstants objectForKey:reactionName];
        ReactionComponents* reactionComponents = [reactions objectForKey:reactionName];

        [cfg addReaction:reactionName kineticConstant:constant reactionComponents:reactionComponents];
    }

    [kineticConstants release];
    [reactions release];

    return cfg;
}

@end
