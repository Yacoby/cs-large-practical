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
    NSScanner* scanner = [NSScanner scannerWithString:str];
    if ( [scanner scanDouble:NULL] && [scanner isAtEnd] ){
        //TODO
    }
    return nil;
}

@end
