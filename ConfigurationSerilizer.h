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
+ (ReactionEquation*)parseReactionComponents: (NSString*) reaction;
+ (NSCountedSet*)parsePartOfReactionComponents:(NSString*) part;

+ (NSString*)trimWhiteSpace:(NSString*)str;
+ (BOOL)isVariableMoleculeCount:(NSString*)var;
+ (NSString*)removeCommentFromLine:(NSString*)line;
@end
