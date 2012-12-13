#import "Simulator.h"
#import "ReactionDefinition.h"
#import "Logger.h"
#import <math.h>

const int NO_REACTION = -1;

@implementation ReactionWithRate

- (id)initWithReaction:(ReactionDefinition*)reaction rate:(double)rate{
    self = [super init];
    if ( self ){
        [reaction retain];
        mReaction = reaction;

        mRate = rate;
    }
    return self;
}
- (void)dealloc{
    [super dealloc];
    [mReaction release];
}

- (ReactionDefinition*)reaction{
    return mReaction;
}
- (double)rate{
    return mRate;
}
- (void)setRate:(double)rate{
    mRate = rate;
}

- (double)partialSum{
    return mPartialRate;
}
- (void)setPartialSum:(double)rate{
    mPartialRate = rate;
}
@end

@implementation SimulatorInternalState
- (id)init{
    return [self initWithSDM:NO ldm:NO dependencyGraph:NO];
}

- (id)initWithSDM:(BOOL)sdm ldm:(BOOL)ldm dependencyGraph:(BOOL)graph{
    self = [super init];
    if ( self ){
        mUseSortedDirectMethod     = sdm;
        mUseLogrithmicDirectMethod = ldm;
        mUseDependencyGraph        = graph;

        [Logger info:@"Using standard internal state"];
        [Logger info:@"SDM:<%c> LDM:<%c> Graph:<%c>", sdm, ldm, graph];

        mReactions      = [[NSMutableArray alloc] init];
        mDirtyReactions = [[NSMutableSet alloc] init];
        mReactionRateDepencies = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc{
    [mReactions release];
    [mDirtyReactions release];
    [mReactionRateDepencies release];
    [super dealloc];
}

- (void)addReaction:(ReactionDefinition*)reaction{
    ReactionWithRate* reactionAndRate = [[ReactionWithRate alloc] initWithReaction:reaction
                                                                  rate:0];
    [mReactions addObject:reactionAndRate];
    [mDirtyReactions addObject:reactionAndRate];
}

- (void)buildRequirementsGraph{
    //build a dictionary of all molecule to all reactions that have the molecule in thier
    //requirements
    NSMutableDictionary* moleculeToRequireReaction = [[NSMutableDictionary alloc] init];
    for ( ReactionWithRate* reactionAndRate in mReactions ){
        ReactionDefinition* reaction = [reactionAndRate reaction];
        for ( NSString* moleculeRequirement in [reaction requirements] ){
            NSMutableSet* set = [moleculeToRequireReaction objectForKey:moleculeRequirement];
            if ( set == nil ){
                set = [[NSMutableSet alloc] init];
                [moleculeToRequireReaction setObject:set forKey:moleculeRequirement];
                [set release];
            }
            [set addObject:reactionAndRate];
        }
    }

    //Covert the above into a graph with edges for reaction depenecies
    for ( ReactionWithRate* reactionAndRate in mReactions ){
        ReactionDefinition* reaction = [reactionAndRate reaction];

        NSMutableSet* set = [[NSMutableSet alloc] init];
        [mReactionRateDepencies setObject:set forKey:[NSValue valueWithPointer:reaction]];
        [set release];

        for ( NSString* molecule in [reaction alteredMolecules] ){
            [set unionSet:[moleculeToRequireReaction objectForKey:molecule]];
        }
    }
    [moleculeToRequireReaction release];
}

- (void)updateRates:(SimulationState*)state{
    if ( mUseDependencyGraph ){
        for ( ReactionWithRate* reactionWithRate in mDirtyReactions ){
            double reactionRate = [[reactionWithRate reaction] reactionRate:state];
            [reactionWithRate setRate:reactionRate];
        }
        [mDirtyReactions removeAllObjects];
    }else{
        for ( ReactionWithRate* reactionWithRate in mReactions ){
            double reactionRate = [[reactionWithRate reaction] reactionRate:state];
            [reactionWithRate setRate:reactionRate];
        }
    }

    if ( mUseLogrithmicDirectMethod ){
        double sum = 0;
        for (int reactionIdx = 0; reactionIdx < [mReactions count]; ++reactionIdx) {
            ReactionWithRate* const reactionAndRate = [mReactions objectAtIndex:reactionIdx];
            sum += [reactionAndRate rate];
            [reactionAndRate setPartialSum:sum];
        }
    }
}

- (double)reactionRateSumForState:(SimulationState*)state{
    [self updateRates:state];

    if ( mUseLogrithmicDirectMethod ){
        return [[mReactions lastObject] partialSum];
    }else{
        double reactionRateSum = 0;
        for ( ReactionWithRate* reactionAndRate in mReactions ){
            reactionRateSum += [reactionAndRate rate];
        }
        return reactionRateSum;
    }
}

- (int)findReactionIndex:(double)lowerBound{
    if ( mUseLogrithmicDirectMethod ){
        return [self findReactionIndexWithBinarySearch:lowerBound];
    }
    return [self findReactionIndexWithLinearSearch:lowerBound];
}

- (int)findReactionIndexWithLinearSearch:(double)lowerBound{
    double rateSum = 0;
    for (int reactionIdx = 0; reactionIdx < [mReactions count]; ++reactionIdx) {
        rateSum += [[mReactions objectAtIndex:reactionIdx] rate];
        if ( rateSum > lowerBound ){
            return reactionIdx;
        }
    }
    return NO_REACTION;
}

- (int)findReactionIndexWithBinarySearch:(double)lowerBound{
    assert(mUseLogrithmicDirectMethod && "Otherwise the partial sums won't be set");
    int min = 0;
    int max = [mReactions count] - 1;
    while ( min <= max ){
        int mid = (min + max)/2;
        if ( [[mReactions objectAtIndex:mid] partialSum] >= lowerBound ){
            max = mid - 1;
        }else{
            min = mid + 1;
        }
    }

    assert("Basic post condition" && [[mReactions objectAtIndex:min] partialSum] > lowerBound);
    assert("Basic post condition" && (min < 2 || [[mReactions objectAtIndex:min-1] partialSum] <= lowerBound));
    return min;
}

- (ReactionDefinition*)reactionForBound:(double)lowerBound{
    assert( mUseDependencyGraph == false ||
           ([mDirtyReactions count] == 0 && "Must be empty otherwise calculations will be wrong"));

    int reactionIdx = [self findReactionIndex:lowerBound];
    if ( reactionIdx != NO_REACTION ){
        ReactionWithRate* reactionToReturn = [mReactions objectAtIndex:reactionIdx];

        //slowly move reactions that happen alot to the start of the array to search
        //sorted direct method
        if ( mUseSortedDirectMethod && reactionIdx > 0 ){
            const int newCurrentReactionIdx = reactionIdx - 1;
            ReactionWithRate* const higherPriorityReaction = [mReactions objectAtIndex:newCurrentReactionIdx];

            [mReactions replaceObjectAtIndex:newCurrentReactionIdx withObject:reactionToReturn];
            [mReactions replaceObjectAtIndex:reactionIdx withObject:higherPriorityReaction];
        }
        return [reactionToReturn reaction];
    }
    return nil;
}

- (void)setDirty:(ReactionDefinition*)reaction{
    if ( mUseDependencyGraph ){
        NSValue* const pointerToReaction = [NSValue valueWithPointer:reaction];
        [mDirtyReactions unionSet:[mReactionRateDepencies objectForKey:pointerToReaction]];
    }
}

- (BOOL)isDirty:(ReactionDefinition*)reaction{
    for ( ReactionWithRate* reactionAndRate in mDirtyReactions ){
        if ( [reactionAndRate reaction] == reaction ){
            return YES;
        }
    }
    return NO;
}
@end

@implementation Simulator
- (id)initWithInternals:(SimulatorInternalState*)internals
                    cfg:(SimulationConfiguration*)cfg
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

        [internals retain];
        mInternalState = internals;

        NSDictionary* reactions = [cfg reactions];
        for ( NSString* reactionName in reactions ){
            ReactionDefinition* reaction = [reactions objectForKey:reactionName];
            [mInternalState addReaction:reaction];
        }
        [mInternalState buildRequirementsGraph];
    }
    return self;
}

- (void)dealloc{
    [mInternalState release];
    [mAggregator release];
    [mCfg release];
    [mRandom release];
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
        BOOL shouldContinue = [self runSimulationStep:state stopTime:stopTime];
        if ( !shouldContinue ){
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

- (BOOL)runSimulationStep:(SimulationState*)state stopTime:(TimeSpan*)stopTime{
    double reactionRateSum = [mInternalState reactionRateSumForState:state];

    //calculate the time that the next reaction will occur
    const double r1 = [mRandom next];
    const double tau = (1/reactionRateSum) * log(1/r1);
    TimeSpan* time = [state timeSinceSimulationStart];

    if ( [time totalSeconds] + tau > [stopTime totalSeconds] ){
        [Logger info:@"Simulation greater time is greater than stop time"];
        return NO;
    }

    [time addSeconds:tau];

    //calculcate which reaction will happen next
    const double r2 = [mRandom next];
    ReactionDefinition* reaction = [mInternalState reactionForBound:r2*reactionRateSum];
    if ( reaction == nil){
        [Logger info:@"No reaction for simulation to do"];
        return NO;
    }

    NSMutableDictionary* counts = [state moleculeCounts];
    [reaction applyReactionToCounts:counts];

    [mInternalState setDirty:reaction];

    return YES;
}

@end
