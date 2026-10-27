#import "HSAnimationPositioning.h"
// Places an animated object on its path: the object's center sits at the
// path point for the current time, offset by where it stood relative to
// the path's start (the fixation, at time zero).
@implementation HSAnimationPositioning
// Moves the center there, then rounds the frame's origin.
+ (void)setPosition:(NSPoint)aPosition ofObject:(id)aObject
{
    id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil)
        return;
    [applier moveCenterTo:aPosition withLayoutGuidingContext:nil];
    NSRect frame = [[applier mutableGeometryAttributes] frameBoundingRect];
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(roundf((float)frame.origin.x), roundf((float)frame.origin.y)) withLayoutGuidingContext:nil];
}
// The transformed center of the object's box.
+ (NSPoint)positionOfObject:(id)aObject
{
    id<HSGeometryAttributes> geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroPoint;
    NSSize size = [geometry size];
    CGAffineTransform transform = [geometry affineTransform];
    return NSMakePoint(transform.tx + transform.a * (float)size.width * 0.5f + transform.c * (float)size.height * 0.5f,
                       transform.ty + transform.b * (float)size.width * 0.5f + transform.d * (float)size.height * 0.5f);
}
- (void)updateObjectPosition
{
    NSPoint point = [[self structure] pathPointAtTime:[self pathTime]];
    NSPoint start = [[self structure] pathPointAtTime:0];
    NSPoint origin = [_fixation objectPositionAtZeroTime];
    [self setObjectPosition:NSMakePoint(((float)origin.x + (float)point.x) - (float)start.x, ((float)origin.y + (float)point.y) - (float)start.y)];
}
// The animated attributes' values at the current time (not undoable).
- (void)updateObjectAttributes
{
    [[[self object] undoManager] disableUndoRegistration];
    NSDictionary *attributes = [[self structure] attributes];
    NSEnumerator *enumerator = [attributes keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil)
        [[self object] setValue:[[attributes objectForKey:key] valueAtTime:[self pathTime]] forKey:key];
    [[[self object] undoManager] enableUndoRegistration];
}
- (double)pathTime
{
    return [_dataSource pathTimeForAnimationPositioning:self];
}
- (id)structure
{
    return [_dataSource structureForAnimationPositioning:self];
}
- (id)object
{
    return [_dataSource objectToAnimateForAnimationPositioning:self];
}
- (void)replaceFixationWith:(id)aWith
{
    if (_fixation == aWith)
        return;
    [_fixation release];
    _fixation = [aWith copy];
}
- (id)fixation
{
    return _fixation;
}
- (NSPoint)objectPositionAtZeroTime
{
    return [_fixation objectPositionAtZeroTime];
}
- (void)setObjectPosition:(NSPoint)aPosition
{
    [[[self object] undoManager] disableUndoRegistration];
    [[self class] setPosition:aPosition ofObject:[self object]];
    [[[self object] undoManager] enableUndoRegistration];
}
- (NSPoint)objectPosition
{
    return [[self class] positionOfObject:[self object]];
}
- (void)updateObject
{
    [self updateObjectAttributes];
    [self updateObjectPosition];
}
// Remembers the object's current offset from the path.
- (void)updateFixation
{
    NSPoint position = [self objectPosition];
    NSPoint point = [[self structure] pathPointAtTime:[self pathTime]];
    NSPoint start = [[self structure] pathPointAtTime:0];
    [_fixation setObjectPositionAtZeroTime:NSMakePoint(((float)start.x + (float)position.x) - (float)point.x, ((float)start.y + (float)position.y) - (float)point.y)];
}
- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}
- (id)dataSource
{
    return _dataSource;
}
- (void)dealloc
{
    [_fixation release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _fixation = [HSAnimationFixation new];
    return self;
}
@end
