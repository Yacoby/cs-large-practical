#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"
#import "CommandLineOptionParser.h"

void countAllocationsForAllClasses(){
    int numClasses;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class* classes = malloc(sizeof(Class) * numClasses);
        (void) objc_getClassList (classes, numClasses);
        int i;
        for (i = 0; i < numClasses; i++) {
            GSDebugAllocationActiveRecordingObjects(classes[i]);
        }
        free(classes);
    }
}

void printAllocatedClasses(){
    printf(GSDebugAllocationList(false));
}

int main(void){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"seed"];

    NSArray* input = [NSArray arrayWithObjects: @"-s", @"10", nil];

    CommandLineOptions* options = [underTest parse:input];
    NSString* seedResult = [options getOptionWithName: @"seed"];

    countAllocationsForAllClasses();

    NSString* configurationStr = @"t = 10\n";
    NSLog(@"%f",[[[ConfigurationTextSerilizer deserilize:configurationStr] time] totalSeconds]);
    [pool drain];

    return 0;
}
