#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "ReactionDefinition.h"
#import "TimeSpan.h"

/**
 * Object holds a valid copy of the configuration and is designed in such a way
 * that it is fairly hard to add invalid data
 *
 * TODO there should be no way to load an invalid configuration
 */
@interface SimulationConfiguration : NSObject{
    TimeSpan* mTime;
    NSMutableDictionary* mReactions;
    NSMutableDictionary* mMoleculeCounts;
}
- (TimeSpan*) time;
- (void)setTime:(TimeSpan*)time;

- (ReactionDefinition*)reaction:(NSString*)key;

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components;

- (void)addMoleculeCount:(NSString*)key count:(uint)count;
- (uint)moleculeCount:(NSString*)key;

@end
