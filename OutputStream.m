#import "OutputStream.h"

@implementation MemoryOutputStream
-(id)init{
    self = [super init];
    if ( self != nil ){
        mMemory = [[NSMutableString alloc] init];
    }
    return self;
}

-(void) dealloc{
    [mMemory release];
    [super dealloc];
}

-(void)write:(NSString*)str{
    [mMemory appendString:str];
}

-(NSString*)memory{
    return mMemory;
}
@end
