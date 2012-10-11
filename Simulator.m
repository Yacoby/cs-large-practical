#import "Simulator.h"
#import "ReactionDefinition.h"
#import <math.h>

@implementation Simulator
- (id)initWithCfg:(SimulationConfiguration*)cfg{
    self = [super init];
    if ( self != nil ){
        [cfg retain];
        mCfg = cfg;

        mReactions = [[NSMutableArray alloc] init];

        NSDictionary* reactions = [cfg reactions];
        for ( NSString* reactionName in reactions ){ //TODO
            [mReactions addObject:[reactions objectForKey:reactionName]];
        }

    }
    return self;
}

- (void)dealloc{
    [mCfg release];
    [mReactions release];
    [super dealloc];
}

- (NSArray*)runSimulation{
    TimeSpan* startTime = [[TimeSpan alloc] initFromSeconds:0];
    NSDictionary* initialCounts = [mCfg moleculeCounts];
    SimulationState* initialState = [[SimulationState alloc] initWithTime:startTime moleculeCount:initialCounts];

    TimeSpan* stopTime = [mCfg time];

    NSMutableArray* result = [[[NSMutableArray alloc] init] autorelease];
    [result addObject:initialState];
    SimulationState* state = initialState;

    while ( true ){
        state = [self runSimulationStep:state];
        if ( state == nil ||
            [[state timeSinceSimulationStart] totalSeconds] >= [stopTime totalSeconds] ){
            break;
        }

        [result addObject:state];
    }

    [startTime release];
    [initialState release];

    return result;
}

- (SimulationState*)runSimulationStep:(SimulationState*)state{
    double a0 = 0;
    for ( ReactionDefinition* reaction in mReactions ){
        a0 += [reaction reactionRate:state];
    }
    double r1 = ((double)rand())/RAND_MAX;
    double tau = (1/a0) * log(1/r1);
    TimeSpan* oldTime = [state timeSinceSimulationStart];
    TimeSpan* newTime = [[[TimeSpan alloc] initFromSeconds:[oldTime totalSeconds]]autorelease];
    [newTime addSeconds:tau];

    double r2 = ((double)rand())/RAND_MAX;

    int reaction = -1;
    double rateSum = 0;
    for (int i = 0; i < [mReactions count]; ++i) {
        rateSum += [[mReactions objectAtIndex:i] reactionRate:state];
        if ( rateSum > r2 * a0 ){
            reaction = i;
            break;
        }
    }
    if ( reaction == -1 ){
        return nil;
    }

    NSDictionary* oldCounts = [state moleculeCounts];
    NSDictionary* newCounts = [[mReactions objectAtIndex:reaction] applyReactionToCounts:oldCounts];

    return [[[SimulationState alloc] initWithTime:newTime moleculeCount:newCounts] autorelease];
}

@end
