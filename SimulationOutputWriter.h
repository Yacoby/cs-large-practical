#import <Foundation/Foundation.h>
#import "SimulationState.h"
#import "SimulationConfiguration.h"
#import "OutputStream.h"

/**
 * @brief This is a generic writer that allows writing of the simulation to a stream
 */
@protocol SimulationOutputWriter <NSObject>
- (void)writeToStream:(SimulationState*)state;
@end

@interface RfcCsvWriter : NSObject <SimulationOutputWriter>{
    id <OutputStream> mOutputStream;
    NSArray* mOrderedMolecules;
}
- (id)initWithStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg;
- (void)writeHeaders;

- (void)dealloc;
- (void)writeToStream:(SimulationState*)state;
@end

/**
 * @brief Outputs the entire state in the required format
 */
@interface AssignmentCsvWriter: RfcCsvWriter <SimulationOutputWriter>
- (void)writeHeaders;
- (void)writeToStream:(SimulationState*)state;
@end

