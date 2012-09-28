#import "SimulationConfiguration.h"

@implementation SimulationConfiguration
- (id)init {
    self = [super init];
    if (self != nil) {
        mReactions = [[NSMutableDictionary init] alloc];
        mMoleculeCounts = [[NSMutableDictionary init] alloc];
    }
    return self;
}

- (void)dealloc {
    [mReactions release];
    [mMoleculeCounts release];
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

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components{
    ReactionDefinition* def = [[ReactionDefinition alloc] initFromKineticConstant:kineticConstant reactionComponents:components];
    [mReactions setObject:def forKey:key];
    [def release];
}

- (ReactionDefinition*)reaction:(NSString*)key{
    return [mReactions objectForKey:key];
}
- (void)addMoleculeCount:(NSString*)key count:(uint)count{
    NSNumber* number = [[NSNumber alloc] initWithUnsignedInt: count];
    [mMoleculeCounts setObject:number forKey:key];
    [number release];
}
- (uint)moleculeCount:(NSString*)key{
    NSNumber* number = [mMoleculeCounts objectForKey:key];
    return [number unsignedIntValue];
}
- (NSSet*)molecules{
    return [[[NSSet alloc] initWithArray:[mMoleculeCounts allKeys]] autorelease];
}

@end
