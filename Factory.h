#import <Foundation/Foundation.h>

/**
 * @brief Allows lookup of a certain subset of classes
 *
 * This provides additional security to ensure that when a user specifies which
 * class to create we are guaranteed that it conforms to a protocol.
 *
 */
@interface Factory : NSObject{
    NSMutableDictionary* mNameToValidClass;
}

- (id)initFromProtocol:(Protocol*)protocol;
- (void)dealloc;
- (void)addValidFromProtocol:(Protocol*)protocol;

/**
 * @return the class or nil if the class cannot be created from this factory
 */
- (Class)classFromString:(NSString*)cls;
- (Class)classFromString:(NSString*)cls error:(NSError**)error;

/**
 * 
 * @return A set of strings with the classes that can be accessed from this class
 */
- (NSSet*)listClasses;

@end
