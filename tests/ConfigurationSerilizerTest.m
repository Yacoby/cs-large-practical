#import "Testing.h"
#import <Foundation/Foundation.h>

#import "ConfigurationSerilizer.h"

void testDeserilize_WhenHasTime_ParsesTimeCorrectly(){
    NSString* configurationStr = @"t = 10\n";
    PASS([[ConfigurationTextSerilizer deserilize:configurationStr] time] == 10,
         "When parsing the configuration string, the time was not valid");
}

int main()
{
    START_SET("ConfigurationTxtSerilizer")
        testDeserilize_WhenHasTime_ParsesTimeCorrectly();

    END_SET("ConfigurationTxtSerilizer")

    return 0;
}

