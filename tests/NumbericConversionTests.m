#import "Testing.h"
#import "TestingExtension.h"
#import "NumericConversion.h"

void decimalWithString_WhenHasInvalidDecimal_ReturnsNil(){
    PASS([NumericConversion decimalWithString:@"foo"] == nil, "Invalid decimal should return nil");
}

void decimalWithString_WhenHasPartInvalidDecimal_ReturnsNil(){
    PASS([NumericConversion decimalWithString:@"1.5 foo"] == nil, "Invalid decimal should return nil");
}

void decimalWithString_WhenHasSFNotation_Parses(){
    NSDecimalNumber* number = [NumericConversion decimalWithString:@"1.5e2"];
    PASS([number doubleValue] == 150, "SF notation should be valid");
}

void decimalWithString_WhenHasNegativeNumber_Parses(){
    NSDecimalNumber* number = [NumericConversion decimalWithString:@"-5e-2"];
    PASS([number doubleValue] == -0.05, "Negatives should be supported");
}

void intWithString_WhenHasDecimalNumber_ReturnsNil(){
    NSNumber* number = [NumericConversion intWithString:@"1.5"];
    PASS(number == nil, "Shouldn't parse decimals");
}

void intWithString_WhenHasDecimalExpNumber_ReturnsNil(){
    NSNumber* number = [NumericConversion intWithString:@"1.5e10"];
    PASS(number == nil, "Shouldn't parse decimals");
}

void intWithString_WhenHasBasicNumber_ShouldParse(){
    NSNumber* number = [NumericConversion intWithString:@"123654"];
    PASS(number != nil, "");
    PASS_INT_EQUAL([number intValue], 123654, "Should parse basic number");
}

void intWithString_WhenHasExpNumber_ReturnsNil(){
    NSNumber* number = [NumericConversion intWithString:@"1e5"];
    PASS(number != nil, "");
    PASS_INT_EQUAL([number intValue], 100000, "Should parse exponent");
}

int main()
{
    START_SET("NumericConversion")
        decimalWithString_WhenHasInvalidDecimal_ReturnsNil();
        decimalWithString_WhenHasPartInvalidDecimal_ReturnsNil();

        decimalWithString_WhenHasSFNotation_Parses();
        decimalWithString_WhenHasNegativeNumber_Parses();

        intWithString_WhenHasBasicNumber_ShouldParse();
        intWithString_WhenHasDecimalNumber_ReturnsNil();
        intWithString_WhenHasDecimalExpNumber_ReturnsNil();

        intWithString_WhenHasExpNumber_ReturnsNil();

    END_SET("NumericConversion")

    return 0;
}
