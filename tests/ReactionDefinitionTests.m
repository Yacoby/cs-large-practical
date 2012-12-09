#import "Testing.h"
#import "TestingExtension.h"
#import "ReactionDefinition.h"

void reactionRate_WhenHasSingleReq_RateEqualsSimpleMult(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                                                                    @"A",
                                                                                    nil];

    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc]
                                                initWithTime:time moleculeCount:counts]
                                                autorelease];

    PASS_INT_EQUAL([underTest reactionRate:state], 5*6, "");
}

void reactionRate_WhenHasNonDuplicate_RateEqualsSimpleMult(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", @"B", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                                                                    @"A",
                                                                                    [NSNumber numberWithInt:7],
                                                                                    @"B",
                                                                                    nil];

    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc]
                                                initWithTime:time moleculeCount:counts]
                                                autorelease];

    PASS_INT_EQUAL([underTest reactionRate:state], 5*6*7, "");
}

void reactionRate_WhenHasDuplicate_RateEqualsComplexMult(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", @"A", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                                                                    @"A",
                                                                                    nil];

    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc]
                                                initWithTime:time moleculeCount:counts]
                                                autorelease];

    PASS_INT_EQUAL([underTest reactionRate:state], 5*6*(6-1)*0.5, "");
}

void applyReactonToCounts_WhenHasSimpleReaction_AltersCountsCorrectly(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc]
                                           initWithObjects:@"B", nil]
                                           autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],
                                                                                    @"A",
                                                                                    [NSNumber numberWithInt:0],
                                                                                    @"B",
                                                                                    nil];
    [underTest applyReactionToCounts:counts];


    PASS_INT_EQUAL([[counts objectForKey:@"A"] intValue], 0, "");
    PASS_INT_EQUAL([[counts objectForKey:@"B"] intValue], 1, "");
}

void applyReactonToCounts_WhenHasDestructiveReaction_AltersCountsCorrectly(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc]
                                           init]
                                           autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],
                                                                                    @"A",
                                                                                    nil];

    [underTest applyReactionToCounts:counts];

    PASS_INT_EQUAL([[counts objectForKey:@"A"] intValue], 1, "");
}

void applyReactonToCounts_WhenHasCreativeReaction_AltersCountsCorrectly(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 init]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc]
                                           initWithObjects:@"A", nil]
                                           autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],
                                                                                    @"A",
                                                                                    nil];

    [underTest applyReactionToCounts:counts];

    PASS_INT_EQUAL([[counts objectForKey:@"A"] intValue], 3, "");
}

void applyReactonToCounts_WhenHasReactionWithMultipleReqAndResults_AltersCountsCorrectly(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", @"B", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc]
                                           initWithObjects:@"C", @"D", nil]
                                           autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],
                                                                                    @"A",
                                                                                    [NSNumber numberWithInt:1],
                                                                                    @"B",
                                                                                    [NSNumber numberWithInt:0],
                                                                                    @"C",
                                                                                    [NSNumber numberWithInt:0],
                                                                                    @"D",
                                                                                    nil];

    [underTest applyReactionToCounts:counts];

    PASS_INT_EQUAL([[counts objectForKey:@"A"] intValue], 0, "");
    PASS_INT_EQUAL([[counts objectForKey:@"B"] intValue], 0, "");
    PASS_INT_EQUAL([[counts objectForKey:@"C"] intValue], 1, "");
    PASS_INT_EQUAL([[counts objectForKey:@"D"] intValue], 1, "");
}

void applyReactonToCounts_WhenHasReactionWithDuplicates_AltersCountsCorrectly(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc]
                                                 initWithObjects:@"A", @"A", nil]
                                                 autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc]
                                           initWithObjects:@"B", @"B", nil]
                                           autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],
                                                                                    @"A",
                                                                                    [NSNumber numberWithInt:0],
                                                                                    @"B",
                                                                                    nil];

    [underTest applyReactionToCounts:counts];

    PASS_INT_EQUAL([[counts objectForKey:@"A"] intValue], 0, "");
    PASS_INT_EQUAL([[counts objectForKey:@"B"] intValue], 2, "");
}

int main(){
    START_SET("ReactionDefinition")
        reactionRate_WhenHasSingleReq_RateEqualsSimpleMult();
        reactionRate_WhenHasNonDuplicate_RateEqualsSimpleMult();
        reactionRate_WhenHasDuplicate_RateEqualsComplexMult();

        applyReactonToCounts_WhenHasDestructiveReaction_AltersCountsCorrectly();
        applyReactonToCounts_WhenHasReactionWithMultipleReqAndResults_AltersCountsCorrectly();
        applyReactonToCounts_WhenHasCreativeReaction_AltersCountsCorrectly();
        applyReactonToCounts_WhenHasReactionWithDuplicates_AltersCountsCorrectly();
    END_SET("ReactionDefinition")

    return 0;
}
