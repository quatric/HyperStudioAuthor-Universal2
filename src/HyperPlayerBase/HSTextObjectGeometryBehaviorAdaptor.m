#import "HSTextObjectGeometryBehaviorAdaptor.h"
@implementation HSTextObjectGeometryBehaviorAdaptor
- (NSSize)adaptResizingUnproportionallyTo:(NSSize)aTo canResizeHorizontally:(BOOL)aHorizontally canResizeVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext
{
    NSSize size = [super adaptResizingUnproportionallyTo:aTo canResizeHorizontally:aHorizontally canResizeVertically:aVertically withLayoutGuidingContext:aContext];
    return [self HSTextObjectGeometryBehaviorAdaptor_adaptResizingTo:aTo withPreadaptedSize:size layoutGuidingContext:aContext];
}
- (NSSize)adaptResizingProportionallyTo:(NSSize)aTo withLayoutGuidingContext:(id)aContext
{
    NSSize size = [super adaptResizingProportionallyTo:aTo withLayoutGuidingContext:aContext];
    return [self HSTextObjectGeometryBehaviorAdaptor_adaptResizingTo:aTo withPreadaptedSize:size layoutGuidingContext:aContext];
}
// A fixed-size text object (not autosizing, height not set by the user)
// grows to fit its text at the new width (at least its minimum width).
- (NSSize)HSTextObjectGeometryBehaviorAdaptor_adaptResizingTo:(NSSize)aTo withPreadaptedSize:(NSSize)aSize layoutGuidingContext:(id)aContext
{
    float containerWidth = [HSTextObject widthOfTextContainerForTextObjectWithSize:aTo];
    float minWidth = NSSizeFromString([_hyperObject hyperSizeMinValue]).width;
    if ([[_hyperObject nodeData] isAutosizing])
        return aSize;
    float width = MAX(minWidth, containerWidth);
    if ([[_hyperObject nodeData] heightSetByUser])
        return aSize;
    NSSize textSize = [HSCoreText hyperSizeForText:[_hyperObject text] withWidth:width fixedWidth:YES];
    return NSMakeSize(textSize.width, aSize.height > textSize.height ? aSize.height : textSize.height);
}
- (id)initWithTextObject:(id)aObject
{
    return [super initWithHyperObject:aObject];
}
- (id)initWithHyperObject:(id)aObject
{
    if (![aObject isKindOfClass:[HSTextObject class]]) {
        [self release];
        return nil;
    }
    return [self initWithTextObject:aObject];
}
@end
