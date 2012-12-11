#import <Foundation/Foundation.h>

/**
 * @brief Allows lookup of a certain subset of classes
 *
 * This provides additional security to ensure that when a user specifies which
 * class to create we are guaranteed that it conforms to a protocol.
 */
@interface Factory : NSObject{
    NSMutableDictionary* mNameToValidClass;
}

/**
 * @brief creates a class such that the 
 * @TODO docs
 */
- (id)initFromProtocol:(Protocol*)protocol;

- (void)dealloc;

/**
 * @brief addds as valid classes all classes that implement the given protocol.
 * @note this is not intended to be called by the user
 */
- (void)addValidFromProtocol:(Protocol*)protocol;

/**
 * @return the class or nil if the class cannot be created from this factory
 *
 * @see classFromString:error:
 */
- (Class)classFromString:(NSString*)cls;

/**
 * @brief get a class from a string if the class is valid 
 *
 * The nature of a valid class if dependent on how the Factory object was created,
 * i.e. if it was created from a protocol then for a class to be valid it must
 * implement that protocol.
 *
 * @param cls the NSString* class name of the class to return
 * @param error this is filled with the error that occured if nil is returned
 * @return the class or nil if the class cannot be created from this factory
 */
- (Class)classFromString:(NSString*)cls error:(NSError**)error;

/**
 * @return A set of NSString* with the classes that can be accessed from this class
 */
- (NSSet*)listClasses;

@end
