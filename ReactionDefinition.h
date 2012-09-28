#import <Foundation/Foundation.h>
#import "KineticConstant.h"

@interface ReactionComponents : NSObject{
    NSCountedSet* mRequirements;
    NSCountedSet* mResult;
}
- (void)dealloc;
- (void)setRequirements:(NSCountedSet*)requirements;
- (void)setResult:(NSCountedSet*)result;

- (NSCountedSet*)requirements;
- (NSCountedSet*)result;
@end

@interface ReactionDefinition : NSObject{
    KineticConstant* mKineticConstant;
    ReactionComponents* mComponents;
}
- (id) initFromKineticConstant:(KineticConstant*)k reactionComponents:(ReactionComponents*)components;
- (void) dealloc;

- (KineticConstant*) kineticConstant;
- (NSCountedSet*)requirements;
- (NSCountedSet*)result;
@end
