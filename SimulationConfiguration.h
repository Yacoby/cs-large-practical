#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "ReactionDefinition.h"

/**
 * Object holds a valid copy of the configuration.
 *
 * TODO there should be no way to load an invalid configuration
 */
@interface SimulationConfiguration : NSObject{
    int mTime;
    NSMutableDictionary* mReactions;
    NSMutableDictionary* mMoleculeCounts;
}
- (int) time;
- (void)setTime:(int)time;

- (ReactionDefinition*)reaction:(NSString*)key;

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components;

- (void)addMoleculeCount:(NSString*)key count:(uint)count;
- (uint)moleculeCount:(NSString*)key;

@end
