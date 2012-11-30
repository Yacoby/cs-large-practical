#import "Testing.h"
#import "TestingExtension.h"
#import "SimulationConfiguration.h"

void addReaction_WhenAddsReaction_HasReactionForKey(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];

    ReactionEquation* components = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* required = [[[NSCountedSet alloc] init] autorelease];
    [components setRequirements:required];

    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    [components setResult:result];

    KineticConstant* kConst = [[[KineticConstant alloc] initWithDouble:0] autorelease];

    [underTest addReactionEquation:@"key" reactionEquation:components];
    [underTest addKineticConstant:@"key" kineticConstant:kConst ];

    ReactionDefinition* reaction = [underTest reaction:@"key"];

    PASS_EQUAL([reaction kineticConstant], kConst, "");
    PASS_EQUAL([reaction requirements], required, "");
    PASS_EQUAL([reaction result], result, "");
}

void addReactionEquation_WhenHasDuplicate_ReturnsNo(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];
    ReactionEquation* eqn = [[[ReactionEquation alloc] init] autorelease];

    PASS_INT_EQUAL([underTest addReactionEquation:@"key" reactionEquation:eqn], YES, "");
    PASS_INT_EQUAL([underTest addReactionEquation:@"key" reactionEquation:eqn], NO, "");
}

void addKineticConstant_WhenHasDuplicate_ReturnsNo(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];
    KineticConstant* k = [[[KineticConstant alloc] init] autorelease];

    PASS_INT_EQUAL([underTest addKineticConstant:@"key" kineticConstant:k], YES, "");
    PASS_INT_EQUAL([underTest addKineticConstant:@"key" kineticConstant:k], NO, "");
}

void addMoleculeCount_WhenHasDuplicate_ReturnsNo(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];

    PASS_INT_EQUAL([underTest addMoleculeCount:@"key" count:5], YES, "");
    PASS_INT_EQUAL([underTest addMoleculeCount:@"key" count:1], NO, "");

    PASS_INT_EQUAL([underTest moleculeCount:@"key"], 5, "Only takes into account the first value set");
}

void validate_WhenHasNoTime_Fails(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];

    ConfigurationValidation* result = [underTest validate];
    PASS([[result errors] count] > 0 , "There must be some form of error");

    NSSet* errors = [result errors];
    PASS_INT_EQUAL([errors count], 1, "");
    NSString* expectedReason = @"time (t) was not set";
    NSString* reason = [errors anyObject];

    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void validate_WhenHasNoKineticConstantForEqn_Fails(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];
    [underTest setTime:[[[TimeSpan alloc] initFromSeconds:20] autorelease]];

    KineticConstant* k = [[[KineticConstant alloc] init] autorelease];
    [underTest addKineticConstant:@"key" kineticConstant:k];

    NSError* result = [underTest validate];
    PASS([[result warnings] count] > 0 , "There must be some form of warning");

    NSSet* warnings = [result warnings];
    NSSet* errors = [result errors];
    PASS_INT_EQUAL([warnings count], 1, "");
    PASS_INT_EQUAL([errors count], 0, "");
    NSString* expectedReason = @"The kinetic constant <key> has no reaction equation";
    NSString* reason = [errors anyObject];

    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void validate_ReactionMentionsMoleculeThatDoesntExist_Fails(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];
    [underTest setTime:[[[TimeSpan alloc] initFromSeconds:20] autorelease]];

    KineticConstant* k = [[[KineticConstant alloc] init] autorelease];
    [underTest addKineticConstant:@"reaction" kineticConstant:k];

    ReactionEquation* eqn = [[[ReactionEquation alloc] init] autorelease];
    [underTest addReactionEquation:@"reaction" reactionEquation:eqn];

    NSCountedSet* req = [[[NSCountedSet alloc] init] autorelease];
    [req addObject:@"key"];
    [eqn setRequirements:req];


    NSError* result = [underTest validate];
    PASS([[result errors] count] > 0 , "There must be some form of error");

    NSSet* errors = [result errors];
    PASS_INT_EQUAL([errors count], 1, "");
    NSString* expectedReason = @"Molecule <key> in reaction equation <reaction> has no count";
    NSString* reason = [errors anyObject];

    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

int main() {
    START_SET("SimulationConfiguration")
        addReaction_WhenAddsReaction_HasReactionForKey();
        addReactionEquation_WhenHasDuplicate_ReturnsNo();
        addKineticConstant_WhenHasDuplicate_ReturnsNo();
        addMoleculeCount_WhenHasDuplicate_ReturnsNo();

        validate_WhenHasNoTime_Fails();
        validate_WhenHasNoKineticConstantForEqn_Fails();
        validate_ReactionMentionsMoleculeThatDoesntExist_Fails();
    END_SET("SimulationConfiguration")

    return 0;
}
