#import "BTCreateMagicWandSelectionTool.h"
#import "BTCGBitmapLayer.h"

@implementation BTCreateMagicWandSelectionTool

- (void)finalizeSelectionPath:(id)aSender
{
    if (!_isSelectionStartPointDefined)
        return;
    [self beginUndoAction];
    [self BTCreateMagicWandSelectionTool_createSelectionPathForPoint:_selectionStartPoint event:nil];
    [self endUndoActionWithName:@"Change Magic Wand Selection"];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
    if ([self isActive]) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        _isSelectionStartPointDefined = NO;
    }
}

/* Starts the wand from the top-left pixel. */
- (void)selectAllArea:(id)aSender
{
    [self beginUndoAction];
    CGSize size = [[self workImage] imageSize];
    [self BTCreateMagicWandSelectionTool_createSelectionPathForPoint:NSMakePoint(0.5, size.height - 0.5) event:nil];
    [self endUndoActionWithName:@"Create All Area Magic Wand Selection"];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:nil nextStage:nil];
    if ([self isActive]) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        _isSelectionStartPointDefined = NO;
    }
}

- (void)setSelectionStartPoint:(id)aPoint
{
    _selectionStartPoint = [aPoint pointValue];
    _isSelectionStartPointDefined = YES;
}

- (BOOL)mouseDown:(id)aEvent
{
    [self beginUndoAction];
    [self BTCreateMagicWandSelectionTool_createSelectionPathForPoint:[self eventLocationInImage:aEvent] event:aEvent];
    [self endUndoActionWithName:@"Create Magic Wand Selection"];
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:nil];
    if ([self isActive]) {
        CGPathRelease(_selectionPath);
        _selectionPath = NULL;
        _isSelectionStartPointDefined = NO;
    }
    return YES;
}

/* Traces the area of similar color around the point; Shift keeps the pixel staircase. */
- (void)BTCreateMagicWandSelectionTool_createSelectionPathForPoint:(NSPoint)aPoint event:(id)aEvent
{
    [_delegate tool:self willUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self willUpdateOutputForKey:@"selectionStartPoint"];
    if (aPoint.x >= 0.0 && aPoint.y >= 0.0) {
        CGSize size = [[self workImage] imageSize];
        if (aPoint.x <= size.width && aPoint.y <= size.height) {
            id<BTRawImage> bitmap = [self BTCreateMagicWandSelectionTool_bitmapWorkImage];
            CGMutablePathRef path;
            if (bitmap != nil && (path = (CGMutablePathRef)CFAutorelease(CGPathCreateMutable())) != NULL) {
                if (CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, [bitmap imageBytes], lround(size.width), lround(size.height),
                                                                   [bitmap imageBytesPerRow], aPoint.x, aPoint.y, _tolerance, 1, 8, NULL)) {
                    _selectionStartPoint = aPoint;
                    _isSelectionStartPointDefined = YES;
                    if ([aEvent modifierFlags] & NSEventModifierFlagShift)
                        _selectionPath = CGPathCreateCopy(path);
                    else
                        _selectionPath = (CGPathRef)BTCGPathCreateCopyWithSmoothedCorners(path);
                }
            }
        }
    }
    [_delegate tool:self didUpdateOutputForKey:@"selectionStartPoint"];
    [_delegate tool:self didUpdateOutputForKey:@"selectionPath"];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionStartPoint"];
    [_delegate tool:self didFinalizeOutputForKey:@"selectionPath"];
}

/* The work image itself when it is a plain ARGB bitmap, else an ARGB copy of it. */
- (id)BTCreateMagicWandSelectionTool_bitmapWorkImage
{
    id image = [self workImage];
    if (image == nil)
        return nil;
    if ([image conformsToProtocol:@protocol(BTRawImage)] && [image conformsToProtocol:@protocol(BTCGMutableImage)]
        && [image imageFormat] == -1 && [image imageDecode] == NULL && [image imageColorProfile] == NULL)
        return image;

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    CGSize size = [image imageSize];
    long width = size.width > 0.0 ? lround(ceil(size.width)) : 0;
    long height = size.height > 0.0 ? lround(ceil(size.height)) : 0;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~15L, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (context == NULL)
        return nil;
    [image drawInCGContext:context atPoint:CGPointZero];
    id layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
    CGContextRelease(context);
    return layer;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    return [self willCreateSelectionCursor];
}

- (id)currentStage
{
    return @"BTWaitingToolStage";
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    CGPathRelease(_selectionPath);
    _selectionPath = NULL;
    _isSelectionStartPointDefined = NO;
    return YES;
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"selectionStartPoint", @"selectionPath", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willCreateSelectionCursor", @"tolerance", @"selectionStartPoint", nil];
}

- (id)selectionPath
{
    return (id)_selectionPath;
}

- (id)selectionStartPoint
{
    if (!_isSelectionStartPointDefined)
        return nil;
    return [NSValue valueWithPoint:_selectionStartPoint];
}

- (void)setTolerance:(CGFloat)aTolerance
{
    _tolerance = aTolerance;
}

- (CGFloat)tolerance
{
    return _tolerance;
}

- (void)setWillCreateSelectionCursor:(id)aCursor
{
    if (_willCreateSelectionCursor != aCursor) {
        [_willCreateSelectionCursor release];
        _willCreateSelectionCursor = [aCursor retain];
    }
}

- (id)willCreateSelectionCursor
{
    return _willCreateSelectionCursor;
}

- (id)defaultWillCreateSelectionCursor
{
    return nil;
}

- (id *)optionalImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTRawImage);
    return protocols;
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

- (void)dealloc
{
    [_willCreateSelectionCursor release];
    CGPathRelease(_selectionPath);
    [super dealloc];
}

@end
