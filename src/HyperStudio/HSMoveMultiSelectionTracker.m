#import "HSMoveMultiSelectionTracker.h"

// The editor's layout guiding (snapping), not declared on the tracker side.
@protocol HSMoveMultiSelectionTrackerLayoutGuiding
- (BOOL)isSnappingEnabled;
- (id)layoutGuidingProcessor;
- (id)filterSnapRules:(id)aRules madeForRect:(NSRect)aRect byMoveDirection:(NSPoint)aDirection;
- (void)setAppliedLayoutGuidingRules:(id)aRules forSnappingRect:(NSRect)aRect;
- (id)appliedLayoutGuidingRules;
- (void)cancelAppliedLayoutGuidingRulesClearing;
- (void)showAppliedLayoutGuidingRules;
@end

@implementation HSMoveMultiSelectionTracker

- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    _didStartDragging = YES;
    [self moveEvent:aDragged inView:aView];
}

- (void)mouseUp:(id)aUp inView:(id)aView
{
    if (_didStartDragging)
        [self moveEvent:aUp inView:aView];
    [super mouseUp:aUp inView:aView];
    [self concludeTracking];
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
    [self prepareForTracking];
}

- (void)concludeTracking
{
    NSEnumerator *enumerator = [_geometryAppliers objectEnumerator];
    id attributes = [[enumerator nextObject] mutableGeometryAttributes];
    id controller;
    while ((controller = [attributes attributeObservingController]) != nil) {
        [controller endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
        attributes = [[enumerator nextObject] mutableGeometryAttributes];
    }
    [_startTransforms release];
    _startTransforms = nil;
}

// Records each object's transform and the union of their frames before the move.
- (void)prepareForTracking
{
    _startTransforms = [[NSMutableArray alloc] initWithCapacity:[_geometryAppliers count]];
    NSEnumerator *enumerator = [_geometryAppliers objectEnumerator];
    _currentSelectionBoundingRect = NSZeroRect;
    id attributes = [[enumerator nextObject] mutableGeometryAttributes];
    while (attributes != nil) {
        [_startTransforms addObject:[NSAffineTransform transformWithHyperCGAffineTransform:[attributes affineTransform]]];
        _startSelectionBoundingRect = NSUnionRect(_startSelectionBoundingRect, [attributes frameBoundingRect]);
        [[attributes attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
        attributes = [[enumerator nextObject] mutableGeometryAttributes];
    }
    _currentSelectionBoundingRect = _startSelectionBoundingRect;
}

- (void)moveEvent:(id)aEvent inView:(id)aView
{
    NSPoint startPoint = [self startPoint];
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    [self mouseEvent:aEvent inView:aView];
    [self moveObjectsByUserDelta:NSMakeSize(point.x - startPoint.x, point.y - startPoint.y) withKeyboard:NO];
}

// With the keyboard the delta is used as given and only the guides the moved rect still lies on are kept.
- (void)moveObjectsByUserDelta:(NSSize)aDelta withKeyboard:(BOOL)aKeyboard
{
    NSSize delta = aDelta;
    NSRect movedRect = NSOffsetRect(_startSelectionBoundingRect, aDelta.width, aDelta.height);
    [self adjustDelta:&delta keyboardUsed:aKeyboard];
    if (aKeyboard) {
        [[self layoutGuidingContext] cancelAppliedLayoutGuidingRulesClearing];
        delta = aDelta;
        NSArray *rules = [[self layoutGuidingContext] appliedLayoutGuidingRules];
        NSMutableArray *keptRules = [NSMutableArray array];
        NSEnumerator *enumerator = [rules objectEnumerator];
        id rule;
        while ((rule = [enumerator nextObject]) != nil) {
            if ([rule ruleType] != 0) {
                float value;
                switch ([rule rectSide]) {
                case 0: value = movedRect.origin.x; break;
                case 1: value = movedRect.origin.y; break;
                case 2: value = movedRect.origin.x + movedRect.size.width; break;
                case 3: value = movedRect.origin.y + movedRect.size.height; break;
                case 4: value = movedRect.size.width * 0.5f + movedRect.origin.x; break;
                case 5: value = movedRect.size.height * 0.5f + movedRect.origin.y; break;
                case 6: value = movedRect.size.width; break;
                case 7: value = movedRect.size.height; break;
                default: value = 0.0f; break;
                }
                if (fabsf((float)[rule layoutRuleFloatValue] - value) > 0.5f)
                    continue;
            }
            [keptRules addObject:rule];
        }
        [[self layoutGuidingContext] setAppliedLayoutGuidingRules:keptRules forSnappingRect:NSZeroRect];
    }
    NSEnumerator *appliers = [_geometryAppliers objectEnumerator];
    NSEnumerator *transforms = [_startTransforms objectEnumerator];
    _currentSelectionBoundingRect = NSZeroRect;
    id applier;
    while ((applier = [appliers nextObject]) != nil) {
        id startTransform = [transforms nextObject];
        id attributes = [applier mutableGeometryAttributes];
        CGAffineTransform start = [startTransform hyperCGAffineTransform];
        CGAffineTransform current = [attributes affineTransform];
        [applier moveBy:NSMakeSize((start.tx + delta.width) - current.tx, (start.ty + delta.height) - current.ty) withLayoutGuidingContext:nil];
        _currentSelectionBoundingRect = NSUnionRect(_currentSelectionBoundingRect, [attributes frameBoundingRect]);
    }
    if ([self layoutGuidingContext] != nil)
        [[self layoutGuidingContext] showAppliedLayoutGuidingRules];
}

// Snaps the moved selection rect; YES when the delta was changed.
- (BOOL)adjustDelta:(NSSize *)aDelta keyboardUsed:(BOOL)aUsed
{
    id<HSMoveMultiSelectionTrackerLayoutGuiding> context = [self layoutGuidingContext];
    if (context == nil || ![context isSnappingEnabled])
        return NO;
    NSSize delta = *aDelta;
    NSRect original = NSOffsetRect(_startSelectionBoundingRect, delta.width, delta.height);
    NSRect snapped = original;
    id rules = nil;
    id filteredRules;
    BOOL adjusted;
    id guiding = [[self trackingObject] queryHyperInterface:@protocol(HSCardObjectLayoutGuidingInterface)];
    [guiding setHyperIgnoredInLayoutGuiding:YES];
    if (![[context layoutGuidingProcessor] snapRect:&snapped edges:0xf transformationDirectionHint:NSZeroSize appliedRules:&rules]
        || NSEqualPoints(snapped.origin, original.origin)) {
        filteredRules = nil;
        adjusted = NO;
    } else {
        filteredRules = [context filterSnapRules:rules madeForRect:original byMoveDirection:_moveDirection];
        if ([filteredRules count] == 0 && !aUsed) {
            adjusted = NO;
        } else {
            delta.height += snapped.origin.y - original.origin.y;
            delta.width += snapped.origin.x - original.origin.x;
            adjusted = YES;
        }
        *aDelta = delta;
    }
    [guiding setHyperIgnoredInLayoutGuiding:NO];
    [[self layoutGuidingContext] setAppliedLayoutGuidingRules:aUsed ? rules : filteredRules forSnappingRect:snapped];
    return adjusted;
}

- (NSRect)currentBoundingRect
{
    return _currentSelectionBoundingRect;
}

- (void)setTrackingObject:(id)aObject
{
    [super setTrackingObject:aObject];
    [self setTrackingObjects:[[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] allHyperInterfaces]];
}

- (void)setTrackingObjects:(id)aObjects
{
    [_trackingObjects autorelease];
    _trackingObjects = [aObjects retain];
    [_geometryAppliers release];
    _geometryAppliers = [[NSMutableArray alloc] initWithCapacity:[_trackingObjects count]];
    NSEnumerator *enumerator = [_trackingObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [_geometryAppliers addObject:object];
}

- (void)dealloc
{
    [_startTransforms release];
    [_geometryAppliers release];
    [_trackingObjects release];
    [super dealloc];
}

@end
