#include <Foundation/Foundation.h>
#include "KineticConstant.h"

/**
 * Object holds a valid copy of the configuration.
 *
 * TODO there should be no way to load an invalid configuration
 */
@interface SimulationConfiguration : NSObject{
    int mTime;
    NSMutableDictionary* mKineticConstants;
}
- (int) time;
- (void)setTime:(int)time;
- (void)setKineticConstant:(NSString*)key value:(int)value;
- (KineticConstant*)kineticConstant:(NSString*)key;
@end
