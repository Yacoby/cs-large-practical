#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"

/**
 * Protocol defines the deserilization of anything into a SimulationConfiguration*
 *
 * TODO convert NSString to id
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
@end
