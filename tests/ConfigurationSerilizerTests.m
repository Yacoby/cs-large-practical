#import "Testing.h"
#import "TestingExtension.h"
#import <Foundation/Foundation.h>

#import "ConfigurationSerilizer.h"
#import "ReactionDefinition.h"

void testDeserilize_WhenHasTime_ParsesTimeCorrectly(){
    NSString* configurationStr1 = @"t = 10\n";
    SimulationConfiguration* cfg1 = [ConfigurationTextSerilizer deserilize:configurationStr1];
    PASS_INT_EQUAL([[cfg1 time] totalSeconds], 10, "Time should be 10");

    NSString* configurationStr2 = @"t = 20\n";
    SimulationConfiguration* cfg2 = [ConfigurationTextSerilizer deserilize:configurationStr2];
    PASS_INT_EQUAL([[cfg2 time] totalSeconds], 20, "Time should be 20");
}

void testDeserilize_WhenHasComment_DoesNotAffectParsing(){
    NSString* configurationStr = @"#comment\nt = 10\n#comment";
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:configurationStr];
    PASS_INT_EQUAL([[cfg time] totalSeconds], 10, "Time should be 10 and comments should be ignored");
}

void testDeserilize_WhenHasTimeAndKineticConstant_ParsesConstantCorrectly(){
    NSString* configurationStr = @"t = 10\nd = 5";
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:configurationStr];
    ReactionDefinition* reaction = [cfg reaction:@"d"];
    PASS_INT_EQUAL([[reaction kineticConstant] doubleValue], 5, "");
}

void testDeserilize_WhenHasBasicReaction_ParsesReactionCorrectly(){
    NSString* configurationStr = @"p = 1\np : F -> A";
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:configurationStr];
    ReactionDefinition* reaction = [cfg reaction:@"p"];

    PASS_INT_EQUAL([[reaction requirements] countForObject:@"F"], 1, "");
    PASS_INT_EQUAL([[reaction requirements] count], 1, "There is only one requirement for the reaction");

    PASS_INT_EQUAL([[reaction result] countForObject:@"A"], 1, "The result of the reaction should be A");
    PASS_INT_EQUAL([[reaction result] count], 1, "There should be only one result from the reaction");
}

void testDeserilize_WhenHasDestructiveReaction_ParsesReactionCorrectly(){
    NSString* configurationStr = @"p = 1\np : F ->";
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:configurationStr];
    ReactionDefinition* reaction = [cfg reaction:@"p"];

    PASS_INT_EQUAL([[reaction requirements] countForObject:@"F"], 1, "");
    PASS_INT_EQUAL([[reaction requirements] count], 1, "");

    PASS_INT_EQUAL([[reaction result] count], 0, "There should be no results of the reaction");
}

void testDeserilize_WhenHasMoleculeCount_ParsesCorrectly(){
    NSString* configurationStr = @"E = 10\n";
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:configurationStr];

    PASS_INT_EQUAL([cfg moleculeCount:@"E"], 10, "Molecule count should be 10");
}

void testParseReactionComponents_WhenHasBasicReaction_ParsesCorrectly(){
    NSString* reactionString = @" A -> B";

    NSError* error;
    ReactionEquation* equation = [ConfigurationTextSerilizer parseReactionComponents:reactionString error:&error];

    PASS_INT_EQUAL([[equation requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[equation requirements] count], 1, "");

    PASS_INT_EQUAL([[equation result] countForObject:@"B"], 1, "");
    PASS_INT_EQUAL([[equation result] count], 1, "");
}

void testParseReactionComponents_WhenHasDesctuctiveReaction_ParsesCorrectly(){
    NSString* reactionString = @" A -> ";
    NSError* error;
    ReactionEquation* equation = [ConfigurationTextSerilizer parseReactionComponents:reactionString error:&error];

    PASS_INT_EQUAL([[equation requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[equation requirements] count], 1, "");

    PASS_INT_EQUAL([[equation result] count], 0, "");
}

void testParseReactionComponents_WhenHasCreativeReaction_ParsesCorrectly(){
    NSString* reactionString = @" -> A";
    NSError* error;
    ReactionEquation* equation = [ConfigurationTextSerilizer parseReactionComponents:reactionString error:&error];

    PASS_INT_EQUAL([[equation requirements] count], 0, "");

    PASS_INT_EQUAL([[equation result] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[equation result] count], 1, "");
}

void testParseReactionComponents_WhenHasTwoRequirements_ParsesCorrectly(){
    NSString* reactionString = @"A + B -> C";
    NSError* error;
    ReactionEquation* equation = [ConfigurationTextSerilizer parseReactionComponents:reactionString error:&error];

    PASS_INT_EQUAL([[equation requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[equation requirements] countForObject:@"B"], 1, "");
    PASS_INT_EQUAL([[equation requirements] count], 2, "");

    PASS_INT_EQUAL([[equation result] countForObject:@"C"], 1, "");
    PASS_INT_EQUAL([[equation result] count], 1, "");
}

void testDeserilize_WhenHasTwoEquals_Error(){
    NSString* cfgString = @"a = 2 = 3";

    NSError* err;
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:cfgString error:&err];
    PASS(cfg == nil, "Should fail to parse");

    NSString* reason = [err localizedDescription];
    NSString* expectedReason = @"Line <1>: Too many <=> symbols";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void testDeserilize_WhenHasInvalidFunctionBody_Error(){
    NSString* cfgString = @"f : A";

    NSError* err;
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:cfgString error:&err];
    PASS(cfg == nil, "Should fail to parse");

    NSString* reason = [err localizedDescription];
    NSString* expectedReason = @"Line <1>: No -> found in function body";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void testDeserilize_WhenHasInvalidIdentifier_Error(){
    NSString* cfgString = @"24 = 5";

    NSError* err;
    SimulationConfiguration* cfg = [ConfigurationTextSerilizer deserilize:cfgString error:&err];
    PASS(cfg == nil, "Should fail to parse");

    NSString* reason = [err localizedDescription];
    NSString* expectedReason = @"Line <1>: Invalid identifier on the LHS";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

int main()
{
    START_SET("ConfigurationTextSerilizer")
        testDeserilize_WhenHasTime_ParsesTimeCorrectly();
        testDeserilize_WhenHasComment_DoesNotAffectParsing();
        testDeserilize_WhenHasTimeAndKineticConstant_ParsesConstantCorrectly();

        testDeserilize_WhenHasBasicReaction_ParsesReactionCorrectly();
        testDeserilize_WhenHasDestructiveReaction_ParsesReactionCorrectly();

        testDeserilize_WhenHasMoleculeCount_ParsesCorrectly();

        testParseReactionComponents_WhenHasBasicReaction_ParsesCorrectly();

        testParseReactionComponents_WhenHasDesctuctiveReaction_ParsesCorrectly();
        testParseReactionComponents_WhenHasCreativeReaction_ParsesCorrectly();
        testParseReactionComponents_WhenHasTwoRequirements_ParsesCorrectly();


        testDeserilize_WhenHasTwoEquals_Error();
        testDeserilize_WhenHasInvalidFunctionBody_Error();
        testDeserilize_WhenHasInvalidIdentifier_Error();
    END_SET("ConfigurationTextSerilizer")

    return 0;
}

