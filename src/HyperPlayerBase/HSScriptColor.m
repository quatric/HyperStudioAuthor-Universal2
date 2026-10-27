#import "HSScriptColor.h"
// A color for scripts: { r, g, b } from 0 to 255, opacity from 0 to 100.
@implementation HSScriptColor
// Three numbers.
+ (BOOL)canBuildColorFromArguments:(id)aArguments
{
    if ([aArguments count] < 3)
        return NO;
    for (NSUInteger index = 0; index < 3; index++)
        if (![[aArguments objectAtIndex:index] respondsToSelector:@selector(floatValue)])
            return NO;
    return YES;
}
+ (id)normalizeColorSpace:(id)aSpace
{
    return [aSpace colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
}
// An NSColor stays as it is. The opacity defaults to 0; with an old color
// its alpha is kept instead.
+ (id)colorWithScriptObject:(id)aObject andOldColor:(id)aColor
{
    if (![self isValidColorObject:aObject])
        return nil;
    if ([aObject isKindOfClass:[NSColor class]])
        return aObject;
    float red = [[aObject valueForKey:@"r"] floatValue];
    float green = [[aObject valueForKey:@"g"] floatValue];
    float blue = [[aObject valueForKey:@"b"] floatValue];
    float alpha = 0;
    id opacity = [aObject valueForKey:@"opacity"];
    if (opacity != nil && ![opacity isKindOfClass:[WebUndefined class]])
        alpha = [opacity floatValue];
    if (aColor != nil)
        alpha = [aColor alphaComponent] * 100.0f;
    [HSScriptColor normalizeColorWithRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}
+ (BOOL)isValidColorObject:(id)aObject
{
    if ([aObject isKindOfClass:[NSColor class]])
        return YES;
    return [self scriptObject:aObject hasFloatComponentsNamed:[self colorComponentsNames]];
}
+ (void)normalizeColorWithRed:(float *)aRed green:(float *)aGreen blue:(float *)aBlue alpha:(float *)aAlpha
{
    *aRed = *aRed / 255.0;
    *aGreen = *aGreen / 255.0;
    *aBlue = *aBlue / 255.0;
    if (aAlpha != NULL)
        *aAlpha = *aAlpha / 100.0;
}
+ (id)scriptColorWithColor:(id)aColor
{
    NSColor *color = [self normalizeColorSpace:aColor];
    HSScriptColor *scriptColor = [[HSScriptColor new] autorelease];
    scriptColor->_r = [color redComponent] * 255.0f;
    scriptColor->_g = [color greenComponent] * 255.0f;
    scriptColor->_b = [color blueComponent] * 255.0f;
    scriptColor->_opacity = [color alphaComponent] * 100.0f;
    return scriptColor;
}
+ (id)colorComponentsNames
{
    static NSArray *names = nil;
    if (names == nil)
        names = [[NSArray alloc] initWithObjects:@"r", @"g", @"b", nil];
    return names;
}
- (id)objectIdentifierString
{
    return [NSString stringWithFormat:@"{%@: %i, %@: %i, %@: %i}", @"r", (int)_r, @"g", (int)_g, @"b", (int)_b];
}
- (void)getRed:(float *)aRed green:(float *)aGreen blue:(float *)aBlue
{
    if (aRed != NULL)
        *aRed = _r;
    if (aGreen != NULL)
        *aGreen = _g;
    if (aBlue != NULL)
        *aBlue = _b;
}
@end
