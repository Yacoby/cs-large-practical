#import "Testing.h"
#import "OutputStream.h"

void memoryStream_WhenCallsWrite_AppendsToPreviousWrite(){
    MemoryOutputStream* underTest = [[[MemoryOutputStream alloc] init] autorelease];

    [underTest write:@"Foo"];
    [underTest write:@"Bar"];

    NSString* expected = @"FooBar";

    PASS_EQUAL([underTest memory], expected, "");
}

int main()
{
    START_SET("OutputStream")
        memoryStream_WhenCallsWrite_AppendsToPreviousWrite();
    END_SET("OutputStream")

    return 0;
}
