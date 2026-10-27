#import "HSBitmapPencilToolWrapper.h"

@implementation HSBitmapPencilToolWrapper

// Solid RGB stroke colors are copied back to the shared tool settings.
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    BOOL alternate = [aKey isEqualToString:@"alternateStrokeColor"];
    if (alternate || [aKey isEqualToString:@"strokeColor"]) {
        CGEColorRef color = [[aTool valueForOutputKey:aKey] pointer];
        if (CGEColorIsSolid(color)) {
            CGColorRef cgColor = CGEColorGetCGColor(color);
            CGColorSpaceRef rgb = cgColor != NULL ? CGColorSpaceCreateDeviceRGB() : NULL;
            if (rgb != NULL) {
                if (CGColorGetNumberOfComponents(cgColor) == 4 && CFEqual(CGColorGetColorSpace(cgColor), rgb)) {
                    NSColor *nsColor = [NSColor colorWithColorSpace:[NSColorSpace deviceRGBColorSpace] components:CGColorGetComponents(cgColor) count:4];
                    if (nsColor != nil) {
                        id settings = [[HSToolManager sharedToolManager] toolSettings];
                        if (alternate)
                            [settings setEraserColor:nsColor];
                        else
                            [settings setDrawColor:nsColor];
                    }
                }
                CGColorSpaceRelease(rgb);
            }
        }
    }
    [super tool:aTool didUpdateOutputForKey:aKey];
}

- (id)settingsIdentifiers
{
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolEraserColorAttributeKey, nil]];
}

- (BOOL)activateBitmapTool
{
    BOOL activated = [super activateBitmapTool];
    if (activated) {
        if (_startPoints == nil) {
            _startPoints = [NSMutableArray new];
            _endPoints = [NSMutableArray new];
        }
        [[self bitmapTool] startRecordStrokesWithConsumer:self];
    }
    return activated;
}

- (void)addPencilStrokeFromPoint:(CGPoint)aFrom toPoint:(CGPoint)aTo
{
    if (CGRectEqualToRect(_bounds, CGRectZero)) {
        _bounds.origin.x = MIN(aFrom.x, aTo.x);
        _bounds.origin.y = MIN(aFrom.y, aTo.y);
        _bounds.size.width = fabsf(aFrom.x - aTo.x);
        _bounds.size.height = fabsf(aFrom.y - aTo.y);
    } else {
        CGFloat maxX = _bounds.origin.x + _bounds.size.width;
        CGFloat maxY = _bounds.origin.y + _bounds.size.height;
        CGFloat minX = MIN(MIN(_bounds.origin.x, aTo.x), aFrom.x);
        CGFloat minY = MIN(MIN(_bounds.origin.y, aTo.y), aFrom.y);
        _bounds.size.width = MAX(MAX(maxX, aTo.x), aFrom.x) - minX;
        _bounds.size.height = MAX(MAX(maxY, aTo.y), aFrom.y) - minY;
        _bounds.origin.x = minX;
        _bounds.origin.y = minY;
    }
    [_startPoints addObject:[NSValue valueWithPoint:NSPointFromCGPoint(aFrom)]];
    [_endPoints addObject:[NSValue valueWithPoint:NSPointFromCGPoint(aTo)]];
}

- (void)deactivateBitmapTool
{
    [[self bitmapTool] stopRecordStrokesWithConsumer:self];
    [_startPoints removeAllObjects];
    [_endPoints removeAllObjects];
    _bounds = CGRectZero;
    [super deactivateBitmapTool];
}

- (void)dealloc
{
    [_startPoints release];
    [_endPoints release];
    [super dealloc];
}

- (void)getStartPoint:(CGPoint *)aStart endtPoint:(CGPoint *)aEnd forPencilStrokeAtIndex:(NSUInteger)aIndex
{
    if (aStart != NULL && aEnd != NULL && aIndex < [_startPoints count]) {
        *aStart = NSPointToCGPoint([[_startPoints objectAtIndex:aIndex] pointValue]);
        *aEnd = NSPointToCGPoint([[_endPoints objectAtIndex:aIndex] pointValue]);
    }
}

- (NSUInteger)numberOfPencilStrokes
{
    return [_startPoints count];
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNext
{
    if ([self bitmapTool] == aTool && aNext == nil) {
        id bitmapTool = [self bitmapTool];
        if (CGEColorIsGradient((CGEColorRef)[[bitmapTool strokeColor] pointer])) {
            id image = [bitmapTool workImage];
            CGSize imageSize = image != nil ? [image imageSize] : CGSizeZero;
            CGRect rect = CGRectIntersection(_bounds, CGRectMake(0, 0, imageSize.width, imageSize.height));
            if (!CGRectIsEmpty(rect)) {
                CGContextRef context = [image imageCGContext];
                if (context != NULL) {
                    [bitmapTool preEditWorkImage:image inRect:rect];
                    [image beginCGEditing];
                    [bitmapTool drawWithPointProvider:self inContext:context withBounds:rect];
                    [image endCGEditing];
                    [bitmapTool postEditWorkImageInRect:rect];
                }
            }
        }
        [_startPoints removeAllObjects];
        [_endPoints removeAllObjects];
        _bounds = CGRectZero;
    }
    return [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aNext];
}

@end
