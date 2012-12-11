#import "ConfigurationSerilizer.h"
#import "TimeSpan.h"
#import "ErrorConstants.h"
#import "NumericConversion.h"

static NSString* COMMENT_TOKEN = @"#";
static NSString* SIMPLE_ASSIGNMENT_SEPERATOR = @"=";
static NSString* EQUATION_SEPERATOR = @":";

@implementation ConfigurationTextSerilizer
+ (ReactionEquation*)parseEquationComponents:(NSString*)reaction error:(NSError**)err{
    ReactionEquation* result = [[[ReactionEquation alloc] init] autorelease];

    if ( [reaction rangeOfString:@"->"].location == NSNotFound ){
         [self makeError:err withDescription:@"No -> found in function body"];
         return nil;
    }

    NSArray* lhsAndRhs = [reaction componentsSeparatedByString: @"->"];
    NSString* requirementString = [lhsAndRhs objectAtIndex:0];

    NSCountedSet* req = [self parsePartOfEquationComponents:requirementString error:err];
    if ( req == nil ){
        return nil;
    }
    [result setRequirements:req];

    NSString* resultString = [lhsAndRhs objectAtIndex:1];
    NSCountedSet* resultParseResult = [self parsePartOfEquationComponents:resultString error:err];
    if ( resultParseResult == nil ){
        return nil;
    }
    [result setResult:resultParseResult];

    return result;
}

+ (NSCountedSet*)parsePartOfEquationComponents:(NSString*)part error:(NSError**)err{
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    part = [self trimWhiteSpace:part];

    if ( [part length] == 0 ){
        return result;
    }

    NSArray* partReactionComponents = [part componentsSeparatedByString: @"+"];

    for ( NSString* component in partReactionComponents ){
        NSString* strippedString = [self trimWhiteSpace:component];
        if ( [strippedString length] == 0 ){
            [self makeError:err withDescription:@"No molecule idenfier"];
            return nil;
        }
        [result addObject:strippedString];
    }

    return result;
}

+ (SimulationConfiguration*)deserilize:(NSString*)input{
    NSError* err;
    return [self deserilize:input error:&err];
}

+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err{
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];

    NSArray* lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for ( int lineIdx = 0; lineIdx < [lines count]; ++lineIdx ){ 
        const int lineNumber = lineIdx + 1;
        NSString* line = [lines objectAtIndex:lineIdx];

        line = [self removeCommentFromLine:line];
        line = [self trimWhiteSpace:line];

        if ( [line length] == 0 ){
            continue;
        }

        if ([line rangeOfString:SIMPLE_ASSIGNMENT_SEPERATOR].location != NSNotFound ){
            BOOL success = [self parseSimpleAssignmentForCfg:cfg fromLine:line lineNumber:lineNumber error:err];
            if ( !success ){
                return nil;
            }
        } else if ([line rangeOfString:EQUATION_SEPERATOR].location != NSNotFound ){
            BOOL success = [self parseEquationForCfg:cfg fromLine:line lineNumber:lineNumber error:err];
            if ( !success ){
                return nil;
            }
        } else {
            NSString* description = [NSString stringWithFormat:@"Line <%i>: Line was not parseable",
                                                               lineNumber];
            [self makeError:err withDescription:description];
            return nil;
        }
    }

    return cfg;
}

+ (BOOL)parseSimpleAssignmentForCfg:(SimulationConfiguration*)cfg
                           fromLine:(NSString*)line
                         lineNumber:(int)lineNumber
                              error:(NSError**)err{
    NSMutableArray* keyValue = [[line componentsSeparatedByString:SIMPLE_ASSIGNMENT_SEPERATOR] mutableCopy];
    if ( [keyValue count] != 2 ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Too many <%@> symbols",
                                                           lineNumber,
                                                           SIMPLE_ASSIGNMENT_SEPERATOR];
        [self makeError:err withDescription:description];
        [keyValue release];
        return NO;
    }

    NSString* key = [self trimWhiteSpace:[keyValue objectAtIndex:0]];
    NSString* value = [self trimWhiteSpace:[keyValue objectAtIndex:1]];
    [keyValue release];

    if ( [key isEqualToString:@"t"] || [key isEqualToString:@"time"] ){
        if ( ![self parseTimeForCfg:cfg value:value lineNumber:lineNumber error:err] ){
            return NO;
        }
    }else if ( [self isVariableMoleculeCount:key] ){
       if ( ![self parseMoleculeAssignmentForCfg:cfg key:key value:value lineNumber:lineNumber error:err] ){
           return NO;
       }
    }else if ( [self isKineticConstant:key] ){
       if ( ![self parseKineticConstantAssignmentForCfg:cfg key:key value:value lineNumber:lineNumber error:err] ){
           return NO;
       }
    }else{
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Invalid identifier on the LHS",
                                                           lineNumber];
        [self makeError:err withDescription:description];
        return NO;
    }
    return YES;
}

+ (BOOL)parseTimeForCfg:(SimulationConfiguration*)cfg
                  value:(NSString*)value
             lineNumber:(int)lineNumber
                  error:(NSError**)err{
    NSNumber* number = [NumericConversion decimalWithString:value];
    if ( number == nil ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: The time was not a valid number",
                                                           lineNumber];
        [self makeError:err withDescription:description];
        return NO;
    }

    double timeDoubleValue = [number doubleValue];
    if ( timeDoubleValue < 0 ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: The time should not be less than 0",
                                                           lineNumber];
        [self makeError:err withDescription:description];
        return NO;
    }

    TimeSpan* ts = [[TimeSpan alloc] initFromSeconds:timeDoubleValue];
    [cfg setTime:ts];
    [ts release];

    return YES;
}

+ (BOOL)parseMoleculeAssignmentForCfg:(SimulationConfiguration*)cfg
                                  key:(NSString*)key
                                value:(NSString*)value
                           lineNumber:(int)lineNumber
                                error:(NSError**)err{

    NSNumber* number = [NumericConversion intWithString:value];
    if ( number == nil ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Molecule count <%@> was not set to a value of a int",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    if ( [number doubleValue] < 0 ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Molecule count <%@> should not be less than 0",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    BOOL moleculeSetCorrectly = [cfg addMoleculeCount:key count:[number intValue]];
    if ( !moleculeSetCorrectly ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Molecule <%@> was already set",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    return YES;
}

+ (BOOL)parseKineticConstantAssignmentForCfg:(SimulationConfiguration*)cfg
                                  key:(NSString*)key
                                value:(NSString*)value
                           lineNumber:(int)lineNumber
                                error:(NSError**)err{
    NSDecimalNumber* number = [NumericConversion decimalWithString:value];
    if ( number == nil ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Kinetic constant <%@> was not set to a value of a double",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    if ( [number doubleValue] < 0 ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Kinetic constant <%@> should not be less than 0",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    KineticConstant* constant = [[KineticConstant alloc] initWithDouble:[number doubleValue] ];
    BOOL kineticConstantSetCorrectly = [cfg addKineticConstant:key kineticConstant:constant];
    [constant release];

    if ( !kineticConstantSetCorrectly ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Kinetic Constant <%@> was already set",
                                                           lineNumber,
                                                           key];
        [self makeError:err withDescription:description];
        return NO;
    }
    return YES;
}

+ (BOOL)parseEquationForCfg:(SimulationConfiguration*)cfg
                   fromLine:(NSString*)line
                 lineNumber:(int)lineNumber
                      error:(NSError**)err{
    NSArray* reactionNameAndDef = [line componentsSeparatedByString: EQUATION_SEPERATOR];
    NSString* reactionName = [reactionNameAndDef objectAtIndex:0];
    reactionName = [self trimWhiteSpace:reactionName];

    NSString* reactionComponentStr = [reactionNameAndDef objectAtIndex:1];

    NSError* reactionError;
    ReactionEquation* reactionEquation = [self parseEquationComponents:reactionComponentStr error:&reactionError];
    if ( reactionEquation == nil ){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: %@",
                                                           lineNumber,
                                                           [reactionError localizedDescription]];

        [self makeError:err withDescription:description];
        return NO;
    }

    BOOL reactionSetCorrectly = [cfg addReactionEquation: reactionName reactionEquation:reactionEquation];
    if ( !reactionSetCorrectly){
        NSString* description = [NSString stringWithFormat:@"Line <%i>: Reaction Equation <%@> was already set",
                                                           lineNumber,
                                                           reactionName];
        [self makeError:err withDescription:description];
        return NO;
    }
    return YES;
}

+ (NSString*)trimWhiteSpace:(NSString*)str{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isVariableMoleculeCount:(NSString*)var {
    BOOL isLetter = [[NSCharacterSet letterCharacterSet] characterIsMember:[var characterAtIndex:0]];
    BOOL isUpperCase = [var characterAtIndex:0] == [[var uppercaseString] characterAtIndex:0];

    return isLetter && isUpperCase;
}
+ (BOOL)isKineticConstant:(NSString*)var{
    BOOL isLetter = [[NSCharacterSet letterCharacterSet] characterIsMember:[var characterAtIndex:0]];
    BOOL isLowerCase = [var characterAtIndex:0] == [[var lowercaseString] characterAtIndex:0];

    return isLetter && isLowerCase;
}

+ (NSString*)removeCommentFromLine:(NSString*)line {
    const NSUInteger commentTokenLocation = [line rangeOfString:COMMENT_TOKEN].location;
    if ( commentTokenLocation != NSNotFound ){
        return [line substringToIndex:commentTokenLocation];
    }
    return line;
}

+ (void)makeError:(NSError**)err withDescription:(NSString*)description{
    NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                    initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                    autorelease];
    *err = [NSError errorWithDomain:ERROR_DOMAIN code:CFG_PARSE_ERROR userInfo:errorDictionary];
}

@end
