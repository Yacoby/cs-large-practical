#import "Testing.h"
#import "TestingExtension.h"
#import <Foundation/Foundation.h>

#import "ConfigurationSerilizer.h"

void testDeserilize_WhenHasTime_ParsesTimeCorrectly(){
    NSString* configurationStr1 = @"t = 10\n";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr1] time], 10, "");

    NSString* configurationStr2 = @"t = 20\n";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr2] time], 20, "");
}

void testDeserilize_WhenHasComment_DoesNotAffectParsing(){
    NSString* configurationStr = @"#comment\nt = 10\n#comment";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr] time], 10, "");
}

void testDeserilize_WhenHasTimeAndKineticConstant_ParsesConstantCorrectly(){
    NSString* configurationStr = @"t = 10\nd = 5";
    PASS_INT_EQUAL([[ConfigurationTextSerilizer deserilize:configurationStr] kineticConstant:@"d"], 5, "");
}

int main()
{
    START_SET("ConfigurationTxtSerilizer")
        testDeserilize_WhenHasTime_ParsesTimeCorrectly();
        testDeserilize_WhenHasComment_DoesNotAffectParsing();
        testDeserilize_WhenHasTimeAndKineticConstant_ParsesConstantCorrectly();
    END_SET("ConfigurationTxtSerilizer")

    return 0;
}

