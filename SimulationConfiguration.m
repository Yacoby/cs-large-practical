#import "SimulationConfiguration.h"
#import "ErrorConstants.h"

int UNKNOWN_MOLECULE = -1;

@implementation ReactionMoleculePair
- (id)initWithReactionName:(NSString*)reaction moleculeName:(NSString*)molecule{
    self = [super init];
    if ( self ){
        [reaction retain];
        mReaction = reaction;

        [molecule retain];
        mMolecule = molecule;
    }
    return self;
}

- (void)dealloc{
    [mReaction release];
    [mMolecule release];
    [super dealloc];
}

- (NSString*)reactionName{
    return mReaction;
}

- (NSString*)moleculeName{
    return mMolecule;
}

@end

@implementation ConfigurationValidation
- (id)init{
    self = [super init];
    if ( self ){
        mErrorMessages = [[NSMutableSet alloc] init];
        mWarningMessages = [[NSMutableSet alloc] init];
    }
    return self;
}
- (void)dealloc{
    [mErrorMessages release];
    [mWarningMessages release];
    [super dealloc];
}
- (NSSet*)errors{
    return mErrorMessages;
}
- (NSSet*)warnings{
    return mWarningMessages;
}

- (void)addError:(NSString*)errorMsg{
    [mErrorMessages addObject:errorMsg];
}

- (void)addWarning:(NSString*)warningMsg{
    [mWarningMessages addObject:warningMsg];
}
@end

@implementation SimulationConfiguration
- (id)init {
    self = [super init];
    if (self != nil) {
        mReactionEquations = [[NSMutableDictionary alloc] init];
        mMoleculeCounts    = [[NSMutableDictionary alloc] init];
        mKineticConstants  = [[NSMutableDictionary alloc] init];

        mMoleculeOrder = [[NSMutableArray alloc] init];

        mTime = nil;
    }
    return self;
}

- (void)dealloc {
    [mReactionEquations release];
    [mMoleculeCounts release];
    [mKineticConstants release];
    [mMoleculeOrder release];

    [mTime release];

    [super dealloc];
}

- (TimeSpan*)time {
    return mTime;
}
- (void)setTime:(TimeSpan*)time{
    [time retain];
    [mTime release];
    mTime = time;
}

- (BOOL)addReactionEquation:(NSString*)key reactionEquation:(ReactionEquation*)eqn{
    if ( [mReactionEquations objectForKey:key] != nil ){
        return NO;
    }
    [mReactionEquations setObject:eqn forKey:key];
    return YES;
}

- (ReactionDefinition*)reaction:(NSString*)key{
    KineticConstant* k    = [mKineticConstants objectForKey:key];
    ReactionEquation* eqn = [mReactionEquations objectForKey:key];
    if ( k == nil || eqn == nil ){
        return nil;
    }
    return [[[ReactionDefinition alloc] initFromKineticConstant:k reactionEquation:eqn] autorelease];
}

- (NSDictionary*)reactions{
    NSMutableDictionary* result = [[[NSMutableDictionary alloc] init] autorelease];
    for ( NSString* key in mReactionEquations ){
        ReactionDefinition* def = [self reaction:key];
        if ( def != nil ){
            [result setObject:def forKey: key];
        }
    }
    return result;
}

- (BOOL)addKineticConstant:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant{
    if ( [mKineticConstants objectForKey:key] != nil ){
        return NO;
    }
    [mKineticConstants setObject:kineticConstant forKey:key];
    return YES;
}

- (BOOL)addMoleculeCount:(NSString*)key count:(uint)count{
    if ( [mMoleculeCounts objectForKey:key] != nil ){
        return NO;
    }
    [mMoleculeOrder addObject:key];

    NSNumber* number = [[NSNumber alloc] initWithUnsignedInt: count];
    [mMoleculeCounts setObject:number forKey:key];
    [number release];
    return YES;
}

- (int)moleculeCount:(NSString*)key{
    NSNumber* number = [mMoleculeCounts objectForKey:key];
    if ( number == nil ){
        return UNKNOWN_MOLECULE;
    }
    return [number unsignedIntValue];
}

- (NSDictionary*)moleculeCounts{
    return mMoleculeCounts;
}

- (NSArray*)orderedMolecules{
    return mMoleculeOrder;
}

- (NSSet*)molecules{
    return [[[NSSet alloc] initWithArray:[mMoleculeCounts allKeys]] autorelease];
}

- (ConfigurationValidation*)validate{
    ConfigurationValidation* result = [[[ConfigurationValidation alloc] init] autorelease];
    if ( [self time] == nil ){
        [result addError:@"The time (t) was not set"];
    }

    for ( NSString* kineticConstant in [self kineticConstantsWithoutReactionEquations] ){
        NSString* description = [NSString stringWithFormat:@"The kinetic constant <%@> has no reaction equation",
                                                            kineticConstant];
        [result addWarning:description];
    }

    for ( NSString* reactionName in [self reactionEquationsWithoutKineticConstants] ){
        NSString* description = [NSString stringWithFormat:@"Reaction <%@> has no kinetic constant",
                                                           reactionName];
        [result addError:description];
    }

    for ( ReactionMoleculePair* reactionAndMolecule in [self moleculesInReactionsWithNoCount]){
        NSString* description = [NSString stringWithFormat:@"Molecule <%@> in reaction equation <%@> has no count",
                                                           [reactionAndMolecule moleculeName],
                                                           [reactionAndMolecule reactionName]];
        [result addError:description];
    }

    for ( NSString* unusedMoleculeName in [self moleculesNotUsedInReactions] ){
        NSString* description = [NSString stringWithFormat:@"Molecule <%@> was not used in a reaction but has a count",
                                                            unusedMoleculeName];
        [result addWarning:description];
    }

    return result;
}

- (NSSet*)kineticConstantsWithoutReactionEquations{
    NSMutableSet* result = [[[NSMutableSet alloc] init] autorelease];
    for ( NSString* key in mKineticConstants ){
        if ( [mReactionEquations objectForKey:key] == nil ){
            [result addObject:key];
        }
    }
    return result;
}
- (NSSet*)reactionEquationsWithoutKineticConstants{
    NSMutableSet* result = [[[NSMutableSet alloc] init] autorelease];
    for ( NSString* reactionName in mReactionEquations ){
        if ( [mKineticConstants objectForKey:reactionName] == nil ){
           [result addObject:reactionName];
        }
    }
    return result;
}

- (NSSet*)moleculesInReactionsWithNoCount{
    NSMutableSet* result = [[[NSMutableSet alloc] init] autorelease];
    for ( NSString* reactionName in mReactionEquations ){
        ReactionEquation* reactionEquation = [mReactionEquations objectForKey:reactionName];

        NSMutableSet* allEquationMolecules = [[reactionEquation requirements] mutableCopy];
        [allEquationMolecules unionSet:[reactionEquation result]];
        for ( NSString* molecule in allEquationMolecules ){
            if ( [mMoleculeCounts objectForKey:molecule] == nil ){
                ReactionMoleculePair* pair = [[ReactionMoleculePair alloc]
                                                                   initWithReactionName:reactionName
                                                                           moleculeName:molecule];
                [result addObject:pair];
                [pair release];
            }
        }
        [allEquationMolecules release];
    }
    return result;
}

- (NSSet*)moleculesNotUsedInReactions{
    return [[[NSSet alloc] init] autorelease];
    NSMutableSet* moleculesUsedInReaction = [[NSMutableSet alloc] init];
    for ( NSString* reactionName in mReactionEquations ){
        ReactionEquation* reactionEquation = [mReactionEquations objectForKey:reactionName];
        [moleculesUsedInReaction unionSet:[reactionEquation result]];
        [moleculesUsedInReaction unionSet:[reactionEquation requirements]];
    }

    NSMutableSet* moleculesWithOnlyCounts = [[mMoleculeCounts mutableCopy] autorelease];
    [moleculesWithOnlyCounts minusSet:moleculesUsedInReaction];

    [moleculesUsedInReaction release];

    return moleculesWithOnlyCounts;
}

@end
