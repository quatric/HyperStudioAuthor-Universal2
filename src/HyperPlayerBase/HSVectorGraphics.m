#import "HSVectorGraphics.h"
#import "EXCodingContext.h"
#import "HSGeometryBehaviorApplier.h"
#import "HSVectorGraphicsLineDashInfoObjectProvider.h"
#import "NSAffineTransform+HSKeyValueCoding.h"
#import "NSBezierPath+HSBinarySerialization.h"
#import "NSMutableArray+EXMutableArray.h"

static BOOL HSVectorGraphicsFloatsAreEqual(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

static BOOL HSVectorGraphicsSizesAreEqual(NSSize aSize1, NSSize aSize2)
{
    return HSVectorGraphicsFloatsAreEqual(aSize1.width, aSize2.width) && HSVectorGraphicsFloatsAreEqual(aSize1.height, aSize2.height);
}

// The ratio of a new length to an old one, 1 for an old length near zero.
static float HSVectorGraphicsScale(float aNewLength, float aOldLength)
{
    float magnitude = aOldLength != 0.0f ? fabsf(aOldLength) : 1.0f;
    float tolerance = magnitude >= 1.0f ? magnitude * 0.0005f : 0.0005f;
    return fabsf(aOldLength) > tolerance ? aNewLength / aOldLength : 1.0f;
}

// The element points of the attributes are in the object's space, the path's
// in the canonized space the object's affine transform maps from.
@implementation HSVectorGraphics

// The named line dash infos are stored by name.
+ (id)serializationKeyForLineDashInfo:(id)aInfo serializedValue:(id *)aValue
{
    NSString *key = @"lineDashInfoKey";
    id value = aInfo;
    if (aInfo) {
        id name = [[[[aInfo class] sharedProvider] namedObjects] allKeysForObject:aInfo];
        name = [name extraFirstObject];
        if (name)
            value = name;
        else
            key = @"lineDashInfo";
    }
    if (aValue)
        *aValue = value;
    return key;
}

// As in the original, the copy shares the path.
- (id)copyWithZone:(NSZone *)aZone
{
    HSVectorGraphics *copy = [[[self class] allocWithZone:aZone] init];
    [copy setBezierPath:[self bezierPath]];
    [copy setCanonizingTransform:[self canonizingTransform]];
    [copy setLineDashInfo:_lineDashInfo];
    [copy setStrokeColor:_strokeColor];
    return copy;
}

- (id)attributeObservingController
{
    return [[self hyperObject] attributeObservingController];
}

- (void)HSVectorGraphics_setUndoActionName:(NSString *)aName
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:aName value:@"" table:@"UndoManager"]];
}

- (void)HSVectorGraphics_notifyChange:(NSInteger)aChange ofAttribute:(Protocol *)aAttribute
{
    [(id)[self hyperObject] notifyChange:aChange ofAttribute:aAttribute withUserInfo:nil];
}

- (void)setHyperStrokeColor:(id)aColor
{
    if ([[self hyperStrokeColor] isEqual:aColor])
        return;
    [self HSVectorGraphics_setUndoActionName:@"Set Stroke Color"];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperStrokeColor:[self hyperStrokeColor]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsStrokeColorAttribute)];
    [self setStrokeColor:aColor];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsStrokeColorAttribute)];
}

- (void)setExtraLineDashInfo:(id)aInfo
{
    if ([_lineDashInfo isEqual:aInfo])
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Line Dash"];
    [[[self undoManager] prepareWithInvocationTarget:self] setExtraLineDashInfo:[self hyperLineDashInfo]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineDashInfoAttribute)];
    [self setLineDashInfo:aInfo];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineDashInfoAttribute)];
}

- (void)setHyperFlatness:(CGFloat)aFlatness
{
    if (HSVectorGraphicsFloatsAreEqual([self hyperFlatness], aFlatness))
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Flatness"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperFlatness:[self hyperFlatness]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsFlatnessAttribute)];
    [self setFlatness:aFlatness];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsFlatnessAttribute)];
}

- (void)setHyperMiterLimit:(CGFloat)aLimit
{
    if (HSVectorGraphicsFloatsAreEqual([self hyperMiterLimit], aLimit))
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Miter Limit"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperMiterLimit:[self hyperMiterLimit]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsMiterLimitAttribute)];
    [self setMiterLimit:aLimit];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsMiterLimitAttribute)];
}

- (void)setHyperWindingRule:(NSUInteger)aRule
{
    if ([self hyperWindingRule] == aRule)
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Winding Rule"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperWindingRule:[self hyperWindingRule]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsWindingRuleAttribute)];
    [self setWindingRule:aRule];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsWindingRuleAttribute)];
}

// Sets the join style, and the cap style to match (round for a miter join).
- (void)setHyperLineSmoothStyle:(NSInteger)aStyle
{
    NSUInteger capStyle = aStyle ? (NSUInteger)aStyle : 2;
    if ([self hyperLineCapStyle] == capStyle && [self hyperLineJoinStyle] == (NSUInteger)aStyle)
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Line Smooth Style"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperLineSmoothStyle:[self hyperLineJoinStyle]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineCapStyleAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineJoinStyleAttribute)];
    [self setLineCapStyle:capStyle];
    [self setLineJoinStyle:aStyle];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineCapStyleAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineJoinStyleAttribute)];
}

- (void)setHyperLineJoinStyle:(NSUInteger)aStyle
{
    if ([self hyperLineJoinStyle] == aStyle)
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Line Join Style"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperLineJoinStyle:[self hyperLineJoinStyle]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineJoinStyleAttribute)];
    [self setLineJoinStyle:aStyle];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineJoinStyleAttribute)];
}

// As in the original, undone through setHyperLineSmoothStyle:.
- (void)setHyperLineCapStyle:(NSUInteger)aStyle
{
    if ([self hyperLineCapStyle] == aStyle)
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Line Cap Style"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperLineSmoothStyle:[self hyperLineCapStyle]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineCapStyleAttribute)];
    [self setLineCapStyle:aStyle];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineCapStyleAttribute)];
}

- (void)setHyperLineWidth:(CGFloat)aWidth
{
    if (HSVectorGraphicsFloatsAreEqual([self hyperLineWidth], aWidth))
        return;
    [self HSVectorGraphics_setUndoActionName:@"Change Line Width"];
    [(HSVectorGraphics *)[[self undoManager] prepareWithInvocationTarget:self] setHyperLineWidth:[self hyperLineWidth]];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineWidthAttribute)];
    [self setLineWidth:aWidth];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineWidthAttribute)];
}

- (void)appendHyperVectorGraphicsObject:(id)aObject
{
}

- (void)deleteHyperElementAtIndex:(NSUInteger)aIndex glueWithEditingMode:(NSInteger)aMode
{
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    NSUInteger element = [self hyperElementAtIndex:aIndex associatedPoints:points];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_setUndoActionName:@"Delete Element"];
    [[[self undoManager] prepareWithInvocationTarget:self] _insertHyperElement:element point:points[0] controlPoint1:points[1] controlPoint2:points[2] atIndex:aIndex];
    [self deleteElementAtIndex:aIndex glueWithEditingMode:aMode];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

- (void)insertHyperPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode
{
    [self HSVectorGraphics_setUndoActionName:@"Insert Element"];
    [[[self undoManager] prepareWithInvocationTarget:self] deleteHyperElementAtIndex:aIndex glueWithEditingMode:aMode];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self insertPoint:aPoint atIndex:aIndex editingMode:aMode];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

- (void)insertHyperElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints atIndex:(NSUInteger)aIndex
{
    [self HSVectorGraphics_setUndoActionName:@"Insert Element"];
    [[[self undoManager] prepareWithInvocationTarget:self] deleteHyperElementAtIndex:aIndex glueWithEditingMode:0];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self insertElement:aElement associatedPoints:aPoints atIndex:aIndex];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

// As in the original, the insertion renames the undo action.
- (void)appendHyperElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints
{
    [self HSVectorGraphics_setUndoActionName:@"Append Element"];
    [self insertHyperElement:aElement associatedPoints:aPoints atIndex:[self hyperElementCount]];
}

- (void)setHyperPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode
{
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    [self hyperElementAtIndex:aIndex associatedPoints:points];
    if (NSEqualPoints(points[0], aPoint))
        return;
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_setUndoActionName:@"Change Control Point Position"];
    [[[self undoManager] prepareWithInvocationTarget:self] _setHyperElementAtIndex:aIndex point:points[0] controlPoint1:points[1] controlPoint2:points[2]];
    [self setPoint:aPoint atIndex:aIndex editingMode:aMode];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

// Only the point of a move or line counts, all three of a curve.
- (void)setHyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints
{
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    NSUInteger element = [self hyperElementAtIndex:aIndex associatedPoints:points];
    BOOL equal = NSEqualPoints(points[0], aPoints[0]);
    if (equal && element == NSCurveToBezierPathElement)
        equal = NSEqualPoints(points[1], aPoints[1]) && NSEqualPoints(points[2], aPoints[2]);
    if (equal)
        return;
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_setUndoActionName:@"Change Control Point Position"];
    [[[self undoManager] prepareWithInvocationTarget:self] _setHyperElementAtIndex:aIndex point:points[0] controlPoint1:points[1] controlPoint2:points[2]];
    [self setElementAtIndex:aIndex associatedPoints:aPoints];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsElementsAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

// Appends the path, given in the object's space, and recanonizes. Not undoable.
- (void)appendHyperBezierPath:(id)aPath
{
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), @protocol(HSVectorGraphicsBezierPathAttribute), nil];
    [(id)[self hyperObject] notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    if (![self isHyperEmpty])
        [aPath hyperCopyVisualAttributesFrom:[self hyperBezierPath]];
    CGAffineTransform transform = [(id)[[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
    [[self bezierPath] transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:transform]];
    [[self bezierPath] appendBezierPath:aPath];
    NSAffineTransform *applied = [NSAffineTransform transform];
    [[self bezierPath] extraCanonizeWithScaling:NO appliedTransform:applied];
    [applied invert];
    [[self undoManager] disableUndoRegistration];
    [(HSGeometryBehaviorApplier *)[[[self hyperObject] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setAffineTransform:[applied hyperCGAffineTransform] withLayoutGuidingContext:nil];
    [[self undoManager] enableUndoRegistration];
    [(id)[self hyperObject] notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (void)setHyperBezierPath:(id)aPath dynamicStrokeWidthAdjustmentFactor:(NSUInteger)aFactor
{
    [self setHyperBezierPath:aPath dynamicStrokeWidthAdjustmentFactor:aFactor resetTransform:NO];
}

- (void)setHyperBezierPath:(id)aPath dynamicStrokeWidthAdjustmentFactor:(NSUInteger)aFactor resetTransform:(BOOL)aTransform
{
    if ([self hyperBezierPath] == aPath)
        return;
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute)];
    [self HSVectorGraphics_notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsBezierPathAttribute)];
    [self HSVectorGraphics_setUndoActionName:@"Change Vector Path"];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperBezierPath:[self hyperBezierPath] dynamicStrokeWidthAdjustmentFactor:_dynamicStrokeWidthAdjustmentFactor];
    if (![self isHyperEmpty])
        [aPath hyperCopyVisualAttributesFrom:[self hyperBezierPath]];
    _dynamicStrokeWidthAdjustmentFactor = (unsigned int)aFactor;
    [self setBezierPath:aPath resetTransform:aTransform];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsBezierPathAttribute)];
    [self HSVectorGraphics_notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute)];
}

- (void)setHyperBezierPath:(id)aPath
{
    [self setHyperBezierPath:aPath dynamicStrokeWidthAdjustmentFactor:2];
}

- (NSUInteger)hyperDynamicStrokeWidthAdjustmentFactor
{
    return [self dynamicStrokeWidthAdjustmentFactor];
}

- (id)hyperStrokeColor
{
    return _strokeColor;
}

- (id)hyperLineDashInfo
{
    return _lineDashInfo;
}

- (CGFloat)hyperFlatness
{
    return [_path flatness];
}

- (CGFloat)hyperMiterLimit
{
    return [_path miterLimit];
}

- (NSUInteger)hyperWindingRule
{
    return [_path windingRule];
}

- (NSUInteger)hyperLineJoinStyle
{
    return [_path lineJoinStyle];
}

- (NSUInteger)hyperLineCapStyle
{
    return [_path lineCapStyle];
}

- (CGFloat)hyperLineWidth
{
    return [_path lineWidth];
}

// In the object's space; NSUIntegerMax for no index.
- (NSUInteger)hyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints
{
    if (aIndex == NSUIntegerMax || aIndex == NSNotFound)
        return NSUIntegerMax;
    NSUInteger element = [_path hyperElementAtIndex:aIndex associatedPoints:aPoints];
    if (!aPoints)
        return element;
    CGAffineTransform affineTransform = [(id)[[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:affineTransform];
    if (element < NSCurveToBezierPathElement)
        aPoints[0] = [transform transformPoint:aPoints[0]];
    if (element == NSCurveToBezierPathElement) {
        aPoints[0] = [transform transformPoint:aPoints[0]];
        aPoints[1] = [transform transformPoint:aPoints[1]];
        aPoints[2] = [transform transformPoint:aPoints[2]];
    }
    return element;
}

- (id)hyperBezierPath
{
    return _path;
}

- (NSUInteger)hyperElementCount
{
    return [_path elementCount];
}

- (BOOL)isHyperShape
{
    return _path && [_path isHyperLastContourClosed];
}

- (BOOL)isHyperEmpty
{
    return !_path || [_path isHyperEmpty];
}

- (void)_insertHyperElement:(NSUInteger)aElement point:(NSPoint)aPoint controlPoint1:(NSPoint)aPoint1 controlPoint2:(NSPoint)aPoint2 atIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = {aPoint, aPoint1, aPoint2};
    [self insertHyperElement:aElement associatedPoints:points atIndex:aIndex];
}

- (void)_setHyperElementAtIndex:(NSUInteger)aIndex point:(NSPoint)aPoint controlPoint1:(NSPoint)aPoint1 controlPoint2:(NSPoint)aPoint2
{
    NSPoint points[3] = {aPoint, aPoint1, aPoint2};
    [self setHyperElementAtIndex:aIndex associatedPoints:points];
}

- (NSUInteger)dynamicStrokeWidthAdjustmentFactor
{
    return _dynamicStrokeWidthAdjustmentFactor;
}

- (void)setDynamicStrokeWidthAdjustmentFactor:(NSUInteger)aFactor
{
    _dynamicStrokeWidthAdjustmentFactor = (unsigned int)aFactor;
}

// Mode 0 makes the lines and curves of the range lines; otherwise each becomes
// a curve smoothly joined with the next element (the first one, past the
// closing line of a closed shape).
- (void)applyEditingMode:(NSInteger)aMode toElementsInRange:(NSRange)aRange
{
    NSUInteger count = [_path elementCount];
    NSUInteger end = MIN(NSMaxRange(aRange), count);
    for (NSUInteger index = aRange.location; index < end; index++) {
        NSBezierPathElement element = [_path elementAtIndex:index];
        if (element == NSMoveToBezierPathElement || element == NSClosePathBezierPathElement)
            continue;
        if (aMode == 0) {
            [self setElementType:NSLineToBezierPathElement atIndex:index];
            continue;
        }
        NSUInteger next = index;
        if (count >= 3 && count - 3 == index && [_path elementAtIndex:count - 2] == NSClosePathBezierPathElement)
            next = 0;
        next++;
        if (next >= count)
            continue;
        NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
        NSPoint threePoints[3];
        threePoints[0] = [_path hyperBasePointOfElementAtIndex:index - 1];
        threePoints[1] = [_path hyperBasePointOfElementAtIndex:next];
        threePoints[2] = [_path hyperBasePointOfElementAtIndex:index];
        NSPoint tangent1 = NSZeroPoint, tangent2 = NSZeroPoint;
        [self tangentPoint1:&tangent1 point2:&tangent2 forThreePoints:threePoints];
        [self setElementType:NSCurveToBezierPathElement atIndex:index];
        [_path hyperElementAtIndex:index associatedPoints:points];
        points[2] = tangent1;
        [_path setHyperAssociatedPoints:points atIndex:index];
        [self setElementType:NSCurveToBezierPathElement atIndex:next];
        [_path hyperElementAtIndex:next associatedPoints:points];
        points[1] = tangent2;
        [_path setHyperAssociatedPoints:points atIndex:next];
    }
    [self canonizePathWithScaling:NO];
}

- (void)setStrokeColor:(id)aColor
{
    if ([_strokeColor isEqual:aColor])
        return;
    [_strokeColor autorelease];
    _strokeColor = [aColor retain];
}

- (void)setLineDashInfoKey:(id)aKey
{
    [self setLineDashInfo:[[[HSVectorGraphicsLineDashInfoObjectProvider sharedProvider] namedObjects] objectForKey:aKey]];
}

- (id)lineDashInfoKey
{
    if (!_lineDashInfo)
        return @"none";
    return [[[[[_lineDashInfo class] sharedProvider] namedObjects] allKeysForObject:_lineDashInfo] extraFirstObject];
}

- (void)setLineDashInfo:(id)aInfo
{
    if (_lineDashInfo == aInfo)
        return;
    [_lineDashInfo releaseOwnerCount];
    [_lineDashInfo autorelease];
    _lineDashInfo = [aInfo retain];
    [_lineDashInfo retainOwnerCount];
    if (_lineDashInfo)
        [_path setAndScaleExtraLineDashString:[_lineDashInfo lineDashString]];
}

- (void)setFlatness:(CGFloat)aFlatness
{
    [_path setFlatness:aFlatness];
}

- (void)setMiterLimit:(CGFloat)aLimit
{
    [_path setMiterLimit:aLimit];
}

- (void)setWindingRule:(NSUInteger)aRule
{
    [_path setWindingRule:aRule];
}

- (void)setLineJoinStyle:(NSUInteger)aStyle
{
    [_path setLineJoinStyle:aStyle];
}

- (void)setLineCapStyle:(NSUInteger)aStyle
{
    [_path setLineCapStyle:aStyle];
}

// The dashes scale with the width.
- (void)setLineWidth:(CGFloat)aWidth
{
    [_path setLineWidth:aWidth];
    if (_lineDashInfo)
        [_path setAndScaleExtraLineDashString:[_lineDashInfo lineDashString]];
}

// The last three elements.
- (id)staticallyConnectedElementIndexes
{
    if (![self hyperBezierPath])
        return nil;
    NSUInteger count = [[self hyperBezierPath] elementCount];
    if (!count)
        return nil;
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(count - 3, 3)];
}

// The original lost the master indexes here, inserting every connected set
// under one key (0 shifted by the offset when shifting from 0, 0 otherwise);
// they are shifted like the connected indexes instead.
- (void)shiftConnectedElementsFromIndex:(NSUInteger)aIndex withOffset:(NSInteger)aOffset
{
    if (!_connectedMasterElements)
        return;
    NSMapTable *shifted = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    NSMapEnumerator enumerator = NSEnumerateMapTable(_connectedMasterElements);
    void *key = NULL;
    void *indexes = NULL;
    while (NSNextMapEnumeratorPair(&enumerator, &key, &indexes)) {
        [(NSMutableIndexSet *)indexes shiftIndexesStartingAtIndex:aIndex by:aOffset];
        NSUInteger master = (NSUInteger)key;
        if (master != NSNotFound && master >= aIndex)
            master += aOffset;
        NSMapInsert(shifted, (const void *)master, indexes);
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(_connectedMasterElements);
    _connectedMasterElements = shifted;
    [_connectedChildElementIndexes shiftIndexesStartingAtIndex:aIndex by:aOffset];
}

// From NSNotFound disconnects the index from every master.
- (void)disconnectElementIndex:(NSUInteger)aIndex fromElementAtIndex:(NSUInteger)aIndex2
{
    if (![[self connectedChildElementIndexes] containsIndex:aIndex])
        return;
    [[self connectedChildElementIndexes] removeIndex:aIndex];
    NSMutableIndexSet *indexes = _connectedMasterElements ? NSMapGet(_connectedMasterElements, (const void *)aIndex2) : nil;
    if (aIndex2 != NSNotFound) {
        if ([indexes containsIndex:aIndex])
            [indexes removeIndex:aIndex];
        return;
    }
    if (indexes)
        NSMapRemove(_connectedMasterElements, (const void *)NSNotFound);
    if (!_connectedMasterElements)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(_connectedMasterElements);
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&indexes)) {
        if ([indexes containsIndex:aIndex])
            [indexes removeIndex:aIndex];
    }
    NSEndMapTableEnumeration(&enumerator);
}

- (void)connectElementIndex:(NSUInteger)aIndex toElemenAtIndex:(NSUInteger)aIndex2
{
    NSMutableIndexSet *indexes = [self connectedIndexesForElementIndex:aIndex2];
    if (!indexes)
        indexes = [NSMutableIndexSet indexSet];
    [indexes addIndex:aIndex];
    NSMapInsertIfAbsent([self connectedElementsMap], (const void *)aIndex2, indexes);
    [[self connectedChildElementIndexes] addIndex:aIndex];
}

- (id)connectedIndexesForElementIndex:(NSUInteger)aIndex
{
    if (!_connectedMasterElements)
        return nil;
    return NSMapGet(_connectedMasterElements, (const void *)aIndex);
}

- (id)connectedChildElementIndexes
{
    if (!_connectedChildElementIndexes)
        _connectedChildElementIndexes = [NSMutableIndexSet new];
    return _connectedChildElementIndexes;
}

- (id)connectedElementsMap
{
    if (!_connectedMasterElements)
        _connectedMasterElements = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _connectedMasterElements;
}

- (void)connectStandartElements
{
}

// The first element is never deleted.
- (void)deleteElementAtIndex:(NSUInteger)aIndex glueWithEditingMode:(NSInteger)aMode
{
    if (aIndex == 0 || aIndex >= (NSUInteger)[_path elementCount])
        return;
    NSBezierPath *path = [[_path copy] autorelease];
    [_path removeAllPoints];
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    NSUInteger count = [path elementCount];
    for (NSUInteger index = 0; index < count; index++) {
        if (index == aIndex)
            continue;
        NSUInteger element = [path hyperElementAtIndex:index associatedPoints:points];
        [_path hyperAppendElement:element associatedPoints:points];
    }
    [self disconnectElementIndex:aIndex fromElementAtIndex:NSNotFound];
    [self shiftConnectedElementsFromIndex:aIndex withOffset:-1];
    [self canonizePathWithScaling:NO];
    if ([_path elementCount] > 2)
        [self applyEditingMode:aMode toElementsInRange:NSMakeRange(aIndex - 1, 2)];
}

// A line in mode 1, a curve otherwise; a move into an empty path.
- (void)insertPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode
{
    NSPoint points[3] = {aPoint, aPoint, aPoint};
    if ([_path elementCount] == 0)
        [self appendElement:NSMoveToBezierPathElement associatedPoints:points];
    else
        [self insertElement:(aMode == 1) + 1 associatedPoints:points atIndex:aIndex];
    if ([_path elementCount] > 2) {
        [self applyEditingMode:aMode toElementsInRange:NSMakeRange(aIndex - 1, 1)];
        [self applyEditingMode:aMode toElementsInRange:NSMakeRange(aIndex + 1, 1)];
    }
}

- (void)HSVectorGraphics_getCanonizedPoints:(NSPoint *)aCanonized fromPoints:(NSPoint *)aPoints
{
    CGAffineTransform affineTransform = [(id)[[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:affineTransform];
    [transform invert];
    if (!aPoints)
        return;
    aCanonized[0] = [transform transformPoint:aPoints[0]];
    aCanonized[1] = [transform transformPoint:aPoints[1]];
    aCanonized[2] = [transform transformPoint:aPoints[2]];
}

- (void)insertElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints atIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    [self HSVectorGraphics_getCanonizedPoints:points fromPoints:aPoints];
    NSUInteger count = [_path elementCount];
    if (count == aIndex) {
        [self appendElement:aElement associatedPoints:aPoints];
        return;
    }
    if (count <= aIndex)
        return;
    NSBezierPath *path = [[_path copy] autorelease];
    [_path removeAllPoints];
    NSPoint pathPoints[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    count = [path elementCount];
    for (NSUInteger index = 0; index < count; index++) {
        if (index == aIndex)
            [_path hyperAppendElement:aElement associatedPoints:points];
        NSUInteger element = [path hyperElementAtIndex:index associatedPoints:pathPoints];
        [_path hyperAppendElement:element associatedPoints:pathPoints];
    }
    [self shiftConnectedElementsFromIndex:aIndex withOffset:1];
    [self canonizePathWithScaling:NO];
}

- (void)appendElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints
{
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    [self HSVectorGraphics_getCanonizedPoints:points fromPoints:aPoints];
    [_path hyperAppendElement:aElement associatedPoints:points];
    if (aElement == NSClosePathBezierPathElement)
        [self connectStandartElements];
    [self canonizePathWithScaling:NO];
}

// The point becomes a curve's end, with the previous element's point as its
// first control point.
- (void)setPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex editingMode:(NSInteger)aMode
{
    NSPoint points[3] = {aPoint, aPoint, aPoint};
    if (aIndex != 0 && aIndex < (NSUInteger)[_path elementCount]) {
        [self hyperElementAtIndex:aIndex - 1 associatedPoints:points];
        points[1] = points[0];
        points[0] = aPoint;
        points[2] = aPoint;
    }
    [self setElementAtIndex:aIndex associatedPoints:points];
    [self applyEditingMode:aMode toElementsInRange:NSMakeRange(aIndex - 1, 3)];
}

- (void)setElementType:(NSUInteger)aType atIndex:(NSUInteger)aIndex
{
    if ((NSUInteger)[_path elementAtIndex:aIndex] == aType)
        return;
    NSBezierPath *path = [[_path copy] autorelease];
    [_path removeAllPoints];
    NSPoint points[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    NSUInteger count = [path elementCount];
    for (NSUInteger index = 0; index < count; index++) {
        NSUInteger element = [path hyperElementAtIndex:index associatedPoints:points];
        if (index == aIndex)
            element = aType;
        [_path hyperAppendElement:element associatedPoints:points];
    }
}

// Moves the elements connected to the element along with its point, and keeps
// a shape closed when its first point moves. The original converted the
// caller's points in place.
- (void)setElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints
{
    NSPoint oldPoints[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
    NSUInteger element = [_path hyperElementAtIndex:aIndex associatedPoints:oldPoints];
    if (element >= NSClosePathBezierPathElement)
        return;
    NSPoint points[3] = {aPoints[0], aPoints[1], aPoints[2]};
    CGAffineTransform affineTransform = [(id)[[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:affineTransform];
    [transform invert];
    points[0] = [transform transformPoint:points[0]];
    if (element == NSCurveToBezierPathElement) {
        points[1] = [transform transformPoint:points[1]];
        points[2] = [transform transformPoint:points[2]];
    }
    NSIndexSet *connected = [self connectedIndexesForElementIndex:aIndex];
    if (connected) {
        NSUInteger index = [connected firstIndex];
        NSAffineTransform *move = [NSAffineTransform transform];
        [move translateXBy:points[0].x - oldPoints[0].x yBy:points[0].y - oldPoints[0].y];
        while (index != NSNotFound) {
            NSPoint connectedPoints[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
            NSUInteger connectedElement = [_path hyperElementAtIndex:index associatedPoints:connectedPoints];
            connectedPoints[0] = [move transformPoint:connectedPoints[0]];
            if (connectedElement == NSCurveToBezierPathElement) {
                connectedPoints[1] = [move transformPoint:connectedPoints[1]];
                connectedPoints[2] = [move transformPoint:connectedPoints[2]];
            }
            [_path setHyperAssociatedPoints:connectedPoints atIndex:index];
            index = [connected indexGreaterThanIndex:index];
        }
    }
    [_path setHyperAssociatedPoints:points atIndex:aIndex];
    if ([self isHyperShape] && aIndex == 0) {
        NSBezierPath *path = [self hyperBezierPath];
        NSPoint lastPoints[3] = {NSZeroPoint, NSZeroPoint, NSZeroPoint};
        if ([path elementCount] > 1) {
            [path hyperElementAtIndex:0 associatedPoints:points];
            [path hyperElementAtIndex:[path elementCount] - 1 associatedPoints:lastPoints];
            lastPoints[0] = points[0];
            [path setHyperAssociatedPoints:lastPoints atIndex:[path elementCount] - 1];
        }
        if ([path elementCount] > 3) {
            [path hyperElementAtIndex:[path elementCount] - 3 associatedPoints:lastPoints];
            lastPoints[0] = points[0];
            [path setHyperAssociatedPoints:lastPoints atIndex:[path elementCount] - 3];
        }
    }
    [self canonizePathWithScaling:NO];
}

// Control points for a curve through the third point, along the direction from
// the first point to the second, 0.4 of the way to each.
- (void)tangentPoint1:(NSPoint *)aPoint1 point2:(NSPoint *)aPoint2 forThreePoints:(NSPoint *)aPoints
{
    float length = truncf(hypotf(aPoints[0].x - aPoints[1].x, aPoints[0].y - aPoints[1].y));
    float distance1 = hypotf(aPoints[0].x - aPoints[2].x, aPoints[0].y - aPoints[2].y);
    float distance2 = hypotf(aPoints[1].x - aPoints[2].x, aPoints[1].y - aPoints[2].y);
    float sum = distance1 + distance2;
    float length1 = truncf((distance1 * length) / sum);
    float length2 = truncf((distance2 * length) / sum);
    NSAffineTransform *rotation = [NSAffineTransform transform];
    [rotation rotateByRadians:(float)atan2(aPoints[1].y - aPoints[0].y, aPoints[1].x - aPoints[0].x)];
    NSPoint point1 = [rotation transformPoint:NSMakePoint((float)(length1 * -0.4), 0)];
    NSPoint point2 = [rotation transformPoint:NSMakePoint((float)(length2 * 0.4), 0)];
    NSAffineTransform *translation = [NSAffineTransform transform];
    [translation translateXBy:aPoints[2].x yBy:aPoints[2].y];
    point1 = [translation transformPoint:point1];
    point2 = [translation transformPoint:point2];
    if (aPoint1)
        *aPoint1 = point1;
    if (aPoint2)
        *aPoint2 = point2;
}

- (void)adjustCanonizingTransform
{
}

- (void)canonizePathWithScaling:(BOOL)aScaling
{
    [self canonizePathWithScaling:aScaling concatWithCurrentTransform:YES];
}

// Canonizes the path and makes the object's affine transform undo the
// canonization, after the current one if asked to.
- (void)canonizePathWithScaling:(BOOL)aScaling concatWithCurrentTransform:(BOOL)aTransform
{
    NSAffineTransform *applied = [NSAffineTransform transform];
    [_path extraCanonizeWithScaling:aScaling appliedTransform:applied];
    [applied invert];
    [[self undoManager] disableUndoRegistration];
    id object = [self hyperObject];
    CGAffineTransform transform = [applied hyperCGAffineTransform];
    if (aTransform) {
        CGAffineTransform current = [(id)[object queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
        transform = CGAffineTransformConcat(transform, current);
        object = [self hyperObject];
    }
    [(HSGeometryBehaviorApplier *)[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setAffineTransform:transform withLayoutGuidingContext:nil];
    [[self undoManager] enableUndoRegistration];
}

- (id)renderingTransform
{
    return [[_canonizingTransform copy] autorelease];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self connectStandartElements];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [[[super keysForExtraLoadingWithCodingContext:aContext] mutableCopy] autorelease];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"hyperLineWidth"];
        [keys addObject:[@"strokeColor" extraKeyForMultiRepresentations]];
    } else {
        [keys addObject:@"lineDashInfo"];
        [keys addObject:@"lineDashInfoKey"];
        [keys addObject:@"bezierPath"];
        [keys addObject:@"dynamicStrokeWidthAdjustmentFactor"];
    }
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray array];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"hyperLineWidth"];
        [keys addObject:[@"strokeColor" extraKeyForMultiRepresentations]];
    } else {
        [keys addObject:[[self class] serializationKeyForLineDashInfo:_lineDashInfo serializedValue:NULL]];
        [keys addObject:@"bezierPath"];
        [keys addObject:@"dynamicStrokeWidthAdjustmentFactor"];
        [keys addObject:[@"strokeColor" extraKeyForMultiRepresentations]];
        [keys addObject:@"canonizingTransform"];
    }
    return keys;
}

- (id)undoManager
{
    return [[self hyperObject] undoManager];
}

- (id)hyperObject
{
    return [[self owner] hyperObjectForVectorGraphics:self];
}

- (void)setBezierPath:(id)aPath
{
    [self setBezierPath:aPath resetTransform:NO];
}

// Without a reset, the object's transform keeps applying after the
// canonization.
- (void)setBezierPath:(id)aPath resetTransform:(BOOL)aTransform
{
    if (_path == aPath)
        return;
    [_path autorelease];
    _path = [aPath retain];
    [self canonizePathWithScaling:NO concatWithCurrentTransform:!aTransform];
    if (_lineDashInfo)
        [_path setAndScaleExtraLineDashString:[_lineDashInfo lineDashString]];
    [self connectStandartElements];
}

- (id)bezierPath
{
    return _path;
}

- (void)setSize:(NSSize)aSize
{
    NSSize size = [self size];
    if (HSVectorGraphicsSizesAreEqual(size, aSize) || HSVectorGraphicsSizesAreEqual(size, NSZeroSize))
        return;
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:HSVectorGraphicsScale(aSize.width, size.width) yBy:HSVectorGraphicsScale(aSize.height, size.height)];
    [_path transformUsingAffineTransform:transform];
}

- (NSSize)size
{
    if ([self isHyperEmpty])
        return NSZeroSize;
    return [_path bounds].size;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    if (_connectedMasterElements)
        NSFreeMapTable(_connectedMasterElements);
    [_connectedChildElementIndexes release];
    [_path release];
    [_canonizingTransform release];
    [_PDFColor release];
    [_lineDashInfo releaseOwnerCount];
    [_lineDashInfo release];
    [_strokeColor release];
    [super dealloc];
}

// Needs a path with elements. As in the original, the path copies the visual
// attributes of the still missing path.
- (id)initWithBezierPath:(id)aPath
{
    if (!aPath || ![aPath elementCount]) {
        [self release];
        return nil;
    }
    self = [super init];
    [aPath hyperCopyVisualAttributesFrom:[self bezierPath]];
    [self setBezierPath:aPath];
    [self adjustCanonizingTransform];
    return self;
}

- (void)setCanonizingTransform:(id)aTransform
{
    if (_canonizingTransform == aTransform)
        return;
    [_canonizingTransform release];
    _canonizingTransform = [aTransform retain];
}

- (id)canonizingTransform
{
    return _canonizingTransform;
}

- (id)hyperPDFColor
{
    if (_PDFColor == nil)
        _PDFColor = [[[self hyperStrokeColor] hyperPDFColor] retain];
    return _PDFColor;
}

@end
