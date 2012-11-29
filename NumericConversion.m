#import "NumericConversion.h"

@implementation NumericConversion
+ (NSDecimalNumber*)decimalWithString:(NSString*)str{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    if ( [scanner scanDouble:NULL] && [scanner isAtEnd] ){
        return [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}
+ (NSNumber*)intWithString:(NSString*)str{
    //We canot use NSNumberFormatter here as it isn't implemented.
    NSScanner* scanner = [NSScanner scannerWithString:str];
    if ( [scanner scanDouble:NULL] && [scanner isAtEnd] ){
        if ( [str rangeOfString:@"."].location == NSNotFound ){ //NB: This is not locale awear at all
            NSDecimalNumber* decimalNum = [NSDecimalNumber decimalNumberWithString:str];
            long long num = [decimalNum longLongValue];
            return [NSNumber numberWithLongLong:num];
        }
    }
    return nil;
}

@end
