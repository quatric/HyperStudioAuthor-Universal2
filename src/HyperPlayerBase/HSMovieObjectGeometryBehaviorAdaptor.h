#import "HyperPlayerBasePrefix.h"
#import "HSGenericGeometryBehaviorAdaptor.h"


@interface HSMovieObjectGeometryBehaviorAdaptor : HSGenericGeometryBehaviorAdaptor
{
}
- (NSSize)minSize;
- (id)initWithMovieObject:(id)aObject;
- (id)initWithHyperObject:(id)aObject;
@end

