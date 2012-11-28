#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "SimulationState.h"

/**
 * @brief Represents the components that make up the reaction
 *
 * This class holds which components (and their count) make up both the input and
 * output of a reaction
 */
@interface ReactionEquation : NSObject{
    NSCountedSet* mRequirements;
    NSCountedSet* mResult;
}
- (void)dealloc;
- (void)setRequirements:(NSCountedSet*)requirements;
- (void)setResult:(NSCountedSet*)result;

- (NSCountedSet*)requirements;
- (NSCountedSet*)result;
@end

/** 
 * @brief Immutable description of a reaction containing the Kinetic Constant and Forumula
 *
 */
@interface ReactionDefinition : NSObject{
    KineticConstant* mKineticConstant;
    ReactionEquation * mEquation;
}
- (id)initFromKineticConstant:(KineticConstant*)k reactionEquation:(ReactionEquation*)eqn;
- (void)dealloc;

- (KineticConstant*)kineticConstant;
- (NSCountedSet*)requirements;
- (NSCountedSet*)result;
- (double)reactionRate:(SimulationState*)state;
- (void)applyReactionToCounts:(NSMutableDictionary*)state;
@end
