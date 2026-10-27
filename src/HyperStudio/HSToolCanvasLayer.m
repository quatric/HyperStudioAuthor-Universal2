#import "HSToolCanvasLayer.h"

@implementation HSToolCanvasLayer

- (BOOL)trackingLoop:(id)aLoop shouldAutoscrollWithMouseEvent:(id)aEvent
{
    return [_tool wantsAutoscrollingWhileTrackingInToolCanvasLayer:self];
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
    [_tool handleFlagsChanged:aChanged whileTrackingInToolCanvasLayer:self];
}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    [_tool handleMouseUp:aUp whileTrackingInToolCanvasLayer:self];
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    [_tool handleMouseDragged:aDragged whileTrackingInToolCanvasLayer:self];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    [_tool handleMouseDown:aDown whileTrackingInToolCanvasLayer:self];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (_tool == nil || _tool != aInfo)
        return [super cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
    return [_tool cursorForToolCanvasLayer:self];
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (_tool == nil)
        return NO;
    return [_tool handleKeyEventSelector:aSelector inToolCanvasLayer:self];
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    if (_tool == nil)
        return NO;
    return [_tool handleFlagsChanged:aChanged atPoint:aPoint inToolCanvasLayer:self];
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    if (_tool == nil)
        return NO;
    return [_tool handleMouseMoved:aEvent inToolCanvasLayer:self];
}

// A tool may hand the click to another tool (switching to it) before tracking starts.
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if (_tool == nil || _tool != aInfo)
        return [super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
    if (![_tool wantsToTrackMouseInToolCanvasLayer:self])
        return NO;
    int toolTag = 0;
    int templateIndex = -1;
    BOOL skipToolApplying = NO;
    if ([_tool wantsToSwitchToolInToolCanvasLayer:self event:aEvent viewPoint:aPoint newToolTag:&toolTag newTemplateIndex:&templateIndex skipToolApplying:&skipToolApplying]) {
        HSToolManager *manager = [HSToolManager sharedToolManager];
        [manager selectToolWithTag:toolTag setAsPermanent:YES forceSelection:YES];
        id newTool = [manager currentTool];
        if (templateIndex != -1) {
            [[manager toolSettings] applySettingsForTool:newTool templateIndex:templateIndex];
            [[[HSToolPaletteController sharedInstance] activeToolSettingsViewController] updateUI];
        }
        if (!skipToolApplying)
            return [(id<HSCanvasRootLayer>)[[newTool view] rootCanvasLayer] handleMouseDown:aEvent];
    }
    if (skipToolApplying) {
        NSBeep();
        return YES;
    }
    id loop;
    if ([_tool wantsAutoscrollingWhileTrackingInToolCanvasLayer:self])
        loop = [HSTrackingLoop autoscrollingTrackingLoopWithView:[self renderingView] client:self];
    else
        loop = [HSTrackingLoop trackingLoopWithView:[self renderingView] client:self];
    [loop runWithMouseDownEvent:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    id layer = [super hitTestCanvasLayerAtPoint:aPoint insideView:aView clickCount:aCount modifierFlags:aFlags hitTestInfo:aInfo];
    if (layer == nil && aView && [_tool wantsToTrackMouseInToolCanvasLayer:self]) {
        *aInfo = _tool;
        layer = self;
    }
    return layer;
}

- (void)setTool:(id)aTool
{
    _tool = aTool;
}

- (id)tool
{
    return _tool;
}

@end
