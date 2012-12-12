#import "Simulator.h"
#import "ReactionDefinition.h"
#import "Logger.h"
#import <math.h>

@implementation SimulatorInternalState
- (id)init{
    return [self initWithSMO:YES dependencyGraph:YES];
}

- (id)initWithSMO:(BOOL)smo dependencyGraph:(BOOL)graph{
    self = [super init];
    if ( self ){
        mUseSortedDirectMethod = smo;
        mUseDependencyGraph = graph;
        mReactions      = [[NSMutableArray alloc] init];
        mReactionRates  = [[NSMutableArray alloc] init];
        mDirtyReactions = [[NSMutableSet alloc] init];
        mReactionRateDepencies = [[NSMutableDictionary alloc] init];
        mReactionToIdx = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc{
    [mReactions release];
    [mReactionRates release];
    [mDirtyReactions release];
    [mReactionToIdx release];
    [mReactionRateDepencies release];
    [super dealloc];
}

- (void)addReaction:(ReactionDefinition*)reaction{
    int newIdx = [mReactions count];
    [mReactions addObject:reaction];
    [mReactionRates addObject:[NSNumber numberWithInt:0]];
    [mDirtyReactions addObject:reaction];
    [mReactionToIdx setObject:[NSNumber numberWithInt:newIdx] forKey:[NSValue valueWithPointer:reaction]];
}

- (void)buildRequirementsGraph{
    //build a dictionary of all molecule to all reactions that have the molecule in thier
    //requirements
    NSMutableDictionary* moleculeToRequireReaction = [[NSMutableDictionary alloc] init];
    for ( ReactionDefinition* reaction in mReactions ){
        for ( NSString* moleculeRequirement in [reaction requirements] ){
            NSMutableSet* set = [moleculeToRequireReaction objectForKey:moleculeRequirement];
            if ( set == nil ){
                set = [[NSMutableSet alloc] init];
                [moleculeToRequireReaction setObject:set forKey:moleculeRequirement];
                [set release];
            }
            [set addObject:reaction];
        }
    }

    //Covert the above into a graph with edges for reaction depenecies
    for ( ReactionDefinition* reaction in mReactions ){
        NSMutableSet* set = [[NSMutableSet alloc] init];
        [mReactionRateDepencies setObject:set forKey:[NSValue valueWithPointer:reaction]];
        [set release];
        for ( NSString* molecule in [reaction alteredMolecules] ){
            [set unionSet:[moleculeToRequireReaction objectForKey:molecule]];
        }
    }
    [moleculeToRequireReaction release];
}

- (void)updateDirty:(SimulationState*)state{
    for ( ReactionDefinition* reaction in mDirtyReactions ){
        int rdIdx = [[mReactionToIdx objectForKey:[NSValue valueWithPointer:reaction]] intValue];
        double reactionRate = [reaction reactionRate:state];
        [mReactionRates replaceObjectAtIndex:rdIdx withObject:[NSNumber numberWithDouble:reactionRate]];
    }
    [mDirtyReactions removeAllObjects];
}

- (double)reactionRate:(SimulationState*)state{
    double reactionRateSum = 0;

    if ( mUseDependencyGraph ){
        [self updateDirty:state];

        for ( NSNumber* rateNumber in mReactionRates ){
            reactionRateSum += [rateNumber doubleValue];
        }
    }else{
        for ( ReactionDefinition* reaction in mReactions ){
            reactionRateSum += [reaction reactionRate:state];
        }
    }

    return reactionRateSum;
}

- (ReactionDefinition*)reactionForValue:(double)upperBound simulationState:(SimulationState*)state{
    assert( mUseDependencyGraph == false ||
           ([mDirtyReactions count] == 0 && "Must be empty otherwise calculations will be wrong"));

    double rateSum = 0;
    for (int reactionIdx = 0; reactionIdx < [mReactions count]; ++reactionIdx) {
        if ( mUseDependencyGraph ){
            rateSum += [[mReactionRates objectAtIndex:reactionIdx] doubleValue];
        }else{
            rateSum += [[mReactions objectAtIndex:reactionIdx] reactionRate:state];
        }
        if ( rateSum > upperBound ){
            ReactionDefinition* reactionToReturn = [mReactions objectAtIndex:reactionIdx];

            //slowly move reactions that happen alot to the start of the array to search
            //sorted direct method
            if ( mUseSortedDirectMethod && reactionIdx != 0 ){
                const int newCurrentReactionIdx = reactionIdx - 1;
                const ReactionEquation* const higherPriorityReaction = [mReactions objectAtIndex:newCurrentReactionIdx];

                [mReactions replaceObjectAtIndex:newCurrentReactionIdx withObject:reactionToReturn];
                [mReactionToIdx setObject:[NSNumber numberWithInt:newCurrentReactionIdx]
                                   forKey:[NSValue valueWithPointer:reactionToReturn]];

                [mReactions replaceObjectAtIndex:reactionIdx withObject:higherPriorityReaction];
                [mReactionToIdx setObject:[NSNumber numberWithInt:reactionIdx]
                                   forKey:[NSValue valueWithPointer:higherPriorityReaction]];
            }
            return reactionToReturn;
        }
    }
    return nil;
}

- (void)setDirty:(ReactionDefinition*)reaction{
    if ( mUseDependencyGraph ){
        NSValue* pointerToReaction = [NSValue valueWithPointer:reaction];
        [mDirtyReactions unionSet:[mReactionRateDepencies objectForKey:pointerToReaction]];
    }
}

- (BOOL)isDirty:(ReactionDefinition*)reaction{
    return [mDirtyReactions member:reaction] != nil;
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
    double reactionRateSum = [mInternalState reactionRate:state];

    //calculate the time that the next reaction will occur
    const double r1 = [mRandom next];
    const double tau = (1/reactionRateSum) * log(1/r1);
    TimeSpan* time = [state timeSinceSimulationStart];
    [time addSeconds:tau];

    //calculcate which reaction will happen next
    const double r2 = [mRandom next];
    ReactionDefinition* reaction = [mInternalState reactionForValue:r2*reactionRateSum simulationState:state];
    if ( reaction == nil){
        return NO;
    }

    NSMutableDictionary* counts = [state moleculeCounts];
    [reaction applyReactionToCounts:counts];

    [mInternalState setDirty:reaction];

    return YES;
}

@end
