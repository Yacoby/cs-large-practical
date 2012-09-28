#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "ReactionDefinition.h"

/**
 * Protocol defines the deserilization of anything into a SimulationConfiguration*
 */
@protocol ConfigurationSerilizer
+ (SimulationConfiguration*)deserilize:(NSString*)input;
@end

/**
 * Parses the script configuration as defined in the handout
 */
@interface ConfigurationTextSerilizer : NSObject<ConfigurationSerilizer>{
}
+ (SimulationConfiguration*)deserilize:(NSString*)input;

+ (ReactionComponents*) parseReactionComponents: (NSString*) reaction;
+ (NSCountedSet*) parsePartOfReactionComponents:(NSString*) part;
@end
