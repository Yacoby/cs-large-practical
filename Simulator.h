#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "SimulationState.h"
#import "OutputWriter.h"
#import "Random.h"

@interface Simulator : NSObject {
    SimulationConfiguration* mCfg;
    NSMutableArray* mReactions;
    id <OutputWriter> mWriter;
    id <Random> mRandom;
}
- (id)initWithCfg:(SimulationConfiguration*)cfg randomGen:(id <Random>)random outputWriter:(id <OutputWriter>)writer;
- (void)dealloc;
- (void)runSimulation;
- (BOOL)runSimulationStep:(SimulationState*)state;
@end

