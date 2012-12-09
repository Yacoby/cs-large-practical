#import <Foundation/Foundation.h>

/**
 * @brief This represents some form of string output to some stream location.
 */
@protocol OutputStream <NSObject>
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
- (id)init;
- (void)dealloc;

- (void)write:(NSString*)str;

/**
 * @return gets everything that has been written to this object
 */
- (NSString*)memory;
@end

/**
 * @brief stream wrapper around file functions so that all messages are written via the given handle
 */
@interface FileHandleOutputStream : NSObject <OutputStream>{
    NSFileHandle* mFileHandle;
}
- (id)initWithFileHandle:(NSFileHandle*)file;
- (void)dealloc;
- (void)write:(NSString*)str;
@end

/**
 * @brief convenience wrapper around FileHandleOutputStream to allow construction from a file
 */
@interface FileOutputStream : FileHandleOutputStream {
}
- (id)initWithFileName:(NSString*)fileName;
@end
