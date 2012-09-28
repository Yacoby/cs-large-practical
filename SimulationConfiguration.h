#include <Foundation/Foundation.h>
#include "KineticConstant.h"

@interface SimulationConfiguration : NSObject{
    int mTime;
    NSMutableDictionary* mKineticConstants;
}
- (int) time;
- (void)setTime:(int)time;
- (void)setKineticConstant:(NSString*)key value:(int)value;
- (KineticConstant*)kineticConstant:(NSString*)key;
@end
