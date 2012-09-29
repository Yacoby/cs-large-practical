#import "ReactionDefinition.h"

@implementation ReactionComponents
- (void)dealloc{
    [mRequirements release];
    [mResult release];
    [super dealloc];
}

- (void)setRequirements:(NSCountedSet*)requirements{
    [requirements retain];
    [mRequirements release];
    mRequirements = requirements;
}

- (void)setResult:(NSCountedSet*)result{
    [result retain];
    [mResult release];
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
- (id)initFromKineticConstant:(KineticConstant*)k reactionComponents:(ReactionComponents*)components{
    self = [super init];
    if ( self != nil ){
        mKineticConstant = k;
        [mKineticConstant retain];

        mComponents = components;
        [mComponents retain];
    }
    return self;
}

- (void)dealloc{
    [mKineticConstant release];
    [mComponents release];
    [super dealloc];
}

- (KineticConstant*)kineticConstant{
    return mKineticConstant;
}

- (NSCountedSet*)requirements{
    return [mComponents requirements];
}

- (NSCountedSet*)result{
    return [mComponents result];
}
@end
