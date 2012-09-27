#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"

@protocol ConfigurationSerilizer
+ (SimulationConfiguration*)deserilize:(NSString*)input;
@end

@interface ConfigurationTextSerilizer : NSObject<ConfigurationSerilizer>{
}
+ (SimulationConfiguration*)deserilize:(NSString*)input;
@end
