#import "HSScriptPoint.h"
@implementation HSScriptPoint
+ (BOOL)getPoint:(NSPoint *)aPoint fromScriptObject:(id)aObject
{
    BOOL isPoint = [self isPointObject:aObject];
    if (isPoint) {
        float x = [[aObject valueForKey:@"x"] floatValue];
        float y = [[aObject valueForKey:@"y"] floatValue];
        if (aPoint != NULL)
            *aPoint = NSMakePoint(x, y);
    }
    return isPoint;
}
+ (BOOL)isPointObject:(id)aObject
{
    return [self scriptObject:aObject hasFloatComponentsNamed:[self pointComponentsNames]];
}
+ (id)pointComponentsNames
{
    static NSArray *names = nil;
    if (names == nil)
        names = [[NSArray alloc] initWithObjects:@"x", @"y", nil];
    return names;
}
+ (NSPoint)pointWithScriptObject:(id)aObject andOldPoint:(NSPoint)aPoint
{
    NSPoint point = NSZeroPoint;
    if ([self getPoint:&point fromScriptObject:aObject])
        return point;
    return aPoint;
}
+ (id)scriptPointWithPoint:(NSPoint)aPoint
{
    HSScriptPoint *point = [[HSScriptPoint new] autorelease];
    point->_x = aPoint.x;
    point->_y = aPoint.y;
    return point;
}
- (id)objectIdentifierString
{
    return [NSString stringWithFormat:@"{%@: %i, %@: %i}", @"x", (int)_x, @"y", (int)_y];
}
@end
