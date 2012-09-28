#import <Foundation/Foundation.h>

@protocol OutputStream
-(void)write:(NSString*)str;
@end

@interface MemoryOutputStream : NSObject <OutputStream>{
    NSString* mOutput;
}
-(void)write:(NSString*)str;
@end
