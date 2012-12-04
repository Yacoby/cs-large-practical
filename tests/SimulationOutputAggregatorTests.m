#import "Testing.h"
#import "TestingExtension.h"
#import "SimulationOutputAggregator.h"

/**
 * Mock object for a writer, allows a simple method of checking what state
 * changes have been sent from the Aggregator
 */
@interface WriterMock : NSObject<SimulationOutputWriter>{
    NSMutableSet* mExpected;
    NSMutableArray* mUnexpected;
}
- (id)init;
- (void)dealloc;

- (void)expects:(SimulationState*)state;

- (NSSet*)expected;
- (NSArray*)unexpected;

- (void)writeToStream:(SimulationState*)state;
@end

@implementation WriterMock
- (id)init{
    self = [super init];
    if ( self ){
        mExpected = [[NSMutableSet alloc] init];
        mUnexpected = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc{
    [mExpected release];
    [mUnexpected release];
    [super dealloc];
}

- (void)expects:(SimulationState*)state{
    [mExpected addObject:state];
}

- (NSSet*)expected{
    return mExpected;
}

- (NSArray*)unexpected{
    return mUnexpected;
}

- (void)writeToStream:(SimulationState*)state{
    if ( [mExpected member:state] ){
        [mExpected removeObject:state];
    }else{
        [mUnexpected addObject:state];
    }
}
@end


@interface ExactHundredMsTests : NSObject{
    NSMutableDictionary* counts1;
    TimeSpan* startTime1;
    SimulationState* simState1;

    NSMutableDictionary* counts2;
    TimeSpan* startTime2;
    SimulationState* simState2;

    NSMutableDictionary* counts3;
    TimeSpan* startTime3;
    SimulationState* simState3;

    NSMutableDictionary* counts4;
    TimeSpan* startTime4;
    SimulationState* simState4;
}

- (void)setup;
/*
 * Ensure that when there is only one state change only that change is logged
 */
- (void)exactMsStateChanged_WhenHasOneStateChange_WritesOneOutput;

/**
 * When there are two state changes with 100ms then we need to log the inital state and
 * the state 100ms later (ending state)
 */
- (void)exactMsStateChanged_WhenHasTwoStateChangesIn100ms_WritesTwoOutputs;

/**
 * When we have three state changes in 100ms we don't log the second one
 */
- (void)exactMsStateChanged_WhenHasThreeStateChangesIn100ms_WritesTwoOutputs;

/**
 * When we have four state changes, one outside the 100ms mark, we log three state changes
 */
- (void)exactMsStateChanged_WhenHasFourStateChanges_WritesThreeOutputs;

@end

@implementation ExactHundredMsTests
- (void)setup{
    counts1 = [[[NSMutableDictionary alloc]
                                     initWithObjectsAndKeys:@"a", [NSNumber numberWithInt:1], nil]
                                     autorelease];
    startTime1 = [[[TimeSpan alloc] initFromSeconds:0] autorelease];
    simState1 = [[[SimulationState alloc] initWithTime:startTime1 moleculeCount:counts1] autorelease];

    counts2 = [[[NSMutableDictionary alloc]
                                     initWithObjectsAndKeys:@"a", [NSNumber numberWithInt:2], nil]
                                     autorelease];
    startTime2 = [[[TimeSpan alloc] initFromSeconds:0.01] autorelease];
    simState2 = [[[SimulationState alloc] initWithTime:startTime2 moleculeCount:counts2] autorelease];

    counts3 = [[[NSMutableDictionary alloc]
                                     initWithObjectsAndKeys:@"a", [NSNumber numberWithInt:3], nil]
                                     autorelease];
    startTime3 = [[[TimeSpan alloc] initFromSeconds:0.02] autorelease];
    simState3 = [[[SimulationState alloc] initWithTime:startTime3 moleculeCount:counts3] autorelease];

    counts4 = [[[NSMutableDictionary alloc]
                                     initWithObjectsAndKeys:@"a", [NSNumber numberWithInt:4], nil]
                                     autorelease];
    startTime4 = [[[TimeSpan alloc] initFromSeconds:0.11] autorelease];
    simState4 = [[[SimulationState alloc] initWithTime:startTime4 moleculeCount:counts4] autorelease];
}

- (void) exactMsStateChanged_WhenHasOneStateChange_WritesOneOutput{
    WriterMock* ws = [[[WriterMock alloc] init] autorelease];
    ExactHundredMsAggregator* underTest = [[[ExactHundredMsAggregator alloc] initWithWriter:ws] autorelease];

    [underTest stateChangedTo:simState1];
    [underTest simulationEnded];

    PASS_INT_EQUAL([[ws unexpected] count], 1, "Should have only one ouptut");

    SimulationState* output = [[ws unexpected] objectAtIndex:0];
    PASS_EQUAL([output moleculeCounts], counts1, "Counts should be equal");
}

- (void)exactMsStateChanged_WhenHasTwoStateChangesIn100ms_WritesTwoOutputs{
    WriterMock* ws = [[[WriterMock alloc] init] autorelease];
    ExactHundredMsAggregator* underTest = [[[ExactHundredMsAggregator alloc] initWithWriter:ws] autorelease];

    [underTest stateChangedTo:simState1];
    [underTest stateChangedTo:simState2];
    [underTest simulationEnded];

    PASS_INT_EQUAL([[ws unexpected] count], 2, "Should have two outputs, one for initial and one 100ms later for the ending state");

    SimulationState* output1 = [[ws unexpected] objectAtIndex:0];
    PASS_EQUAL([output1 moleculeCounts], counts1, "First counts should be equal to the the first state");

    SimulationState* output2 = [[ws unexpected] objectAtIndex:1];
    PASS_EQUAL([output2 moleculeCounts], counts2, "Counts should be equal to the last state");
}

- (void)exactMsStateChanged_WhenHasThreeStateChangesIn100ms_WritesTwoOutputs{
    WriterMock* ws = [[[WriterMock alloc] init] autorelease];
    ExactHundredMsAggregator* underTest = [[[ExactHundredMsAggregator alloc] initWithWriter:ws] autorelease];

    [underTest stateChangedTo:simState1];
    [underTest stateChangedTo:simState2];
    [underTest stateChangedTo:simState3];
    [underTest simulationEnded];

    PASS_INT_EQUAL([[ws unexpected] count], 2, "Should have two outputs, one for initial and one 100ms later for the ending state");

    SimulationState* output1 = [[ws unexpected] objectAtIndex:0];
    PASS_EQUAL([output1 moleculeCounts], counts1, "First counts should be equal to the the first state");

    SimulationState* output2 = [[ws unexpected] objectAtIndex:1];
    PASS_EQUAL([output2 moleculeCounts], counts3, "Counts should be equal to the last state");
}

- (void)exactMsStateChanged_WhenHasFourStateChanges_WritesThreeOutputs{
    WriterMock* ws = [[[WriterMock alloc] init] autorelease];
    ExactHundredMsAggregator* underTest = [[[ExactHundredMsAggregator alloc] initWithWriter:ws] autorelease];

    [underTest stateChangedTo:simState1];
    [underTest stateChangedTo:simState2];
    [underTest stateChangedTo:simState3];
    [underTest stateChangedTo:simState4];
    [underTest simulationEnded];

    PASS_INT_EQUAL([[ws unexpected] count], 3, "Should have three outputs, one for initial and one 100ms later and one 100ms after that");

    SimulationState* output1 = [[ws unexpected] objectAtIndex:0];
    PASS_EQUAL([output1 moleculeCounts], counts1, "First counts should be equal to the the first state");

    SimulationState* output2 = [[ws unexpected] objectAtIndex:1];
    PASS_EQUAL([output2 moleculeCounts], counts3, "Counts should be equal to the last state");

    SimulationState* output4 = [[ws unexpected] objectAtIndex:2];
    PASS_EQUAL([output4 moleculeCounts], counts4, "Counts should be equal to the last state");
}

@end


int main(){
    START_SET("SimulationOutputAggregator")
        ExactHundredMsTests* tester = [[[ExactHundredMsTests alloc] init] autorelease];
        [tester setup];
        [tester exactMsStateChanged_WhenHasOneStateChange_WritesOneOutput];

        [tester setup];
        [tester exactMsStateChanged_WhenHasTwoStateChangesIn100ms_WritesTwoOutputs];

        [tester setup];
        [tester exactMsStateChanged_WhenHasThreeStateChangesIn100ms_WritesTwoOutputs];

        [tester setup];
        [tester exactMsStateChanged_WhenHasFourStateChanges_WritesThreeOutputs];
    END_SET("SimulationOutputAggregator")

    return 0;
}
