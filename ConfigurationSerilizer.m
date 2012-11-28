#import "ConfigurationSerilizer.h"
#import "TimeSpan.h"

static NSString* COMMENT_TOKEN = @"#";
static NSString* SIMPLE_ASSIGNMENT_SEPERATOR = @"=";
static NSString* EQUATION_SEPERATOR = @":";

@implementation ConfigurationTextSerilizer
+ (ReactionEquation*)parseReactionComponents:(NSString*)reaction{
    NSArray* components = [reaction componentsSeparatedByString: @"->"];

    ReactionEquation* result = [[[ReactionEquation alloc] init] autorelease];

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
    NSError** err;
    return [self deserilize:input error:err];
}

+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err{
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];

    NSArray* lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for ( int lineIdx = 0; lineIdx < [lines count]; ++lineIdx ){ 
        NSString* line = [lines objectAtIndex:lineIdx];

        line = [self removeCommentFromLine:line];
        line = [self trimWhiteSpace:line];

        if ( [line length] == 0 ){
            continue;
        }

        if ([line rangeOfString:SIMPLE_ASSIGNMENT_SEPERATOR].location != NSNotFound ){
            NSMutableArray* keyValue = [[line componentsSeparatedByString:SIMPLE_ASSIGNMENT_SEPERATOR] mutableCopy];
            if ( [keyValue count] != 2 ){
                //error
            }

            NSString* key = [self trimWhiteSpace:[keyValue objectAtIndex:0]];
            NSString* value = [self trimWhiteSpace:[keyValue objectAtIndex:1]];

            if ( [key isEqualToString:@"t"] ){
                TimeSpan* ts = [[TimeSpan alloc] initFromSeconds:[value doubleValue]];
                [cfg setTime:ts];
                [ts release];
            }else if ( [self isVariableMoleculeCount:key] ){
                [cfg addMoleculeCount:key count:[value intValue]];
            } else{
                KineticConstant* constant = [[KineticConstant alloc] initWithDouble:[value doubleValue] ];
                [cfg addKineticConstant: key kineticConstant:constant];
                [constant release];
            }
            [keyValue release];

        } else if ([line rangeOfString:EQUATION_SEPERATOR].location != NSNotFound ){
            NSArray* reactionNameAndDef = [line componentsSeparatedByString: EQUATION_SEPERATOR];
            NSString* reactionName = [reactionNameAndDef objectAtIndex:0];
            reactionName = [self trimWhiteSpace:reactionName];

            NSString* reactionComponentStr = [reactionNameAndDef objectAtIndex:1];
            ReactionEquation* reactionEquation = [self parseReactionComponents:reactionComponentStr];

            [cfg addReactionEquation: reactionName reactionEquation:reactionEquation];
        } else {
            //error
        }

    }

    return cfg;
}

+ (NSString*)trimWhiteSpace:(NSString*)str{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isVariableMoleculeCount:(NSString*)var {
    return [var characterAtIndex:0] == [[var uppercaseString] characterAtIndex:0];
}

+ (NSString*)removeCommentFromLine:(NSString*)line {
    const NSUInteger commentTokenLocation = [line rangeOfString:COMMENT_TOKEN].location;
    if ( commentTokenLocation != NSNotFound ){
        return [line substringToIndex:commentTokenLocation];
    }
    return line;
}

@end
