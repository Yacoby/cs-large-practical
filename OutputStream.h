#import <Foundation/Foundation.h>

/**
 * This represents some form of string output to some location
 */
@protocol OutputStream
-(void)write:(NSString*)str;
@end

/** 
 * Used for testing, this allows the capture of the output so that it can be
 * inspected rather than (say) written to a file
 */
@interface MemoryOutputStream : NSObject <OutputStream>{
    NSMutableString* mMemory;
}
-(id)init ;
-(void)dealloc;

-(void)write:(NSString*)str;
-(NSString*)memory;
@end
