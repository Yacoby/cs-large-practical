#import <Foundation/Foundation.h>
#import "SimulationState.h"

@protocol OutputWriter
- (void)writeToStream:(NSOutputStream*)stream stateHistory:(NSArray*)stateHistory;
@end

/**
 * Outputs the entire state in the required format
 */
@interface SimpleOutputWriter : NSObject <OutputWriter>{
}
- (void)writeToFile:(NSOutputStream*)stream stateHistory:(NSArray*)stateHistory;

@end
