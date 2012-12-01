#import "Factory.h"
#import "ErrorConstants.h"

@implementation Factory
- (id)initFromProtocol:(Protocol*)protocol{
    self = [super init];
    if ( self ){
        mNameToValidClass = [[NSMutableDictionary alloc] init];
        [self addValidFromProtocol:protocol];
    }
    return self;
}

- (void)dealloc{
    [mNameToValidClass release];
    [super dealloc];
}

- (void)addValidFromProtocol:(Protocol*)protocol{
    Class* classes;
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0 ) {
        classes = malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; ++i) {
            Class cls = classes[i];
            if (class_conformsToProtocol(cls, protocol)) {
                [mNameToValidClass setObject:cls forKey:NSStringFromClass(cls)];
            }
        }
        free(classes);
    }
}


- (Class)classFromString:(NSString*)clsName{
    return [mNameToValidClass objectForKey:clsName];
}

- (Class)classFromString:(NSString*)clsName error:(NSError**)error{
    Class cls = [self classFromString:clsName];
    if ( cls == nil && error ){
        NSString* description = [NSString stringWithFormat:@"Could not find class <%@> in valid list <%@>",
                                                            clsName,
                                                            [[[self listClasses] allObjects] componentsJoinedByString:@","]];
        NSDictionary* errorDictionary = [[[NSDictionary alloc]
                                                        initWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil]
                                                        autorelease];
        *error = [NSError errorWithDomain:ERROR_DOMAIN code:FACTORY_ERROR userInfo:errorDictionary];
    }
    return cls;
}

- (NSSet*)listClasses{
    NSMutableSet* result = [[[NSMutableSet alloc] init] autorelease];
    for ( NSString* className in mNameToValidClass ){
        [result addObject:className];
    }
    return result;
}
@end
