#import "Testing.h"
#import "TestingExtension.h"
#import <Foundation/Foundation.h>

#import "ConfigurationSerilizer.h"
#import "ReactionDefinition.h"

void testDeserilize_WhenHasTime_ParsesTimeCorrectly(){
    NSString* configurationStr1 = @"t = 10\n";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr1] time], 10, "");

    NSString* configurationStr2 = @"t = 20\n";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr2] time], 20, "");
}

void testDeserilize_WhenHasComment_DoesNotAffectParsing(){
    NSString* configurationStr = @"#comment\nt = 10\n#comment";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr] time], 10, "");
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
    ReactionComponents* components = [ConfigurationTextSerilizer parseReactionComponents:reactionString];

    PASS_INT_EQUAL([[components requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[components requirements] count], 1, "");

    PASS_INT_EQUAL([[components result] countForObject:@"B"], 1, "");
    PASS_INT_EQUAL([[components result] count], 1, "");
}

void testParseReactionComponents_WhenHasDesctuctiveReaction_ParsesCorrectly(){
    NSString* reactionString = @" A -> ";
    ReactionComponents* components = [ConfigurationTextSerilizer parseReactionComponents:reactionString];

    PASS_INT_EQUAL([[components requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[components requirements] count], 1, "");

    PASS_INT_EQUAL([[components result] count], 0, "");
}

void testParseReactionComponents_WhenHasCreativeReaction_ParsesCorrectly(){
    NSString* reactionString = @" -> A";
    ReactionComponents* components = [ConfigurationTextSerilizer parseReactionComponents:reactionString];

    PASS_INT_EQUAL([[components requirements] count], 0, "");

    PASS_INT_EQUAL([[components result] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[components result] count], 1, "");
}

void testParseReactionComponents_WhenHasTwoRequirements_ParsesCorrectly(){
    NSString* reactionString = @"A + B -> C";
    ReactionComponents* components = [ConfigurationTextSerilizer parseReactionComponents:reactionString];

    PASS_INT_EQUAL([[components requirements] countForObject:@"A"], 1, "");
    PASS_INT_EQUAL([[components requirements] countForObject:@"B"], 1, "");
    PASS_INT_EQUAL([[components requirements] count], 2, "");

    PASS_INT_EQUAL([[components result] countForObject:@"C"], 1, "");
    PASS_INT_EQUAL([[components result] count], 1, "");
}

int main()
{
    START_SET("ConfigurationTxtSerilizer")
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
    END_SET("ConfigurationTxtSerilizer")

    return 0;
}

