#import "Testing.h"
#import "TestingExtension.h"
#import "Random.h"

void staticRandom_WhenInitedWith5_AlwaysReturns5(){
    StaticRandom* underTest = [[[StaticRandom alloc] initWithStaticNumber:5] autorelease];
    PASS_INT_EQUAL(5, [underTest next], "");
    PASS_INT_EQUAL(5, [underTest next], "");
}

int main() {
    START_SET("RandomTests")
        staticRandom_WhenInitedWith5_AlwaysReturns5();
    END_SET("RandomTests")

    return 0;
}
