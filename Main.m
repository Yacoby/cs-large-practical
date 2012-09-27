#import <Foundation/Foundation.h>
#import "ConfigurationSerilizer.h"

int main(void){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* configurationStr = @"t = 10\n";
    NSLog(@"%d",[[ConfigurationTextSerilizer deserilize:configurationStr] time]);
    [pool drain];
    return 0;
}
