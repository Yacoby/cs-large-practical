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
 * @brief Parses the reaction components. E.g: A + B -> C
 */
+ (ReactionComponents*)parseReactionComponents: (NSString*) reaction;
+ (NSCountedSet*)parsePartOfReactionComponents:(NSString*) part;
@end
