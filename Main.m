#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"
int main(void){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* configurationStr = @"t = 10\n";
    [pool drain];
    return [[ConfigurationTextSerilizer deserilize:configurationStr] time] == 10;

}
