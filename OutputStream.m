#import "OutputStream.h"

@implementation MemoryOutputStream
-(void)write:(NSString*)str{
    mOutput = [mOutput stringByAppendingString:str];
}
@end
