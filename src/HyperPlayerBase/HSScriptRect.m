#import "HSScriptRect.h"
@implementation HSScriptRect
+ (BOOL)getRect:(NSRect *)aRect fromScriptObject:(id)aObject
{
    BOOL isRect = [self isRectObject:aObject];
    if (isRect) {
        float x = [[aObject valueForKey:@"x"] floatValue];
        float y = [[aObject valueForKey:@"y"] floatValue];
        float width = [[aObject valueForKey:@"width"] floatValue];
        float height = [[aObject valueForKey:@"height"] floatValue];
        if (aRect != NULL)
            *aRect = NSMakeRect(x, y, width, height);
    }
    return isRect;
}
+ (BOOL)isRectObject:(id)aObject
{
    return [self scriptObject:aObject hasFloatComponentsNamed:[self rectComponentsNames]];
}
+ (NSRect)rectWithScriptObject:(id)aObject andOldRect:(NSRect)aRect
{
    NSRect rect = NSZeroRect;
    if ([self getRect:&rect fromScriptObject:aObject])
        return rect;
    return aRect;
}
+ (id)scriptRectWithRect:(NSRect)aRect
{
    HSScriptRect *rect = [[HSScriptRect new] autorelease];
    rect->_x = aRect.origin.x;
    rect->_y = aRect.origin.y;
    rect->_width = aRect.size.width;
    rect->_height = aRect.size.height;
    return rect;
}
+ (id)rectComponentsNames
{
    static NSArray *names = nil;
    if (names == nil)
        names = [[NSArray alloc] initWithObjects:@"x", @"y", @"width", @"height", nil];
    return names;
}
- (id)objectIdentifierString
{
    return [NSString stringWithFormat:@"{%@: %i, %@: %i, %@: %i, %@: %i}",
            @"x", (int)_x, @"y", (int)_y, @"width", (int)_width, @"height", (int)_height];
}
@end
