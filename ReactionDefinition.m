#import "ReactionDefinition.h"

@implementation ReactionComponents
- (void)dealloc{
    [mRequirements release];
    [mResult release];
    [super dealloc];
}

- (void)setRequirements:(NSCountedSet*)requirements{
    [requirements retain];
    [mRequirements release];
    mRequirements = requirements;
}

- (void)setResult:(NSCountedSet*)result{
    [result retain];
    [mResult release];
    mResult = result;
}

- (NSCountedSet*)requirements{
    return mRequirements;
}

- (NSCountedSet*)result{
    return mResult;
}
@end

@implementation ReactionDefinition
- (id)initFromKineticConstant:(KineticConstant*)k reactionComponents:(ReactionComponents*)components{
    self = [super init];
    if ( self != nil ){
        mKineticConstant = k;
        [mKineticConstant retain];

        mComponents = components;
        [mComponents retain];
    }
    return self;
}

- (void)dealloc{
    [mKineticConstant release];
    [mComponents release];
    [super dealloc];
}

- (KineticConstant*)kineticConstant{
    return mKineticConstant;
}

- (NSCountedSet*)requirements{
    return [mComponents requirements];
}

- (NSCountedSet*)result{
    return [mComponents result];
}

- (double)reactionRate:(SimulationState*)state{
    NSCountedSet* req = [self requirements];
    double rate = [mKineticConstant doubleValue];
    if ( [req count] == 1 ){
        NSString* moleculeName = [req anyObject];

        if ( [req countForObject:moleculeName] == 2 ){
            uint count = [state moleculeCount:moleculeName];
            return rate*0.5*( count * (count - 1));
        }
    }


    for ( NSString* moleculeName in req ){
        rate *= [state moleculeCount:moleculeName];
    }
    return rate;

}

- (void)applyReactionToCounts:(NSMutableDictionary*)state{
    for ( NSString* moleculeName in [self requirements] ){
        NSNumber* count = [state objectForKey:moleculeName];
        NSNumber* newCount = [NSNumber numberWithInt:[count intValue]-1];
        [state setObject:newCount forKey:moleculeName];
    }

    for ( NSString* moleculeName in [self result] ){
        NSNumber* count = [state objectForKey:moleculeName];
        NSNumber* newCount = [NSNumber numberWithInt:[count intValue]+1];
        [state setObject:newCount forKey:moleculeName];
    }
}

@end
