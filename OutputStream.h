#import <Foundation/Foundation.h>

/**
 * @brief This represents some form of string output to some location.
 */
@protocol OutputStream
- (void)write:(NSString*)str;
@end

/** 
 * @brief Stores written data in memory where it can be retrieved.
 *
 * This is used for testing so that we are able to inspect the output of the
 * OutputWriter without having to touch the filesystem.
 */
@interface MemoryOutputStream : NSObject <OutputStream>{
    NSMutableString* mMemory;
}
- (id)init ;
- (void)dealloc;

- (void)write:(NSString*)str;
- (NSString*)memory;
@end
