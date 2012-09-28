
#define PASS_INT_EQUAL(testExpression__, testExpect__, testFormat__, ...) \
  NS_DURING \
    { \
      int _cond; \
      int _obj; \
      int _exp; \
      id _tmp = testRaised; testRaised = nil; [_tmp release]; \
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      testLineNumber = __LINE__; \
      testStart(); \
      _obj = testExpression__;\
      _exp = testExpect__;\
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      _cond = _obj == _exp; \
      pass(_cond, "%s:%d ... " testFormat__, __FILE__, __LINE__, ## __VA_ARGS__); \
      if (!_cond) \
	{ \
              fprintf(stderr, "%s: Expected '%d' and got '%d'\n", __FUNCTION__,  _exp, _obj); \
	} \
    } \
  NS_HANDLER \
    testRaised = [localException retain]; \
    pass(0, "%s:%d ... " testFormat__, __FILE__, __LINE__, ## __VA_ARGS__); \
    printf("%s: %s", [[testRaised name] UTF8String], \
      [[testRaised description] UTF8String]); \
  NS_ENDHANDLER
