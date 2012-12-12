#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "SimulationState.h"

/**
 * @brief Represents the components that make up the reaction
 *
 * This class holds which components (and their count) make up both the input (requirements) and
 * output (result) of a reaction.
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
 * @brief Immutable description of a reaction containing the Kinetic Constant and Formula
 *
 * The class has methods to allow calculations based on this reaction if the apropraite simulaton
 * state is provided.
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
- (NSSet*)alteredMolecules;

/**
 * @brief given a state (containing molecule counts) this gets the reaction rate
 * @param counts the counts of the molecules at the current simulation state that the computation will be based on
 *
 * This takes into account when the reaction involves two of the same molecules
 * as a requirement
 */
- (double)reactionRate:(SimulationState*)counts;

/**
 * @brief Applies the current reaction to the molecule counts, altering them
 * @param counts the current molecule counts of the simulation which will be altered to reflect this reaction happening
 *
 * The alteration to the state happens in place rather than doing the more elegant thing
 * of returning a new state to avoid the overhead of memory allocation during the 
 * simulation step. If needed it is trivial to add a wrapper that returns a new state without
 * altering the current state.
 */
- (void)applyReactionToCounts:(NSMutableDictionary*)counts;
@end
