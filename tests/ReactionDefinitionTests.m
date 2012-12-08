
#import "Testing.h"
#import "TestingExtension.h"
#import "ReactionDefinition.h"

void reactionRate_WhenHasNonDuplicate_RateEqualsSimpleMult(){
    ReactionEquation* equation = [[[ReactionEquation alloc] init] autorelease];

    NSCountedSet* requirements = [[[NSCountedSet alloc] initWithObjects:@"A", nil] autorelease];
    NSCountedSet* result = [[[NSCountedSet alloc] init] autorelease];
    [equation setRequirements:requirements];
    [equation setResult:result];

    KineticConstant* constant = [[[KineticConstant alloc] initWithDouble:5] autorelease];

    ReactionDefinition* underTest = [[[ReactionDefinition alloc]
                                       initFromKineticConstant:constant reactionEquation:equation]
                                       autorelease];

    NSMutableDictionary* counts = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6], @"A", nil];

    TimeSpan* time = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    SimulationState* state = [[[SimulationState alloc] initWithTime:time moleculeCount:counts] autorelease];

    PASS_INT_EQUAL([underTest reactionRate:state], 5*6, "");
}

int main(){
    START_SET("ReactionDefinition")
        reactionRate_WhenHasNonDuplicate_RateEqualsSimpleMult();
    END_SET("ReactionDefinition")

    return 0;
}
