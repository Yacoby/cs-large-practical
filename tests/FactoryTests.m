#import "Testing.h"
#import "TestingExtension.h"
#import "Factory.h"

/**
 * @brief Protocol for testing the factory class
 */
@protocol FactoryProtocol <NSObject>
- (int)num;
@end

/**
 * @brief used for testing the factory class
 */
@interface FactoryClass1 : NSObject<FactoryProtocol>
- (int)num;
@end

@implementation FactoryClass1
- (int)num{
    return 1;
}
@end

/**
 * @brief used for testing the factory class
 */
@interface FactoryClass2 : NSObject<FactoryProtocol>
- (int)num;
@end

@implementation FactoryClass2
- (int)num{
    return 2;
}
@end

void listClasses_WhenHasTwoClasses_ListsThem(){
    Factory* underTest = [[[Factory alloc] initFromProtocol:@protocol(FactoryProtocol)] autorelease];

    NSSet* classList = [underTest listClasses];
    PASS_INT_EQUAL([classList count], 2, "");
    PASS([classList member:@"FactoryClass1"] != nil, "");
    PASS([classList member:@"FactoryClass2"] != nil, "");
}

void classFromString_WhenNotValidClass_ReturnNil(){
    Factory* underTest = [[[Factory alloc] initFromProtocol:@protocol(FactoryProtocol)] autorelease];
    Class cls = [underTest classFromString:@"foo"];
    PASS(cls == nil, "");
}

void classFromString_WhenValidClass_ReturnsCorrectClass(){
    Factory* underTest = [[[Factory alloc] initFromProtocol:@protocol(FactoryProtocol)] autorelease];
    Class cls2 = [underTest classFromString:@"FactoryClass2"];
    id factoryCls2 = [[[cls2 alloc] init] autorelease];
    PASS_INT_EQUAL( [factoryCls2 num], 2, "");

    Class cls1 = [underTest classFromString:@"FactoryClass1"];
    id factoryCls1 = [[[cls1 alloc] init] autorelease];
    PASS_INT_EQUAL( [factoryCls1 num], 1, "");
}


int main(){
    START_SET("Factory")
        listClasses_WhenHasTwoClasses_ListsThem();
        classFromString_WhenNotValidClass_ReturnNil();
        classFromString_WhenValidClass_ReturnsCorrectClass();
    END_SET("Factory")

    return 0;
}
