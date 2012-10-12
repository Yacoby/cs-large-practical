#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "OutputWriter.h"

@interface Simulator : NSObject {
    SimulationConfiguration* mCfg;
    NSMutableArray* mReactions;
    id <OutputWriter> mWriter;
}
- (id)initWithCfg:(SimulationConfiguration*)cfg outputWriter:(id <OutputWriter>)writer;
- (void)dealloc;
- (void)runSimulation;
- (BOOL)runSimulationStep:(SimulationState*)state;
@end

