#import <Foundation/Foundation.h>
#import "SimulationState.h"
#import "OutputStream.h"

@protocol OutputWriter
- (void)writeToStream:(id <OutputStream>)stream stateHistory:(NSArray*)stateHistory;
@end

/**
 * Outputs the entire state in the required format
 */
@interface SimpleOutputWriter : NSObject <OutputWriter>{
}
- (void)writeToStream:(id <OutputStream>)stream stateHistory:(NSArray*)stateHistory;

@end
