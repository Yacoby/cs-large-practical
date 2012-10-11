#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "ReactionDefinition.h"
#import "TimeSpan.h"

/**
 * @brief Object holds a valid copy of the configuration 
 *
 * This class is designed so that it is fairly hard to load invalid data into it,
 * however it is possible to have a molecule count that isn't mentioned in a reaction
 * or a molecule mentioned in a reaction that doesn't have an initial count
 */
@interface SimulationConfiguration : NSObject{
    TimeSpan* mTime;
    NSMutableDictionary* mReactions;
    NSMutableDictionary* mMoleculeCounts;
}
- (id)init;
- (void)dealloc;

- (void)setTime:(TimeSpan*)time;
//TODO fix name
- (TimeSpan*)time;

- (void)addReaction:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant reactionComponents:(ReactionComponents*)components;
- (ReactionDefinition*)reaction:(NSString*)key;
- (NSDictionary*)reactions;


- (void)addMoleculeCount:(NSString*)key count:(uint)count;
- (uint)moleculeCount:(NSString*)key;
- (NSDictionary*)moleculeCounts;
- (NSSet*)molecules;

@end
