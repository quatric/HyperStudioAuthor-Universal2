#import "HSVectorDrawShapeTool.h"

@implementation HSVectorDrawShapeTool

+ (Class)settingsSerializationClass
{
    return [BTShapeCreationToolSettingsSerialization class];
}

- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform
{
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)canProvideSelectedShape
{
    return NO;
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    id trackingObject = [self trackingObject];
    if ([self bitmapTool] != aTool)
        return;

    CGPathRef path;
    if ([aKey isEqualToString:@"selectionPath"] && (path = (CGPathRef)[aTool valueForInputKey:aKey]) != NULL) {
        if (CGRectIsEmpty(CGEPathGetPathBoundingBox(path))) {
            if (trackingObject != nil)
                [self deactivateTrackingObjectIfNeeded];
            return;
        }
        BOOL created = [self createIfNeededAndActivateTrackingObject];
        BOOL multiple = _drawMultiple;
        id vector = [self vectorAttributes];
        if (multiple && !created)
            [vector appendHyperBezierPath:[NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)path]];
        else
            [vector setHyperBezierPath:[NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)path] dynamicStrokeWidthAdjustmentFactor:_dynamicStrokeWidthAdjustmentFactor resetTransform:YES];
        return;
    }

    if (![aKey isEqualToString:@"pointsArray"])
        return;
    id points = [aTool valueForInputKey:aKey];
    if ([points count] != 2)
        return;
    NSPoint *first = [points bytesOfItemAtIndex:0];
    NSPoint *second = [points bytesOfItemAtIndex:1];
    if (first == NULL || second == NULL)
        return;
    NSPoint start = *first;
    if (_drawCentered)
        start = NSMakePoint(2.0 * first->x - second->x, 2.0 * first->y - second->y);

    BOOL created = [self createIfNeededAndActivateTrackingObject];
    id vector = [self vectorAttributes];
    NSPoint associated[3] = { start, NSZeroPoint, NSZeroPoint };
    if (!created && (_drawMultiple || [vector hyperElementCount] == 0)) {
        [vector appendHyperElement:0 associatedPoints:associated];
        associated[0] = *second;
        [vector appendHyperElement:1 associatedPoints:associated];
    }
    else {
        [vector setHyperElementAtIndex:0 associatedPoints:associated];
        associated[0] = *second;
        [vector setHyperElementAtIndex:1 associatedPoints:associated];
    }
    if ([trackingObject isKindOfClass:[HSVectorGraphicsObject class]])
        [[trackingObject vg] setDynamicStrokeWidthAdjustmentFactor:_dynamicStrokeWidthAdjustmentFactor];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *representation = nil;
    id positioning = [aRepresentation valueForKey:HSToolPositioningOptionAttributeKey];
    if (positioning != nil) {
        representation = [aRepresentation mutableCopy];
        [representation removeObjectForKey:HSToolPositioningOptionAttributeKey];
    }
    id centering = [aRepresentation valueForKey:HSToolCenteringOptionAttributeKey];
    if (centering != nil && ![[self bitmapTool] isKindOfClass:[BTCreateShapeSelectionTool class]]) {
        if (representation == nil)
            representation = [aRepresentation mutableCopy];
        [representation removeObjectForKey:HSToolCenteringOptionAttributeKey];
    }
    if (representation != nil)
        aRepresentation = [representation autorelease];
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];

    NSDictionary *settings = [[self toolSettingsWrapper] settings];
    id vector = [[self prototypeObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    id value = [settings objectForKey:@"path"];
    if (value != nil)
        [vector setHyperBezierPath:value == [NSNull null] ? nil : value];
    value = [settings objectForKey:@"strokeWidth"];
    if (value != nil)
        [vector setHyperLineWidth:value == [NSNull null] ? 0.0f : [value floatValue]];

    id fillColor = [settings objectForKey:@"fillColor"];
    if (fillColor != nil) {
        id background = [[self prototypeObject] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)];
        id graphics = nil;
        if ([fillColor respondsToSelector:@selector(hyperHSColor)])
            graphics = [fillColor hyperHSColor];
        if (graphics == nil && fillColor != [NSNull null]) {
            graphics = [background queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
            [graphics setHyperSolidColor:fillColor];
        }
        [background setBackgroundGraphics:graphics];
    }

    value = [settings objectForKey:@"dynamicStrokeWidthAdjustmentFactor"];
    if (value == nil)
        _dynamicStrokeWidthAdjustmentFactor = [[self primarySettingsIdentifier] isEqualToString:@"HSLineTool"] ? 0 : 2;
    else
        _dynamicStrokeWidthAdjustmentFactor = [value unsignedIntValue];
    if (positioning != nil)
        [self setDrawMultiple:[positioning unsignedIntValue] != 0];
    if (centering != nil)
        [self setDrawCentered:[centering unsignedIntValue] == 0];
}

- (void)setDrawCentered:(BOOL)aCentered
{
    _drawCentered = aCentered;
}

- (BOOL)drawCentered
{
    return _drawCentered;
}

- (void)setDrawMultiple:(BOOL)aMultiple
{
    _drawMultiple = aMultiple;
}

- (BOOL)drawMultiple
{
    return _drawMultiple;
}

- (id)settingsIdentifiers
{
    NSArray *identifiers;
    if ([[self primarySettingsIdentifier] isEqualToString:@"HSLineTool"])
        identifiers = [NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolStrokeWidthAttributeKey, HSToolCenteringOptionAttributeKey, HSToolPositioningOptionAttributeKey, nil];
    else
        identifiers = [NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolStrokeWidthAttributeKey, HSToolCenteringOptionAttributeKey, HSToolPositioningOptionAttributeKey, HSToolFillColorAttributeKey, nil];
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:identifiers];
}

- (id)primarySettingsIdentifier
{
    NSString *identifier = [self toolIdentifier];
    if ([identifier isEqualToString:@"HSVectorLineTool"])
        return @"HSLineTool";
    if ([identifier isEqualToString:@"HSVectorDragRectTool"])
        return @"HSDragRectTool";
    if ([identifier isEqualToString:@"HSVectorDragCircleTool"])
        return @"HSDragCircleTool";
    if ([identifier isEqualToString:@"HSVectorDragRoundedRectTool"])
        return @"HSDragRoundedRectTool";
    return [super primarySettingsIdentifier];
}

- (id)initWithBTTool:(id)aTool
{
    self = [super initWithBTTool:aTool];
    if (self != nil)
        _dynamicStrokeWidthAdjustmentFactor = 2;
    return self;
}

@end
