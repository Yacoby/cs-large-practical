#import <Foundation/Foundation.h>
#import "SimulationState.h"
#import "SimulationConfiguration.h"
#import "OutputStream.h"

/**
 * This is a generic writer that allows writing of the simulation to a file
 */
@protocol OutputWriter
+ (void)writeToStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg stateHistory:(NSArray*)stateHistory;
@end

/**
 * Outputs the entire state in the required format
 */
@interface SimpleOutputWriter : NSObject <OutputWriter>{
}
+ (void)writeToStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg stateHistory:(NSArray*)stateHistory;

@end
