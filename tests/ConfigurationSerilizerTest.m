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

int main()
{
    START_SET("ConfigurationTxtSerilizer")
        testDeserilize_WhenHasTime_ParsesTimeCorrectly();

    END_SET("ConfigurationTxtSerilizer")

    return 0;
}

