#include <Foundation/Foundation.h>

@interface SimulationConfiguration : NSObject{
    int mTime;
}
- (int) time;
- (void)setTime:(int)time;
@end
