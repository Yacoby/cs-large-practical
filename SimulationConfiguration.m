#import "SimulationConfiguration.h"

@implementation SimulationConfiguration

- (id) init {
    self = [super init];
    if (self != nil) {
        mReactions = [[NSMutableDictionary init] alloc];
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
    [mReactions release];
}

- (int)time {
    return mTime;
}
- (void)setTime:(int)time{
    mTime = time;
}

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components{
    ReactionDefinition* def = [[[ReactionDefinition alloc] initFromKineticConstant:kineticConstant reactionComponents:components] autorelease];
    [mReactions setObject:def forKey:key];
}

- (ReactionDefinition*)reaction:(NSString*)key{
    return [mReactions objectForKey:key];
}

@end
