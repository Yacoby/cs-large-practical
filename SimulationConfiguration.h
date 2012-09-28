#include <Foundation/Foundation.h>

@interface SimulationConfiguration : NSObject{
    int mTime;
    NSMutableDictionary* mKineticConstants;
}
- (int) time;
- (void)setTime:(int)time;
- (void)setKineticConstant:(NSString*)key value:(int)value;
- (int)kineticConstant:(NSString*)key;
@end
