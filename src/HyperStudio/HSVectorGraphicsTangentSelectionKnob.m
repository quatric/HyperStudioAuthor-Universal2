#import "HSVectorGraphicsTangentSelectionKnob.h"

@implementation HSVectorGraphicsTangentSelectionKnob

- (BOOL)canBeLocked
{
    return NO;
}

- (BOOL)isEqualToKnob:(id)aKnob
{
    if (![super isEqualToKnob:aKnob] || ![aKnob isKindOfClass:[HSVectorGraphicsTangentSelectionKnob class]])
        return NO;
    return [self isFirstControlPoint] == [aKnob isFirstControlPoint];
}

- (BOOL)prefersRegionInvalidation
{
    return YES;
}

- (void)invalidateCachedFrame
{
    [super invalidateCachedFrame];
    [self invalidateBoundingRegion];
}

- (void)invalidateBoundingRegion
{
    [_boundingRegion release];
    _boundingRegion = nil;
}

- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    if (_boundingRegion == nil) {
        id region = [[super boundingRegionForOwner:aOwner frame:aFrame inView:aView] mutableCopy];
        NSPoint start = NSZeroPoint, end = NSZeroPoint;
        if ([self getTangentPathStart:&start end:&end forOwner:aOwner inView:aView])
            [region addRegion:[HSRegion regionWithLineFromPoint:start toPoint:end strokeThickness:1.0f]];
        _boundingRegion = [region copy];
        [region release];
    }
    return _boundingRegion;
}

- (BOOL)getTangentPathStart:(NSPoint *)aStart end:(NSPoint *)aEnd forOwner:(id)aOwner inView:(id)aView
{
    NSUInteger index = [self associatedElementIndex];
    if (index == (NSUInteger)-1)
        return NO;
    id attributes = [aOwner queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    if (attributes == nil)
        return NO;
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [attributes hyperElementAtIndex:index associatedPoints:points];
    NSPoint end = points[0];
    NSPoint start = points[2];
    if ([self isFirstControlPoint]) {
        [attributes hyperElementAtIndex:index + 1 associatedPoints:points];
        start = points[1];
    }
    *aStart = [aView convertPointFromUserSpaceToViewSpace:start];
    *aEnd = [aView convertPointFromUserSpaceToViewSpace:end];
    return YES;
}

- (void)setIsFirstControlPoint:(BOOL)aPoint
{
    if (_isFirstControlPoint != (aPoint != NO)) {
        _isFirstControlPoint = aPoint != NO;
        [self invalidateCachedFrame];
    }
}

- (BOOL)isFirstControlPoint
{
    return _isFirstControlPoint;
}

- (void)setAssociatedElementIndex:(NSUInteger)aIndex owner:(id)aOwner
{
    [super setAssociatedElementIndex:aIndex owner:aOwner];
    if (aIndex != (NSUInteger)-1)
        aIndex += [self isFirstControlPoint] ? 1 : 0;
    id attributes = [aOwner queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    BOOL valid = [self isValid] && aIndex < [attributes hyperElementCount] && [attributes hyperElementAtIndex:aIndex associatedPoints:NULL] == 2;
    [self setValid:valid];
    [self setActiveStateImage:nil];
}

- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect
{
    NSPoint start = NSZeroPoint, end = NSZeroPoint;
    if ([self getTangentPathStart:&start end:&end forOwner:aOwner inView:aView]) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:start];
        [path lineToPoint:end];
        [path setLineWidth:0.5];
        [[NSColor blueColor] set];
        [path stroke];
    }
    [super drawWithFrame:aFrame owner:aOwner inView:aView invalidRect:aRect];
}

- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    NSRect bounds = [super boundingRectForOwner:aOwner frame:aFrame inView:aView];
    NSPoint start = NSZeroPoint, end = NSZeroPoint;
    if ([self getTangentPathStart:&start end:&end forOwner:aOwner inView:aView]) {
        NSRect line = NSMakeRect(MIN(start.x, end.x), MIN(start.y, end.y), fabs(start.x - end.x), fabs(start.y - end.y));
        bounds = NSUnionRect(NSInsetRect(line, -2.0, -2.0), bounds);
    }
    return bounds;
}

- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSSize size = [self imageSize];
    id attributes = [aOwner queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    BOOL first = [self isFirstControlPoint];
    [attributes hyperElementAtIndex:[self associatedElementIndex] + (first ? 1 : 0) associatedPoints:points];
    NSPoint point = [aView convertPointFromUserSpaceToViewSpace:points[[self isFirstControlPoint] ? 1 : 2]];
    return NSIntegralRect(NSMakeRect(point.x + size.width * -0.5f, point.y + size.height * -0.5f, size.width, size.height));
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return [[HSVectorGraphicsTangentSelectionTracker alloc] init];
}

@end
