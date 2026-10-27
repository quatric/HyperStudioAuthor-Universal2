#import "HSVectorBrushObject.h"
#import "HSConcreteCardObjectData.h"
#import "HSGeometryBehaviorApplier.h"
#import "HSGeometryNodeUnit.h"
#import "HSHitTestingVectorBrushVisualization.h"
#import "HSVectorBrushData.h"
#import "HSVectorBrushNodeUnit.h"
#import "HSVectorBrushVisualization.h"
#import "HSVisualHitTester.h"

// x is zero within 0.0005, scaled by |x| once that exceeds 1 (compared as floats).
static BOOL HSVectorBrushObject_isAlmostZero(float aValue)
{
    float magnitude = aValue != 0.0f ? fabsf(aValue) : 1.0f;
    float tolerance = 1.0f <= magnitude ? magnitude * 0.0005f : 0.0005f;
    return fabsf(aValue) <= tolerance;
}

// A freehand vector brush stroke; its size follows the stroke's tool bounds and can't be resized.
@implementation HSVectorBrushObject
+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"HSGeometryNodeUnit", @"Geometry Unit",
            @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
            @"HSVectorBrushNodeUnit", HSVectorBrushRole,
            @"HSShowHideTransitionNodeUnit", @"Transition Unit",
            @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}
+ (Class)nodeDataClass
{
    return [HSVectorBrushData class];
}
- (BOOL)shouldBeExportedAsImage
{
    return YES;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
// When the tool bounds move by an offset, the geometry is shifted back so the stroke stays in place.
- (void)HSVectorBrushObject_toolBoundsDidChange:(id)aChange
{
    id offsetValue = [[aChange userInfo] objectForKey:@"HSVectorBrushToolBoundingRectOffset"];
    NSSize offset = offsetValue != nil ? [offsetValue extraSizeValue] : NSZeroSize;
    if (HSVectorBrushObject_isAlmostZero(offset.width) && HSVectorBrushObject_isAlmostZero(offset.height))
        return;
    HSGeometryBehaviorApplier *applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    CGAffineTransform transform = [[applier mutableGeometryAttributes] affineTransform];
    transform.tx = (transform.a * -offset.width - transform.c * offset.height) + transform.tx;
    transform.ty = (-offset.width * transform.b - transform.d * offset.height) + transform.ty;
    [applier setAffineTransform:transform withLayoutGuidingContext:nil];
}
- (id)queryVectorGraphicObjectHitTester
{
    return [self queryDefaultHitTester];
}
- (id)queryEditorHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}
- (id)queryInteractiveHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}
- (id)queryDefaultHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self] autorelease];
}
- (void)setHyperOpacity:(CGFloat)aOpacity
{
    float current = [(HSConcreteCardObjectData *)[self nodeData] opacity];
    float magnitude = current != 0.0f ? fabsf(current) : 1.0f;
    float newMagnitude = aOpacity != 0.0 ? fabsf((float)aOpacity) : 1.0f;
    if (newMagnitude <= magnitude)
        newMagnitude = magnitude;
    if (!(newMagnitude * 0.0005f < fabsf(current - (float)aOpacity)))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
    [(HSVectorBrushObject *)[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[(HSConcreteCardObjectData *)[self nodeData] opacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}
- (CGFloat)hyperOpacity
{
    return (float)[(HSConcreteCardObjectData *)[self nodeData] opacity];
}
- (BOOL)prefersToMaintainSizeAspectRatio
{
    return YES;
}
- (BOOL)canResizeVertically
{
    return NO;
}
- (BOOL)canResizeHorizontally
{
    return NO;
}
- (BOOL)canBreakSizeAspectRatio
{
    return NO;
}
- (NSSize)size
{
    return [self HSVectorBrushObject_brushSize];
}
- (NSSize)defaultSize
{
    return [self HSVectorBrushObject_brushSize];
}
- (CGFloat)height
{
    return [self HSVectorBrushObject_brushSize].height;
}
- (CGFloat)width
{
    return [self HSVectorBrushObject_brushSize].width;
}
- (NSSize)HSVectorBrushObject_brushSize
{
    id attributes = [self queryHyperInterface:@protocol(HSVectorBrushAttributes)];
    if (attributes == nil)
        return NSZeroSize;
    return [attributes hyperToolBoundingRect].size;
}
- (id)nonLocalizedObjectKindKey
{
    return [[self nodeData] objectKindName];
}
- (id)queryNewHyperInterface:(id)aInterface
{
    Class visualizationClass;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        visualizationClass = [HSVectorBrushVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface)
             || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface)
             || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
        visualizationClass = [HSHitTestingVectorBrushVisualization class];
    else
        return [super queryNewHyperInterface:aInterface];
    return [[[visualizationClass alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
}
- (void)dealloc
{
    [super removeObserver:self selector:@selector(HSVectorBrushObject_toolBoundsDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVectorBrushToolBoundingRectAttribute)];
    [super dealloc];
}
- (void)setToolSettings:(id)aSettings touchStorage:(id)aStorage geometryTransform:(CGAffineTransform)aTransform geometryFlippedHorizontally:(BOOL)aHorizontally settingsWrapperInitialDelegate:(id)aDelegate
{
    id brushUnit = [super unitForRole:HSVectorBrushRole];
    if ([brushUnit isKindOfClass:[HSVectorBrushNodeUnit class]]) {
        [brushUnit setToolSettings:aSettings];
        [brushUnit setTouchStorage:aStorage];
    }
    id geometryUnit = [super unitForRole:@"Geometry Unit"];
    if ([geometryUnit isKindOfClass:[HSGeometryNodeUnit class]])
        [(HSGeometryNodeUnit *)geometryUnit setAffineTransform:aTransform flippedHorizontally:aHorizontally];
}
- (id)initWithToolSettings:(id)aSettings touchStorage:(id)aStorage geometryTransform:(CGAffineTransform)aTransform geometryFlippedHorizontally:(BOOL)aHorizontally settingsWrapperInitialDelegate:(id)aDelegate
{
    self = [self init];
    if (self != nil) {
        id brushUnit = [super unitForRole:HSVectorBrushRole];
        if ([brushUnit isKindOfClass:[HSVectorBrushNodeUnit class]]) {
            [brushUnit setToolSettings:aSettings];
            [brushUnit setTouchStorage:aStorage];
        }
        id geometryUnit = [super unitForRole:@"Geometry Unit"];
        if ([geometryUnit isKindOfClass:[HSGeometryNodeUnit class]])
            [(HSGeometryNodeUnit *)geometryUnit setAffineTransform:aTransform flippedHorizontally:aHorizontally];
    }
    return self;
}
// Width and height both follow the brush thickness.
- (id)init
{
    self = [super init];
    if (self != nil) {
        [super linkAttribute:@protocol(HSWidthAttribute) toAttribute:@protocol(HSBrushThicknessAttribute)];
        [super linkAttribute:@protocol(HSHeightAttribute) toAttribute:@protocol(HSBrushThicknessAttribute)];
        [super addObserver:self selector:@selector(HSVectorBrushObject_toolBoundsDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVectorBrushToolBoundingRectAttribute) withPriority:0.75];
    }
    return self;
}
@end
