#import "SimulationConfiguration.h"

@implementation SimulationConfiguration

- (id) init {
    self = [super init];
    if (self != nil) {
        mReactions = [[NSMutableDictionary init] alloc];
        mMoleculeCounts = [[NSMutableDictionary init] alloc];
    }
    return self;
}

- (void) dealloc {
    for ( NSString* key in mReactions ){
        [key release];
    }
    [mReactions release];
    [mMoleculeCounts release];
    [super dealloc];
}

- (TimeSpan*)time {
    return mTime;
}
- (void)setTime:(TimeSpan*)time{
    mTime = time;
}

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components{
    if ( [mReactions objectForKey:key] ){
        //TODO this is bad. We leak if we do this
    }
    [key retain];
    ReactionDefinition* def = [[[ReactionDefinition alloc] initFromKineticConstant:kineticConstant reactionComponents:components] autorelease];
    [mReactions setObject:def forKey:key];
}

- (ReactionDefinition*)reaction:(NSString*)key{
    return [mReactions objectForKey:key];
}
- (void)addMoleculeCount:(NSString*)key count:(uint)count{
    NSNumber* number = [[[NSNumber alloc] initWithUnsignedInt: count] autorelease];
    [mMoleculeCounts setObject:number forKey:key];
}
- (uint)moleculeCount:(NSString*)key{
    NSNumber* number = [mMoleculeCounts objectForKey:key];
    return [number unsignedIntValue];
}

@end
