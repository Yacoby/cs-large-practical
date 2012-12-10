#import <Foundation/Foundation.h>

/**
 * @brief object that holds the state of a random number and allows advancing that state
 * 
 * The encapsulation of the random state rather than relying on a global random state allows
 * the application to be reasoned about in a better way. Standard arguments for the creation of
 * this class are the same as the arguments behind "Global variables are a bad thing".
 */
@protocol Random <NSObject>

/**
 * @brief this should return a random number and advance the state (if applicable)
 * @return a number in the range [0, 1]
 */
- (double)next;
@end

/**
 * @brief designed to be used for testing, this provides a static random number
 *
 * To be valid the random number used with this must be chosen with a dice or
 * something. Else it wouldn't be random ;)
 *
 * @see http://xkcd.com/221/
 */
@interface StaticRandom : NSObject <Random>{
    double mStaticNumber;
}
- (id)initWithStaticNumber:(double)number;

/**
 * @brief gets a static number
 * @return the number that the object was initiated with
 */
- (double)next;
@end

/**
 * @brief This provides a uniform random number generator that generates numbers based on the given seed
 */
@interface UniformRandom : NSObject <Random>{
    uint mSeed;
}
/**
 * @brief creates a random number generator with an initial state
 * @param seed the initial sate of the random number generator
 */
- (id)initWithSeed:(uint)seed;

/**
 * @brief returns a random number between [0, 1] inclusive
 */
- (double)next;
@end
