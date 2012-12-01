#import <Foundation/Foundation.h>

/**
 * @brief object that holds the state of a random number
 */
@protocol Random <NSObject>

/**
 * @brief this should return a random number and advance the state (if applicable)
 * @return a number in the range [0, 1]
 */
- (double)next;
@end

/**
 * @brief desgined to be used for testing, this provides a static random number
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
 * 
 * This allows for deterministic runs of the program so that it is possible to reproduce 
 * a given set of results
 */
@interface UniformRandom : NSObject <Random>{
    uint mSeed;
}
/**
 * @brief creates a random number generator based on the given seed.
 */
- (id)initWithSeed:(uint)seed;

/**
 * @brief returns a random number between [0, 1] inclusive
 */
- (double)next;
@end
