#import "HyperPlayerBasePrefix.h"
#import "HSGenericGeometryBehaviorAdaptor.h"


@interface HSTextObjectGeometryBehaviorAdaptor : HSGenericGeometryBehaviorAdaptor
{
}
- (NSSize)adaptResizingUnproportionallyTo:(NSSize)aTo canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (NSSize)adaptResizingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext;
- (NSSize)HSTextObjectGeometryBehaviorAdaptor_adaptResizingTo:(NSSize)aTo withPreadaptedSize:(NSSize)aSize layoutGuidingContext:(id)aContext;
- (id)initWithTextObject:(id)aObject;
- (id)initWithHyperObject:(id)aObject;
@end

