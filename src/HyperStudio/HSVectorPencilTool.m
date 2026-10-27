#import "HSVectorPencilTool.h"

@implementation HSVectorPencilTool

- (void)addPencilStrokeFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2
{
    id attributes = [self vectorAttributes];
    NSPoint points[3] = { NSPointFromCGPoint(aPoint), NSZeroPoint, NSZeroPoint };

    if (attributes == nil) {
        [self createIfNeededAndActivateTrackingObject];
        attributes = [self vectorAttributes];
        [attributes appendHyperElement:NSMoveToBezierPathElement associatedPoints:points];
    }
    points[0] = NSPointFromCGPoint(aPoint2);
    [attributes appendHyperElement:NSLineToBezierPathElement associatedPoints:points];
}

- (id)settingsIdentifiers
{
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSToolDrawColorAttributeKey, @"HSVectorPencilTool", nil]];
}

- (id)primarySettingsIdentifier
{
    return @"HSPencilTool";
}

- (BOOL)activateBitmapTool
{
    BOOL activated = [super activateBitmapTool];

    if (activated)
        [(BTPencilTool *)[self bitmapTool] startRecordStrokesWithConsumer:self];
    return activated;
}

- (void)deactivateBitmapTool
{
    [(BTPencilTool *)[self bitmapTool] stopRecordStrokesWithConsumer:self];
    [super deactivateBitmapTool];
}

- (id)initWithBTTool:(id)aTool
{
    self = [super initWithBTTool:aTool];
    if (self == nil)
        return nil;
    [aTool setStrokeAdjustment:nil];
    return self;
}

@end
