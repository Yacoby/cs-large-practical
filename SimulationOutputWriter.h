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

/**
 * @brief Writer that follows RFC 4180 to provide a standard CSV file
 * @see http://tools.ietf.org/html/rfc4180
 */
@interface RfcCsvWriter : NSObject <SimulationOutputWriter>{
    id <OutputStream> mOutputStream;
    NSArray* mOrderedMolecules;
}
- (id)initWithStream:(id <OutputStream>)stream simulationConfiguration:(SimulationConfiguration*)cfg;

/**
 * @brief writes the csv headers (column headings)
 *
 * This is split from initWithStream to allow subclasses to alter the behavior of
 * the function.
 * 
 * @see AssignmentCsvWriter::writeHeaders
 */
- (void)writeHeaders;

- (void)dealloc;
- (void)writeToStream:(SimulationState*)state;
@end

/**
 * @brief Writer that outputs in the format set out in the handout (headers prefixed by #)
 *
 * The only difference is that the output headers are prefixed by a #. This isn't
 * allowed in RFC 4180 and so technically isn't a valid CSV file.
 */
@interface AssignmentCsvWriter: RfcCsvWriter <SimulationOutputWriter>
- (void)writeHeaders;
- (void)writeToStream:(SimulationState*)state;
@end

