#import "Testing.h"
#import "TestingExtension.h"
#import "CommandLineOptionParser.h"

void get_WhenHasNoRules_ReturnsAllArgsAsPositionalArgs(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    NSArray* input = [NSArray arrayWithObjects: @"foo", @"bar", nil];

    CommandLineOptions* options = [underTest parse:input];
    NSArray* remainingArgs = [options getRemainingArguments];

    PASS([remainingArgs isEqualToArray: input], "");
}

void addParse_WhenHasOneArgumentAndOption_ParsesCorrectly(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"seed"];

    NSArray* input = [NSArray arrayWithObjects: @"--seed", @"10", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* seedResult = [options getOptionWithName: @"seed"];
    NSString* expected = @"10";

    PASS_EQUAL(seedResult, expected, "");
}

void addParse_WhenHasShortArgumentAndOption_ParsesCorrectly(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"seed"];

    NSArray* input = [NSArray arrayWithObjects: @"--seed", @"10", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* seedResult = [options getOptionWithName: @"seed"];
    NSString* expected = @"10";

    PASS_EQUAL(seedResult, expected, "");
}

void addParse_WhenHasZeroArguments_ParsesAsBoolean(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"foo" andShortName: @"f" isBoolean:YES];

    NSArray* input = [NSArray arrayWithObjects: @"--foo", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* result = [options getOptionWithName: @"foo"];
    NSString* expected = @"1";
    PASS_EQUAL(result, expected, "");
}

void addParse_WhenHasUnknownOptionName_ReturnsError(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    NSArray* input = [NSArray arrayWithObjects: @"--foo", nil];

    NSError* err;
    CommandLineOptions* options = [underTest parse:input error:&err];
    PASS(options == nil, "There is no valid options to return");

    NSString* reason = [err localizedFailureReason];

    NSString* expectedReason = @"Unknown argument --foo";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void addForKey_WhenAddingForKey_ResultIsStoredInThatKey(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentForKey: @"foo" withName:@"bar"];

    NSArray* input = [NSArray arrayWithObjects: @"--bar", @"baz", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* result = [options getOptionWithName: @"foo"];
    NSString* expected = @"baz";
    PASS_EQUAL(result, expected, "");
}

int main()
{
    START_SET("CommandLineOptionParser")
        get_WhenHasNoRules_ReturnsAllArgsAsPositionalArgs();
        addParse_WhenHasShortArgumentAndOption_ParsesCorrectly();
        addParse_WhenHasOneArgumentAndOption_ParsesCorrectly();
        addParse_WhenHasZeroArguments_ParsesAsBoolean();
        addParse_WhenHasUnknownOptionName_ReturnsError();
        addForKey_WhenAddingForKey_ResultIsStoredInThatKey();
    END_SET("CommandLineOptionParser")

    return 0;
}
