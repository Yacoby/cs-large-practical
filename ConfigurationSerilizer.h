#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "ReactionDefinition.h"


/**
 * @brief Protocol defines the deserilization of anything into a SimulationConfiguration*
 */
@protocol ConfigurationSerilizer
+ (SimulationConfiguration*)deserilize:(NSString*)input;
+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err;
@end

/**
 * @brief Parses the script configuration as defined in the handout
 */
@interface ConfigurationTextSerilizer : NSObject<ConfigurationSerilizer>{
}
+ (SimulationConfiguration*)deserilize:(NSString*)input;

/**
 * 
 * @note This is not how I would have written the function had I had access
 *       to a decent set of libraries. However getting things like ParseKit
 *       to compile seemed to be an absolute nightmare
 */
+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err;


/**
 * @brief Parses the reaction components. E.g: A + B -> C
 */
+ (ReactionEquation*)parseReactionComponents: (NSString*) reaction error:(NSError**)err;
+ (NSCountedSet*)parsePartOfReactionComponents:(NSString*) part error:(NSError**)err;

/**
 * @brief Removes all white space from the lhs and rhs of a string
 */
+ (NSString*)trimWhiteSpace:(NSString*)str;

/**
 * @brief returns true if a string variable is a molecule count
 *
 * Returns true if it starts with a capital letter
 */ 
+ (BOOL)isVariableMoleculeCount:(NSString*)var;

/**
 * @brief returns true if a string variable is a kinetic constant
 *
 * Returns true if it starts with a lower case letter
 */ 
+ (BOOL)isKineticConstant:(NSString*)var;

/**
 * @brief removes everything after the first # symbol (including the # symbol)
 */ 
+ (NSString*)removeCommentFromLine:(NSString*)line;

/**
 * @brief makes an error object for the ConfigurationSerilizer.
 */ 
+ (void)makeError:(NSError**)err withDescription:(NSString*)desc;
@end
