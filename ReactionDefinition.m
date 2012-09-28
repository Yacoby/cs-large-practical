#import "ReactionDefinition.h"

@implementation ReactionComponents
- (void)setRequirements:(NSCountedSet*)requirements{
    mRequirements = requirements;
}
- (void)setResult:(NSCountedSet*)result{
    mResult = result;
}
- (NSCountedSet*)requirements{
    return mRequirements;
}
- (NSCountedSet*)result{
    return mResult;
}
@end


@implementation ReactionDefinition
- (id) initFromKineticConstant:(KineticConstant*)k reactionComponents:(ReactionComponents*)components{
    self = [super init];
    if ( self != nil ){
        mKineticConstant = k;
        mComponents = components;
    }
    return self;
}
- (KineticConstant*) kineticConstant{
    return mKineticConstant;
}
- (NSCountedSet*)requirements{
    return [mComponents requirements];
}
- (NSCountedSet*)result{
    return [mComponents result];
}
@end
