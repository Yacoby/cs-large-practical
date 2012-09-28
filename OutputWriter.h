#import <Foundation/Foundation.h>
#import "SimulationState.h"
#import "SimulationConfiguration.h"
#import "OutputStream.h"

/**
 * @brief This is a generic writer that allows writing of the simulation to a stream
 */
@protocol OutputWriter
+ (void)writeToStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg stateHistory:(NSArray*)stateHistory;
@end

/**
 * @brief Outputs the entire state in the required format
 *
 * This is the basic formatter which will output the entire state without attempting
 * to aggregate any of the data
 */
@interface SimpleOutputWriter : NSObject <OutputWriter>{
}
+ (void)writeToStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg stateHistory:(NSArray*)stateHistory;

@end
