#import "ConfigurationSerilizer.h"

@implementation ConfigurationTextSerilizer

+ (SimulationConfiguration*)deserilize:(NSString*)input{
    SimulationConfiguration* cfg = [[[SimulationConfiguration alloc] init] autorelease];

    NSArray* lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for ( NSString* line in lines ){
        if ([line hasPrefix:@"#"]){
            continue;
        }

        if ([line rangeOfString:@"="].location != NSNotFound ){
            NSLog(line);
            NSArray* keyValue = [line componentsSeparatedByString: @"="];
            for ( int i = 0; i < [keyValue count]; ++i ){
                NSString* string = [keyValue objectAtIndex:i];
                [keyValue replaceObjectAtIndex:i withObject:[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
            }

            NSString* key = [keyValue objectAtIndex:0];
            NSString* value = [keyValue objectAtIndex:1];
            if ( [key isEqualToString:@"t"] ){
                [cfg setTime:[value intValue]];
            }else{
                [cfg setKineticConstant:key value:[value intValue]];
            }

        }

    }

    return cfg;
}

@end

