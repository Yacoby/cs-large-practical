#import "Testing.h"
#import "TestingExtension.h"
#import "KineticConstant.h"

void init_WhenSetToValue_doubleValueGetsValue(){
    KineticConstant* underTest = [[KineticConstant alloc] initWithDouble:10];
    PASS_INT_EQUAL([underTest doubleValue], 10, "");
    [underTest release];
}

int main()
{
    START_SET("KineticConstant")
        init_WhenSetToValue_doubleValueGetsValue();
    END_SET("KineticConstant")

    return 0;
}
