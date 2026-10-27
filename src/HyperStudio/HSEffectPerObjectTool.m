#import "HSEffectPerObjectTool.h"

@implementation HSEffectPerObjectTool

- (void)applyEffect:(id)aEffect centerPoint:(NSPoint)aPoint isNewCenterNearPrevious:(BOOL)aPrevious
{
    id attributes = [aEffect queryHyperInterface:@protocol(HSEffectMutableAttributes)];
    id effectName, category, settings, newSettings;
    NSPoint center;
    BOOL hasNoCenter;

    if (attributes == nil)
        return;
    effectName = [self effectName];
    category = [[self effect] category];
    settings = [attributes effectSettings];
    center = [[HSEffectSettings sharedSettings] centerPointForSettings:settings category:category];
    hasNoCenter = center.x >= INFINITY || center.y >= INFINITY;
    if (![effectName isEqual:[attributes hyperEffectName]] || (!hasNoCenter && !aPrevious))
        newSettings = [self defaultEffectSettings:aPoint intencity:[self effectIntencity]];
    else
        newSettings = [[HSEffectSettings sharedSettings] adjustedSettings:settings forName:effectName category:category additionalIntencity:0.25];
    [attributes setHyperEffectName:effectName settings:newSettings];
}

- (id)defaultEffectSettings:(NSPoint)aSettings intencity:(CGFloat)aIntencity
{
    return [[HSEffectSettings sharedSettings] defaultSettingsForName:[self effectName] category:[[self effect] category] center:aSettings intencity:aIntencity identifier:@"HSEffectPerObjectTool"];
}

- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer
{
    id hitTester = [[[aLayer context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)];
    NSPoint viewPoint = [[self view] convertPoint:[aUp locationInWindow] fromView:nil];
    id node = [hitTester hitTestNodeAtPoint:viewPoint];

    if (_mouseDownObject != nil && _mouseDownObject == node) {
        if ([_mouseDownObject supportsEffectPerObject] && ![[_mouseDownObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            NSPoint userPoint = [[self view] convertPointFromViewSpaceToUserSpace:viewPoint];
            id geometry = [node queryHyperInterface:@protocol(HSGeometryAttributes)];
            // CGAffineTransformInvert returns the transform unchanged when it is singular, like the original.
            CGAffineTransform inverse = CGAffineTransformInvert([geometry affineTransform]);
            NSSize frameSize = [geometry affineFrameSize];
            NSRect nearRect = NSOffsetRect(NSMakeRect(_lastClickedCenter.x, _lastClickedCenter.y, 3.0, 3.0), -1.0, -1.0);
            BOOL isNear = NSPointInRect(userPoint, nearRect);
            NSPoint objectPoint = CGPointApplyAffineTransform(userPoint, inverse);

            [self applyEffect:_mouseDownObject centerPoint:NSMakePoint(objectPoint.x / frameSize.width * 100.0, objectPoint.y / frameSize.height * 100.0) isNewCenterNearPrevious:isNear];
            _lastClickedCenter = userPoint;
        }
        else
            NSBeep();
    }
    _mouseDownObject = nil;
}

- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer
{
    id hitTester = [[[aLayer context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)];

    _mouseDownObject = [hitTester hitTestNodeAtPoint:[[self view] convertPoint:[aDown locationInWindow] fromView:nil]];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer = [[self view] rootCanvasLayer];
    id vectorToolsLayer = [rootLayer vectorToolsCanvasLayer];

    if (_dragCardCanvasLayer == nil)
        _dragCardCanvasLayer = [HSDragCardViewCanvasLayer new];
    if (_dragCardCanvasLayer != nil)
        [vectorToolsLayer addSublayer:_dragCardCanvasLayer];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
    [vectorToolsLayer setTool:self];
}

@end
