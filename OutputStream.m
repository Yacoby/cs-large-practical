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

@implementation FileHandleOutputStream
- (id)initWithFileHandle:(NSFileHandle*)file{
    self = [super init];
    if ( self != nil ){
        [file retain];
        mFileHandle = file;

    }
    return self;
}

- (void)dealloc{
    [mFileHandle release];
    [super dealloc];
}

- (void)write:(NSString*)str{
    NSData* data = [str dataUsingEncoding:NSASCIIStringEncoding];
    [mFileHandle writeData:data];
}
@end

@implementation FileOutputStream
- (id)initWithFileName:(NSString*)fileName{
    return [super initWithFileHandle:[NSFileHandle fileHandleForWritingAtPath:fileName]];
}
@end
