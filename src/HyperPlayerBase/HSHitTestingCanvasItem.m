#import "HSHitTestingCanvasItem.h"
// A canvas item that draws nothing and only hit tests, by its hit tester
// (the hyper object it was made with): points by the hit tester, rects by
// its editor hit testing. Without a rendering view everything hits.
@implementation HSHitTestingCanvasItem
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [HSRegion region];
}
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return NSZeroRect;
}
- (BOOL)prefersRegionInvalidation
{
    return NO;
}
- (BOOL)hitTestRect:(NSRect)aRect inCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (view == nil)
        return YES;
    return [[self editorHitTester] hitTestUserRect:[view userBoundingRectForViewRect:aRect]];
}
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (view == nil)
        return YES;
    return [[self hitTester] hitTestUserPoint:[view convertPointFromViewSpaceToUserSpace:aPoint]];
}
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
}
- (id)editorHitTester
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSUserObjectEditorHitTesting)];
}
- (id)hitTester
{
    return [self hyperObject];
}
// Needs a hit tester. (The original returns nil without releasing.)
- (id)initWithHyperObject:(id)aObject
{
    [self release];
    return nil;
}
- (id)initWithHitTester:(id)aTester
{
    return [super initWithHyperObject:aTester];
}
@end
