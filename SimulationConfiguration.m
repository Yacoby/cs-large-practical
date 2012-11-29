#import "SimulationConfiguration.h"
#import "ErrorConstants.h"

@implementation SimulationConfiguration
- (id)init {
    self = [super init];
    if (self != nil) {
        mReactionEquations = [[NSMutableDictionary init] alloc];
        mMoleculeCounts    = [[NSMutableDictionary init] alloc];
        mKineticConstants  = [[NSMutableDictionary init] alloc];

        mTime = nil;
    }
    return self;
}

- (void)dealloc {
    [mReactionEquations release];
    [mMoleculeCounts release];
    [mKineticConstants release];

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
    NSNumber* number = [[NSNumber alloc] initWithUnsignedInt: count];
    [mMoleculeCounts setObject:number forKey:key];
    [number release];
    return YES;
}

- (uint)moleculeCount:(NSString*)key{
    NSNumber* number = [mMoleculeCounts objectForKey:key];
    return [number unsignedIntValue];
}

- (NSDictionary*)moleculeCounts{
    return mMoleculeCounts;
}

- (NSSet*)molecules{
    return [[[NSSet alloc] initWithArray:[mMoleculeCounts allKeys]] autorelease];
}

- (NSError*)validate{
    if ( [self time] == nil ){
        return [self makeErrorWithDescription:@"The time (t) was not set"];
    }

    for ( NSString* key in mKineticConstants ){
        if ( [mReactionEquations objectForKey:key] == nil ){
            NSString* description = [NSString stringWithFormat:@"The kinetic constant <%@> has no reaction equation", key];
            return [self makeErrorWithDescription:description];
        }
    }

    NSMutableSet* usedMolecules = [[NSMutableSet alloc] init];
    for ( NSString* reactionName in mReactionEquations ){
        if ( [mKineticConstants objectForKey:reactionName] == nil ){
            NSString* description = [NSString stringWithFormat:@"Reaction <%@> has no kinetic constant", reactionName];
            return [self makeErrorWithDescription:description];
        }

        ReactionEquation* eqn = [mReactionEquations objectForKey:reactionName];
        for ( NSString* molecule in [eqn requirements] ){
            [usedMolecules addObject:molecule];
            if ( [mMoleculeCounts objectForKey:molecule] == nil ){
                NSString* description = [NSString stringWithFormat:@"Molecule <%@> in reaction equation <%@> has no count",
                                                                   molecule,
                                                                   reactionName];
                return [self makeErrorWithDescription:description];
            }
        }
        for ( NSString* molecule in [eqn result] ){
            [usedMolecules addObject:molecule];
            if ( [mMoleculeCounts objectForKey:molecule] == nil ){
                NSString* description = [NSString stringWithFormat:@"Molecule <%@> in reaction equation <%@> has no count",
                                                                   molecule,
                                                                   reactionName];
                return [self makeErrorWithDescription:description];
            }
        }
    }

    //NB: the < case was handled by checking the reaction equations
    if ( [mMoleculeCounts count] > [usedMolecules count] ){
        for ( NSString* molecule in mMoleculeCounts ){
            if ( [usedMolecules member:molecule] == nil ){
                NSString* description = [NSString stringWithFormat:@"Molecule <%@> was not used", molecule];
                return [self makeErrorWithDescription:description];
            }
        }
    }

    return nil;
}

- (NSError*)makeErrorWithDescription:(NSString*)description{
    NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                    initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                    autorelease];
    return [NSError errorWithDomain:ERROR_DOMAIN code:CFG_VALIDATE_ERROR userInfo:errorDictionary];
}

@end
