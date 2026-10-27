#import "HSLegacyCreationTool.h"

@implementation HSLegacyCreationTool

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [super didActivateExplicitly:aExplicitly];
    [self setupToolLayer];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    [self cleanupToolLayer];
}

- (void)cleanupToolLayer
{
    _toolLayerIsSetUp = NO;
    id root = [[self view] rootCanvasLayer];
    [root setEnabledSublayerIdentifiers:nil];
    [[root vectorToolsCanvasLayer] setTool:nil];
    [[root bitmapToolsCanvasLayer] setTool:nil];
}

- (void)setupToolLayer
{
    id root = [[self view] rootCanvasLayer];
    id layer = [self toolLayerNoVerify];
    [root setEnabledSublayerIdentifiers:[self worksInBitmapLayer] ? [root bitmapToolsIdentifiers] : [root vectorToolsIdentifiers]];
    [layer setTool:self];
    _toolLayerIsSetUp = YES;
}

- (id)toolLayer
{
    return [self toolLayerNoVerify];
}

- (id)toolLayerNoVerify
{
    id root = [[self view] rootCanvasLayer];
    return [self worksInBitmapLayer] ? [root bitmapToolsCanvasLayer] : [root vectorToolsCanvasLayer];
}

- (BOOL)worksInBitmapLayer
{
    return NO;
}

- (id)defaultToolCursorName
{
    return nil;
}

- (void)handleAutoscrollingWithMouseEvent:(id)aEvent
{
}

- (void)handleFlagsChanged:(id)aChanged
{
}

- (void)handleMouseUp:(id)aUp
{
}

- (void)handleMouseDragged:(id)aDragged
{
}

- (void)handleMouseDown:(id)aDown
{
}

- (void)mouseMoved:(id)aMoved
{
}

- (BOOL)wantsToSwitchToolInToolCanvasLayer:(id)aLayer event:(id)aEvent viewPoint:(NSPoint)aPoint newToolTag:(int *)aTag newTemplateIndex:(int *)aIndex skipToolApplying:(BOOL *)aApplying
{
    if (aApplying)
        *aApplying = NO;
    return NO;
}

- (id)cursorForToolCanvasLayer:(id)aLayer
{
    id name = [self defaultToolCursorName];
    return name ? [HSCursor cursorNamed:name] : nil;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector inToolCanvasLayer:(id)aLayer
{
    BOOL responds = [self respondsToSelector:aSelector];
    if (responds)
        [self performSelector:aSelector withObject:nil];
    return responds;
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint inToolCanvasLayer:(id)aLayer
{
    [self handleFlagsChanged:aChanged];
    return YES;
}

- (BOOL)handleMouseMoved:(id)aMoved inToolCanvasLayer:(id)aLayer
{
    [self mouseMoved:aMoved];
    return YES;
}

- (void)handleAutoscrollingWithMouseEvent:(id)aEvent whileTrackingInToolCanvasLayer:(id)aLayer
{
    [self handleAutoscrollingWithMouseEvent:aEvent];
}

- (BOOL)wantsAutoscrollingWhileTrackingInToolCanvasLayer:(id)aLayer
{
    return YES;
}

- (void)handleFlagsChanged:(id)aChanged whileTrackingInToolCanvasLayer:(id)aLayer
{
    [self handleFlagsChanged:aChanged];
}

- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer
{
    [self handleMouseUp:aUp];
}

- (void)handleMouseDragged:(id)aDragged whileTrackingInToolCanvasLayer:(id)aLayer
{
    [self handleMouseDragged:aDragged];
}

- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer
{
    [self handleMouseDown:aDown];
}

- (BOOL)wantsToTrackMouseInToolCanvasLayer:(id)aLayer
{
    return YES;
}

@end
