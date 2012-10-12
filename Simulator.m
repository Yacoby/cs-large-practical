#import "Simulator.h"
#import "ReactionDefinition.h"
#import <math.h>

@implementation Simulator
- (id)initWithCfg:(SimulationConfiguration*)cfg randomGen:(id <Random>)random outputWriter:(id <OutputWriter>)writer{
    self = [super init];
    if ( self != nil ){
        [cfg retain];
        mCfg = cfg;

        [writer retain];
        mWriter = writer;

        [random retain];
        mRandom = random;

        mReactions = [[NSMutableArray alloc] init];

        NSDictionary* reactions = [cfg reactions];
        for ( NSString* reactionName in reactions ){ //TODO
            [mReactions addObject:[reactions objectForKey:reactionName]];
        }

    }
    return self;
}

- (void)dealloc{
    [mWriter release];
    [mCfg release];
    [mRandom release];
    [mReactions release];
    [super dealloc];
}

- (void)runSimulation{
    TimeSpan* startTime = [[TimeSpan alloc] initFromSeconds:0];
    NSMutableDictionary* initialCounts = [[[mCfg moleculeCounts] mutableCopy] autorelease];
    SimulationState* initialState = [[SimulationState alloc] initWithTime:startTime moleculeCount:initialCounts];

    TimeSpan* stopTime = [mCfg time];

    SimulationState* state = initialState;
    [mWriter writeToStream:state];

    while ( true ){
        BOOL hasHadReaction = [self runSimulationStep:state];
        if ( !hasHadReaction ||
            [[state timeSinceSimulationStart] totalSeconds] >= [stopTime totalSeconds] ){
            break;
        }

        [mWriter writeToStream:state];
    }

    [startTime release];
    [initialState release];
}

- (BOOL)runSimulationStep:(SimulationState*)state{
    double a0 = 0;
    for ( ReactionDefinition* reaction in mReactions ){
        a0 += [reaction reactionRate:state];
    }
    double r1 = [mRandom next];
    double tau = (1/a0) * log(1/r1);
    TimeSpan* time = [state timeSinceSimulationStart];
    [time addSeconds:tau];

    double r2 = [mRandom next];

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
        return NO;
    }

    NSMutableDictionary* counts = [state moleculeCounts];
    [[mReactions objectAtIndex:reaction] applyReactionToCounts:counts];

    return YES;
}

@end
