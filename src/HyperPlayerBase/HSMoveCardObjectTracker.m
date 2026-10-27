#import "HSMoveCardObjectTracker.h"
// The editor's layout guiding (snapping), not declared on this side.
@protocol HSMoveCardObjectTrackerLayoutGuiding
- (BOOL)isSnappingEnabled;
- (id)layoutGuidingProcessor;
- (BOOL)snapRect:(NSRect *)aRect edges:(NSUInteger)aEdges transformationDirectionHint:(NSPoint)aHint appliedRules:(id *)aRules;
- (id)filterSnapRules:(id)aRules madeForRect:(NSRect)aRect byMoveDirection:(NSPoint)aDirection;
- (void)setAppliedLayoutGuidingRules:(id)aRules forSnappingRect:(NSRect)aRect;
- (void)showAppliedLayoutGuidingRules;
@end

// Moves an object with the mouse: snapping to guides, kept horizontal,
// vertical or diagonal with Shift, an aligned copy left behind with
// Shift-Option (in the editor) and kept on the card in the player. The
// whole move is one undoable change.
@implementation HSMoveCardObjectTracker
- (void)setTrackingObject:(id)aObject
{
    NSUndoManager *undoManager = [[[self trackingObject] hyperObject] undoManager];
    id geometryAttributes = [self geometryAttributes];
    id applier = [self geometryApplier];
    [super setTrackingObject:aObject];
    if (undoManager != nil && ![undoManager isUndoRegistrationEnabled] && undoManager != [[[self trackingObject] hyperObject] undoManager]) {
        NSRect frame = [geometryAttributes frameBoundingRect];
        [applier moveFrameBoundingRectOriginTo:[self startOrigin] withLayoutGuidingContext:nil];
        [undoManager enableUndoRegistration];
        [applier moveFrameBoundingRectOriginTo:frame.origin withLayoutGuidingContext:nil];
    }
}
- (void)flagsChanged:(id)aChanged inView:(id)aView
{
    NSUInteger flags = [aChanged modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    BOOL shiftOption = flags == (NSEventModifierFlagShift | NSEventModifierFlagOption);
    _shiftModifierPresent = flags == NSEventModifierFlagShift || shiftOption;
    if (shiftOption && ![[[NSDocumentController sharedDocumentController] currentDocument] isInPlayerMode]) {
        _alignedCopyObject = [[[self trackingObject] localCopyIncludingNodeUnits:YES] autorelease];
        [[[_alignedCopyObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier]
            moveFrameBoundingRectOriginTo:[self startOrigin] withLayoutGuidingContext:nil];
        [[[self trackingObject] card] addHyperChild:_alignedCopyObject];
        [[[[NSDocumentController sharedDocumentController] currentDocument] cardView] selectNode:[self trackingObject]];
        return;
    }
    if (_alignedCopyObject != nil) {
        [[_alignedCopyObject card] removeHyperChild:_alignedCopyObject];
        _alignedCopyObject = nil;
    }
}
// Back to the start and then, recorded, to where it ended.
- (void)mouseUp:(id)aUp inView:(id)aView
{
    if (_didStartDragging) {
        [self mouseEvent:aUp inView:aView];
        [[[self geometryAttributes] attributeObservingController] endContinuousChangeOfAttributeSet:
            [NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    }
    [super mouseUp:aUp inView:aView];
    NSRect frame = [[self geometryAttributes] frameBoundingRect];
    if (!NSEqualPoints(frame.origin, [self startOrigin]))
        [[self geometryApplier] moveFrameBoundingRectOriginTo:[self startOrigin] withLayoutGuidingContext:nil];
    [[[[self trackingObject] hyperObject] undoManager] enableUndoRegistration];
    if (!NSEqualPoints(frame.origin, [self startOrigin]))
        [[self geometryApplier] moveFrameBoundingRectOriginTo:frame.origin withLayoutGuidingContext:nil];
}
- (void)mouseDown:(id)aDown inView:(id)aView
{
    [[[[self trackingObject] hyperObject] undoManager] disableUndoRegistration];
    [super mouseDown:aDown inView:aView];
}
- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    if (!_didStartDragging) {
        [[[self geometryAttributes] attributeObservingController] beginContinuousChangeOfAttributeSet:
            [NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
        _didStartDragging = YES;
    }
    [self mouseEvent:aDragged inView:aView];
}
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint startPoint = [self startPoint];
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    NSPoint startOrigin = [self startOrigin];
    NSPoint origin = NSMakePoint(startOrigin.x + (point.x - startPoint.x), startOrigin.y + (point.y - startPoint.y));
    [super mouseEvent:aEvent inView:aView];
    [self adjustOrigin:&origin];
    [self moveCardObjectOriginTo:origin];
    if ([self layoutGuidingContext] != nil)
        [(id<HSMoveCardObjectTrackerLayoutGuiding>)[self layoutGuidingContext] showAppliedLayoutGuidingRules];
}
- (void)moveCardObjectOriginTo:(NSPoint)aTo
{
    [[self geometryApplier] moveFrameBoundingRectOriginTo:aTo withLayoutGuidingContext:nil];
}
// Snapping (when the rules found survive filtering by the move's
// direction), then the Shift constraint (the axis moved less is kept at
// the start, unless the move is near diagonal, which is made exactly
// diagonal), then in the player at least a point of the object is kept on
// the card. YES when the origin changed.
- (BOOL)adjustOrigin:(NSPoint *)aOrigin
{
    BOOL adjusted = NO;
    id<HSMoveCardObjectTrackerLayoutGuiding> context = [self layoutGuidingContext];
    if (context != nil && [context isSnappingEnabled]) {
        NSRect original = { *aOrigin, [self currentBoundingRect].size };
        NSRect snapped = original;
        id rules = nil, filteredRules = nil;
        id guiding = [[self trackingObject] queryHyperInterface:@protocol(HSCardObjectLayoutGuidingInterface)];
        [guiding setHyperIgnoredInLayoutGuiding:YES];
        if ([[context layoutGuidingProcessor] snapRect:&snapped edges:0xf transformationDirectionHint:_moveDirection appliedRules:&rules]
            && !NSEqualPoints(original.origin, snapped.origin)) {
            filteredRules = [context filterSnapRules:rules madeForRect:original byMoveDirection:_moveDirection];
            if ([filteredRules count] != 0) {
                *aOrigin = snapped.origin;
                adjusted = YES;
            } else
                *aOrigin = original.origin;
        }
        [guiding setHyperIgnoredInLayoutGuiding:NO];
        [context setAppliedLayoutGuidingRules:filteredRules forSnappingRect:snapped];
    }
    if (_shiftModifierPresent) {
        NSPoint start = [self startOrigin];
        float dx = fabsf((float)(aOrigin->x - start.x));
        float dy = fabsf((float)(aOrigin->y - start.y));
        if (dx > 0.01f && dy > 0.01f && !(dy - 0.01f <= dx && dx <= dy + 0.01f)) {
            if (dy > dx) {
                if (dy * 0.5 > dx)
                    aOrigin->x = start.x;
                else
                    aOrigin->y = aOrigin->y > start.y ? start.y + dx : start.y - dx;
            } else {
                if (dx * 0.5 > dy)
                    aOrigin->y = start.y;
                else
                    aOrigin->x = aOrigin->x > start.x ? start.x + dy : start.x - dy;
            }
            adjusted = YES;
        }
    }
    id card = [[self trackingObject] card];
    if ([[card document] isInPlayerMode]) {
        id stack = [card stack];
        NSPoint origin = *aOrigin;
        NSSize size = [self currentBoundingRect].size;
        NSSize cardSize = stack != nil ? [stack hyperCardSize] : NSZeroSize;
        float minX = 0 - (size.width - 1.0f);
        float maxX = (size.width - 1.0f) * 2 + cardSize.width + minX;
        if (origin.x + size.width >= maxX)
            origin.x = maxX - size.width;
        if (minX >= origin.x)
            origin.x = minX;
        float minY = 0 - (size.height - 1.0f);
        float maxY = (size.height - 1.0f) * 2 + cardSize.height + minY;
        if (origin.y + size.height >= maxY)
            origin.y = maxY - size.height;
        if (minY >= origin.y)
            origin.y = minY;
        if (!NSEqualPoints(origin, *aOrigin)) {
            *aOrigin = origin;
            return YES;
        }
    }
    return adjusted;
}
@end
