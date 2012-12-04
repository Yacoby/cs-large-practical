#import <Foundation/Foundation.h>

/**
 * @brief Provides a thin facade over the conversion provided by NSNumber
 * 
 * This was written to provide better and more consitent error handling over
 * NSNumber as well as try and cope with unimplemented features in gnustep.
 */
@interface NumericConversion
/**
 * @brief Parses a decimal from a string
 * @param str the string to convert to a decimal
 * @return the decimal or nil if  the string wasn't a decimal
 */
+ (NSDecimalNumber*)decimalWithString:(NSString*)str;

/**
 * @brief Parses a integer from a string
 * @param str the string to convert to a integer
 * @return the integer or nil if  the string wasn't a integer
 */
+ (NSNumber*)intWithString:(NSString*)str;
@end
