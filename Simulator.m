#import "Simulator.h"
#import "ReactionDefinition.h"
#import "Logger.h"
#import <math.h>

const int NO_REACTION = -1;

@implementation Simulator
- (id)initWithCfg:(SimulationConfiguration*)cfg
        randomGen:(id<Random>)random
 outputAggregator:(id<SimulationOutputAggregator>)aggregator{
    self = [super init];
    if ( self != nil ){
        [cfg retain];
        mCfg = cfg;

        [aggregator retain];
        mAggregator = aggregator;

        [random retain];
        mRandom = random;

        mReactions = [[NSMutableArray alloc] init];

        NSDictionary* reactions = [cfg reactions];
        for ( NSString* reactionName in reactions ){
            [mReactions addObject:[reactions objectForKey:reactionName]];
        }

    }
    return self;
}

- (void)dealloc{
    [mAggregator release];
    [mCfg release];
    [mRandom release];
    [mReactions release];
    [super dealloc];
}

- (void)runSimulation{
    [Logger info:@"Starting simulation"];
    TimeSpan* startTime = [[TimeSpan alloc] initFromSeconds:0];
    NSMutableDictionary* initialCounts = [[[mCfg moleculeCounts] mutableCopy] autorelease];
    SimulationState* initialState = [[SimulationState alloc] initWithTime:startTime moleculeCount:initialCounts];

    TimeSpan* stopTime = [mCfg time];

    SimulationState* state = initialState;
    [mAggregator stateChangedTo:state];

    while ( true ){
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        BOOL hasHadReaction = [self runSimulationStep:state];
        if ( !hasHadReaction ||
            [[state timeSinceSimulationStart] totalSeconds] >= [stopTime totalSeconds] ){
            [Logger info:@"Simulation stopped at time <%f>", [stopTime totalSeconds]];
            [pool drain];
            break;
        }

        [mAggregator stateChangedTo:state];
        [pool drain];
    }
    [mAggregator simulationEnded];

    [startTime release];
    [initialState release];
}

- (BOOL)runSimulationStep:(SimulationState*)state{
    double reactionRateSum = 0;
    for ( ReactionDefinition* reaction in mReactions ){
        reactionRateSum += [reaction reactionRate:state];
    }



    //calculate the time that the next reaction will occur
    const double r1 = [mRandom next];
    const double tau = (1/reactionRateSum) * log(1/r1);
    TimeSpan* time = [state timeSinceSimulationStart];
    [time addSeconds:tau];

    //calculcate which reaction will happen next
    const double r2 = [mRandom next];
    int reactionToDoIdx = NO_REACTION;
    double rateSum = 0;
    for (int reactionIdx = 0; reactionIdx < [mReactions count]; ++reactionIdx) {
        rateSum += [[mReactions objectAtIndex:reactionIdx] reactionRate:state];
        if ( rateSum > r2 * reactionRateSum ){
            [Logger debug:@"Reaction at index <%d> occured", reactionIdx];
            reactionToDoIdx = reactionIdx;
            break;
        }
    }
    if ( reactionToDoIdx == NO_REACTION ){
        return NO;
    }

    NSMutableDictionary* counts = [state moleculeCounts];
    [[mReactions objectAtIndex:reactionToDoIdx] applyReactionToCounts:counts];

    //slowly move reactions that happen alot to the start of the array to search
    //sorted direct method
    if ( reactionToDoIdx != 0 ){
        const int newCurrentReactionIdx = reactionToDoIdx - 1;
        const ReactionEquation* const higherPriorityReaction = [mReactions objectAtIndex:newCurrentReactionIdx];
        const ReactionEquation* const currentReaction        = [mReactions objectAtIndex:reactionToDoIdx];
        [mReactions replaceObjectAtIndex:newCurrentReactionIdx withObject:currentReaction];
        [mReactions replaceObjectAtIndex:reactionToDoIdx withObject:higherPriorityReaction];
    }

    return YES;
}

@end
