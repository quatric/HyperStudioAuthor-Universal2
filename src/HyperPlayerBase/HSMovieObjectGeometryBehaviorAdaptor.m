#import "HSMovieObjectGeometryBehaviorAdaptor.h"
@implementation HSMovieObjectGeometryBehaviorAdaptor
- (NSSize)minSize
{
    // a movie with a controller is at least as wide as the controller
    CGFloat width = 10;
    if ([_hyperObject hasController])
        width = [[_hyperObject movieWithController] minControllerSize].width;
    return NSMakeSize(width, 10);
}
- (id)initWithMovieObject:(id)aObject
{
    return [super initWithHyperObject:aObject];
}
- (id)initWithHyperObject:(id)aObject
{
    if (![aObject isKindOfClass:[HSMovieObject class]]) {
        [self release];
        return nil;
    }
    return [self initWithMovieObject:aObject];
}
@end
