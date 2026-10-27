#import "HSEditorCanvasHitTester.h"

@implementation HSEditorCanvasHitTester

- (BOOL)hitTestRect:(NSRect)aRect inItem:(id)aItem
{
    if (![self shouldHitTestCanvasItem:aItem])
        return NO;
    return [super hitTestRect:aRect inItem:aItem];
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem
{
    if (![self shouldHitTestCanvasItem:aItem])
        return NO;
    return [super hitTestPoint:aPoint inItem:aItem];
}

// Card objects hidden by the stack's visibility setting are skipped unless
// they are the current selection.
- (BOOL)shouldHitTestCanvasItem:(id)aItem
{
    id object = [aItem queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (object == nil)
        return YES;
    id support = [object queryHyperInterface:@protocol(HSUserObjectSupport)];
    if (support == nil)
        return YES;
    NSInteger visibility = [[support stack] cardObjectsVisibility];
    if ([[[[HSGlobalSelectionSync globalSelectionSync] currentSelectedObject] allHyperInterfaces] containsObject:object])
        return YES;
    if (visibility == 1 || (visibility == 2 && [object isHiddenInPlayer]))
        return NO;
    return YES;
}

@end
