#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "ReactionDefinition.h"
#import "TimeSpan.h"

/**
 * @brief Object holds a valid copy of the configuration 
 */
@interface SimulationConfiguration : NSObject{
    TimeSpan* mTime;
    NSMutableDictionary* mReactionEquations;
    NSMutableDictionary* mMoleculeCounts;
    NSMutableDictionary* mKineticConstants;
}
- (id)init;
- (void)dealloc;

- (void)setTime:(TimeSpan*)time;
//TODO fix name
- (TimeSpan*)time;

- (BOOL)addReactionEquation:(NSString*)key reactionEquation:(ReactionEquation*)components;
- (BOOL)addKineticConstant:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant;

- (ReactionDefinition*)reaction:(NSString*)key;
- (NSDictionary*)reactions;


- (BOOL)addMoleculeCount:(NSString*)key count:(uint)count;
- (uint)moleculeCount:(NSString*)key;
- (NSDictionary*)moleculeCounts;
- (NSSet*)molecules;

/**
 * Validates the configruation ensuring that everything that is required is set
 */
- (NSError*)validate;
- (NSError*)makeErrorWithDescription:(NSString*)description;

@end
