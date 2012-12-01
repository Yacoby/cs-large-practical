#import "SimulationConfiguration.h"
#import "ErrorConstants.h"

int UNKNOWN_MOLECULE = -1;

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
    ConfigurationValidation* result = [[ConfigurationValidation alloc] init];
    if ( [self time] == nil ){
        [result addError:@"The time (t) was not set"];
    }

    for ( NSString* key in mKineticConstants ){
        if ( [mReactionEquations objectForKey:key] == nil ){
            NSString* description = [NSString stringWithFormat:@"The kinetic constant <%@> has no reaction equation", key];
            [result addWarning:description];
        }
    }

    NSMutableSet* usedMolecules = [[NSMutableSet alloc] init];
    for ( NSString* reactionName in mReactionEquations ){
        if ( [mKineticConstants objectForKey:reactionName] == nil ){
            NSString* description = [NSString stringWithFormat:@"Reaction <%@> has no kinetic constant", reactionName];
            [result addError:description];
        }

        ReactionEquation* eqn = [mReactionEquations objectForKey:reactionName];
        NSMutableSet* equationMolecules = [[eqn requirements] mutableCopy];
        [equationMolecules unionSet:[eqn result]];
        for ( NSString* molecule in equationMolecules ){
            [usedMolecules addObject:molecule];
            if ( [mMoleculeCounts objectForKey:molecule] == nil ){
                NSString* description = [NSString stringWithFormat:@"Molecule <%@> in reaction equation <%@> has no count",
                                                                   molecule,
                                                                   reactionName];
                [result addError:description];
            }
        }
        [equationMolecules release];
    }

    //NB: the < case was handled by checking the reaction equations
    if ( [mMoleculeCounts count] > [usedMolecules count] ){
        for ( NSString* molecule in mMoleculeCounts ){
            if ( [usedMolecules member:molecule] == nil ){
                NSString* description = [NSString stringWithFormat:@"Molecule <%@> was not used", molecule];
                [result addWarning:description];
            }
        }
    }

    return result;
}

@end
