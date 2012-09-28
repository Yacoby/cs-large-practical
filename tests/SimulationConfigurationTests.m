#import "Testing.h"
#import "SimulationConfiguration.h"

void addReaction_WhenAddsReaction_HasReactionForKey(){
    SimulationConfiguration* underTest = [[[SimulationConfiguration alloc] init] autorelease];
    ReactionComponents* components = [[[ReactionComponents alloc] init] autorelease];
    KineticConstant* kConst = [[[KineticConstant alloc] initWithDouble:0] autorelease];

    [underTest addReaction:@"key" kineticConstant:kConst reactionComponents:components];

    ReactionDefinition* reaction = [underTest reaction:@"key"];

    PASS_EQUAL([reaction kineticConstant], kConst, "");

}

int main()
{
    START_SET("SimulationConfiguration")
        addReaction_WhenAddsReaction_HasReactionForKey();
    END_SET("SimulationConfiguration")

    return 0;
}

