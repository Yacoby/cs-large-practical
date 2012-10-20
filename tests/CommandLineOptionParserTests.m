#import "Testing.h"
#import "TestingExtension.h"
#import "CommandLineOptionParser.h"

void get_WhenHasNoRulesAndGivenArgument_ReturnsNil(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    NSArray* input = [NSArray arrayWithObjects: @"foo", @"bar", nil];

    NSError* err = NULL;
    CommandLineOptions* options = [underTest parse:input error:&err];
    PASS(options == nil, "There is no valid options to return");
    NSString* reason = [err localizedDescription];
    NSString* expectedReason = @"Unexpected positional argument foo";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void addParse_WhenHasOneArgumentAndOption_ParsesCorrectly(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"--seed" ofType:String];

    NSArray* input = [NSArray arrayWithObjects: @"--seed", @"10", nil];

    NSError* err = nil;
    CommandLineOptions* options = [underTest parse:input error:&err];
    PASS(options != nil, "");

    NSString* seedResult = [options getOptionWithName: @"seed"];
    NSString* expected = @"10";

    PASS_EQUAL(seedResult, expected, "");
}

void addParse_WhenHasShortArgumentAndOption_ParsesCorrectly(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"--seed" andShortName:@"-s" ofType:String];

    NSArray* input = [NSArray arrayWithObjects: @"-s", @"10", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* seedResult = [options getOptionWithName: @"seed"];
    NSString* expected = @"10";

    PASS_EQUAL(seedResult, expected, "");
}

void addParse_WhenHasZeroArguments_ParsesAsBoolean(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"--foo" andShortName: @"-f" ofType:Boolean];

    NSArray* input = [NSArray arrayWithObjects: @"--foo", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSNumber* result = [options getOptionWithName: @"foo"];
    NSNumber* expected = [NSNumber numberWithBool:YES];
    PASS_EQUAL(result, expected, "");
}

void addParse_WhenHasUnknownOptionName_ReturnsError(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    NSArray* input = [NSArray arrayWithObjects: @"--foo", nil];

    NSError* err;
    CommandLineOptions* options = [underTest parse:input error:&err];
    PASS(options == nil, "There is no valid options to return");

    NSString* reason = [err localizedDescription];

    NSString* expectedReason = @"Unknown argument --foo";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void parse_WhenBooleanArgNotSet_IsFalse(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"--foo" ofType:Boolean];

    NSArray* input = [NSArray arrayWithObjects: nil];

    CommandLineOptions* options = [underTest parse:input];

    NSNumber* result = [options getOptionWithName: @"foo"];
    NSNumber* expected = [NSNumber numberWithBool:NO];
    PASS_EQUAL(result, expected, "");
}

void addForKey_WhenAddingForKey_ResultIsStoredInThatKey(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addOptionalArgumentForKey: @"foo" withName:@"--bar" ofType:String];

    NSArray* input = [NSArray arrayWithObjects: @"--bar", @"baz", nil];

    CommandLineOptions* options = [underTest parse:input];

    NSString* result = [options getOptionWithName: @"foo"];
    NSString* expected = @"baz";
    PASS_EQUAL(result, expected, "");
}

void add_WhenSetsType_TypeMatches(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    CommandLineType expectedType = Boolean;
    [underTest addArgumentWithName: @"--foo" ofType:expectedType];
    CommandLineType result =  [underTest getArgumentType:@"foo"];
    PASS_INT_EQUAL(expectedType, result, "");
}

void getKeyFromArgument_WhenIsLongName_GetsNameCorrectly(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    NSString* expectedKey = @"foo";
    NSString* argument = [NSString stringWithFormat:@"%@%@", COMMAND_LINE_LONG_PREFIX, expectedKey];
    [underTest addArgumentWithName:argument ofType:String];
    NSString* key = [underTest getKeyFromArgument:argument];
    PASS_EQUAL(key, expectedKey, "");
}

void parse_WhenHasPositionalArgAndIsNotSet_ReturnsError(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"foo" ofType:String];

    NSError* err = NULL;
    NSArray* input = [[[NSArray alloc] init] autorelease];
    CommandLineOptions* options = [underTest parse:input error:&err];
    PASS(options == nil, "There is no valid options to return");

    NSString* reason = [err localizedDescription];
    NSString* expectedReason = @"Not all required arguments were given: foo";
    NSRange search = [reason rangeOfString:expectedReason options:NSCaseInsensitiveSearch];
    PASS(search.location != NSNotFound, "");
}

void parse_WhenHasPositionalArgThatIsNotRequired_DoesntReturnError(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"foo" ofType:String];
    [underTest setRequiredForArgumentKey:@"foo" required:NO];

    NSArray* input = [[[NSArray alloc] init] autorelease];
    CommandLineOptions* options = [underTest parse:input];
    PASS(options != nil, "The options should have parsed");
    PASS([options getOptionWithName:@"foo"] == nil, "foo shouldn't be set");
}

void parse_WhenOptionHasDefaultArgument_IsSet(){
    CommandLineOptionParser* underTest = [[[CommandLineOptionParser alloc] init] autorelease];
    [underTest addArgumentWithName: @"--foo" ofType:String];
    [underTest setDefaultValueForArgumentKey:@"foo" value:@"bar"];

    NSArray* input = [[[NSArray alloc] init] autorelease];
    CommandLineOptions* options = [underTest parse:input];

    NSString* result = [options getOptionWithName: @"foo"];
    NSString* expected = @"bar";
    PASS_EQUAL(result, expected, "");
}

int main(){
    START_SET("CommandLineOptionParser")
        get_WhenHasNoRulesAndGivenArgument_ReturnsNil();
        addParse_WhenHasShortArgumentAndOption_ParsesCorrectly();
        addParse_WhenHasOneArgumentAndOption_ParsesCorrectly();
        addParse_WhenHasZeroArguments_ParsesAsBoolean();
        addParse_WhenHasUnknownOptionName_ReturnsError();
        addForKey_WhenAddingForKey_ResultIsStoredInThatKey();
        parse_WhenBooleanArgNotSet_IsFalse();
        add_WhenSetsType_TypeMatches();
        getKeyFromArgument_WhenIsLongName_GetsNameCorrectly();
        parse_WhenHasPositionalArgAndIsNotSet_ReturnsError();
        parse_WhenHasPositionalArgThatIsNotRequired_DoesntReturnError();
        parse_WhenOptionHasDefaultArgument_IsSet();
    END_SET("CommandLineOptionParser")

    return 0;
}
