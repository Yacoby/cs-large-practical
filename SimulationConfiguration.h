/**
 * @file
 */
#import <Foundation/Foundation.h>
#import "KineticConstant.h"
#import "ReactionDefinition.h"
#import "TimeSpan.h"

/**
 * @brief used to hold the names of a reaction and a molecule
 *
 * Used in validation to hold a molecule mentioned in a reaction that doesn't have an initial count
 */
@interface ReactionMoleculePair : NSObject{
    NSString* mReaction;
    NSString* mMolecule;
}
- (id)initWithReactionName:(NSString*)reaction moleculeName:(NSString*)molecle;
- (void)dealloc;

- (NSString*)reactionName;
- (NSString*)moleculeName;
@end

/**
 * @brief Holds the result of a validation of SimulationConfiguration
 *
 * This is used as the result of the SimulationConfiguration::validate: and 
 * allows a distinction between critical errors (which means that the Configuration
 * is invalid) and warnings which means that it has some issues that will not cause
 * a problem with using the configuration.
 */
@interface ConfigurationValidation : NSObject{
    NSMutableSet* mErrorMessages;
    NSMutableSet* mWarningMessages;
}
- (id)init;
- (void)dealloc;
/**
 * @brief gets all errors - things which mean that the configuration is invalid
 * @return the set of NSString* of all errors
 */
- (NSSet*)errors;

/**
 * @brief gets all warnings - problems with the configuration that are not errors
 * @return the set of NSString* of all warnings
 */
- (NSSet*)warnings;

- (void)addError:(NSString*)errorMsg;
- (void)addWarning:(NSString*)warningMsg;
@end

/**
 * Used as a molecule count to indicate there is no molecule with the given key
 * @see SimulationConfiguration::moleculeCount:
 */
extern int UNKNOWN_MOLECULE;

/**
 * @brief Holds a copy of the configuration, which may or may not be valid
 *
 * This provides methods to validate the configuration. If the configuration is
 * not valid then it shouldn't be used (i.e. call validate).
 *
 * The ReactionDefinition objects provided by this class are generated on demand
 * so for the same reaction there may be two different objects.
 */
@interface SimulationConfiguration : NSObject{
    TimeSpan* mTime;
    NSMutableDictionary* mReactionEquations;
    NSMutableDictionary* mMoleculeCounts;
    NSMutableDictionary* mKineticConstants;

    NSMutableArray* mMoleculeOrder;
}
- (id)init;
- (void)dealloc;

/**
 * @brief sets the time that the reaction should stop at
 */
- (void)setTime:(TimeSpan*)time;
- (TimeSpan*)time;

/**
 * @brief adds the reaction with the given key to the list of reactions
 * @param key the name of the reaction
 * @param components the reaction equation
 * @return true if it was added, false if a reaction with that key already existed
 *
 * @note Each reaction should have an equivalent kinetic constant
 */
- (BOOL)addReactionEquation:(NSString*)key reactionEquation:(ReactionEquation*)components;

/**
 * @brief adds the kinetic constant for a reaction
 * @param key the name of the kinetic constant
 * @param kineticConstant the kinetic constant itself
 * @return true if it was added, false if a kinetic constant with that key already existed
 */
- (BOOL)addKineticConstant:(NSString*)key kineticConstant:(KineticConstant*)kineticConstant;

/**
 * @brief generates a reaction with the given key.
 * @param key the name of the reaction and kinetic constant
 * @return the ReactionDefinition or nil if there isn't a ReactionEquation and KineticConstant with that key
 */
- (ReactionDefinition*)reaction:(NSString*)key;

/**
 * @brief gets a list of all reactions that are valid
 * @return a list of all reactions that have both a ReactionEquation and KineticConstant
 */
- (NSDictionary*)reactions;

/**
 * @brief adds a molecule count
 * @param key the name of the molecule
 * @param count the number of molecules
 * @return true if it was added, false if a molecule with that key already existed
 */
- (BOOL)addMoleculeCount:(NSString*)key count:(uint)count;

/**
 * @brief gets the molecule count for that key
 * @param key the name of the molecule to get the count for
 * @return the molecule count or UNKNOWN_MOLECULE if a molecule with that key doesn't exist
 */
- (int)moleculeCount:(NSString*)key;

/**
 * @brief gets all molecule counts
 * @return a dictionary of NSString -> NSNumber holding the molecule counts
 */
- (NSDictionary*)moleculeCounts;

/**
 * @brief returns a list of molecule names (NSString*) 
 * 
 * @return an array of molecule names ordered by their occurrence in the configuration 
 */
- (NSArray*)orderedMolecules;

/**
 * @return a set of NSString* with all molecules
 */
- (NSSet*)molecules;

/**
 * Validates the configuration ensuring that everything that is required is set
 */
- (ConfigurationValidation*)validate;

/**
 * @return a set of NSString* that contains the name of every kinetic constant that doesn't have a reaction equation
 * Used by validate
 */
- (NSSet*)kineticConstantsWithoutReactionEquations;

/**
 * @return a set of NSString* that contains the name of every reaction that doesn't have a kinetic constant
 * Used by validate
 */
- (NSSet*)reactionEquationsWithoutKineticConstants;

/**
 * @return a set of ReactionMoleculePair* that holds the name of every molecule 
            reaction pair such that the molecule does not have a count
 * Used by validate
 */
- (NSSet*)moleculesInReactionsWithNoCount;

/**
 * @return a set of NSString* containing all the molecules not used in any reactions
 * Used by validate
 */
- (NSSet*)moleculesNotUsedInReactions;

@end
