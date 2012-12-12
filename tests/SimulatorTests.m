#import "Testing.h"
#import "TestingExtension.h"
#import "Simulator.h"


void dirty_WhenHasBasicReaction_SetsSelfAsDirty(){
    ReactionEquation* re = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc] init] autorelease];
    [requirements addObject:@"A"];

    [re setRequirements:requirements];
    [re setResult:[[[NSCountedSet alloc] init] autorelease]];


    KineticConstant* kc = [[[KineticConstant alloc] initWithDouble:1] autorelease];

    ReactionDefinition* reaction = [[[ReactionDefinition alloc] initFromKineticConstant:kc reactionEquation:re] autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                                                                    @"A",
                                                                                    nil];
    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc]
                                                initWithTime:time moleculeCount:counts]
                                                autorelease];

    SimulatorInternalState* underTest = [[[SimulatorInternalState alloc]
                                                                  initWithSDM:NO ldm:NO dependencyGraph:YES]
                                                                  autorelease];
    [underTest addReaction:reaction];
    [underTest buildRequirementsGraph];

    [underTest updateRates:state];
    PASS([underTest isDirty:reaction] == NO, "Nothing should be dirty at this point");
    [underTest setDirty:reaction];
    PASS([underTest isDirty:reaction], "The reaction alters A and requires A, so it should be dirty");
}

void dirty_WhenHasTwoBasicReactions_SetsBothAsDirty(){
    ReactionEquation* reactionEqn1 = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements1 = [[[NSCountedSet alloc] init] autorelease];
    [requirements1 addObject:@"A"];

    NSCountedSet* result1 = [[[NSCountedSet alloc] init] autorelease];
    [result1 addObject:@"B"];

    [reactionEqn1 setRequirements:requirements1];
    [reactionEqn1 setResult:result1];

    KineticConstant* kc = [[[KineticConstant alloc] initWithDouble:1] autorelease];

    ReactionDefinition* reaction1 = [[[ReactionDefinition alloc]
                                                          initFromKineticConstant:kc reactionEquation:reactionEqn1]
                                                          autorelease];

    ReactionEquation* reactionEqn2 = [[[ReactionEquation alloc] init] autorelease];
    NSCountedSet* requirements2 = [[[NSCountedSet alloc] init] autorelease];
    [requirements2 addObject:@"B"];

    [reactionEqn2 setRequirements:requirements2];
    [reactionEqn2 setResult:[[[NSCountedSet alloc] init] autorelease]];

    ReactionDefinition* reaction2 = [[[ReactionDefinition alloc]
                                                          initFromKineticConstant:kc reactionEquation:reactionEqn2]
                                                          autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                                                                    @"A",
                                                                                    [NSNumber numberWithInt:6],
                                                                                    @"B",
                                                                                    nil];
    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc]
                                                initWithTime:time moleculeCount:counts]
                                                autorelease];

    SimulatorInternalState* underTest = [[[SimulatorInternalState alloc]
                                                                  initWithSDM:NO ldm:NO dependencyGraph:YES]
                                                                  autorelease];
    [underTest addReaction:reaction1];
    [underTest addReaction:reaction2];
    [underTest buildRequirementsGraph];

    [underTest updateRates:state];

    PASS([underTest isDirty:reaction1] == NO && [underTest isDirty:reaction2] == NO, "Nothing should be dirty at this point");

    [underTest setDirty:reaction1];
    PASS([underTest isDirty:reaction1], "The reaction alters A and B and requires A, so it should be dirty");
    PASS([underTest isDirty:reaction2], "The reaction alters A and B and reaction2 requires B, so it should be dirty");

    [underTest updateRates:state];
    PASS([underTest isDirty:reaction1] == NO && [underTest isDirty:reaction2] == NO, "Nothing should be dirty at this point");

    [underTest setDirty:reaction2];
    PASS([underTest isDirty:reaction1] == NO, "reaction2 alters B only, but reaction1 only requires A");
    PASS([underTest isDirty:reaction2], "reaction2 alters B only and reaction2 requires B, so it should be dirty");
}

int main() {
    START_SET("SimulatorTests")
        dirty_WhenHasBasicReaction_SetsSelfAsDirty();
        dirty_WhenHasTwoBasicReactions_SetsBothAsDirty();
    END_SET("SimulatorTests")

    return 0;
}
