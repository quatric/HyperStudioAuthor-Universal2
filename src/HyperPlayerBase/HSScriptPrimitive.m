#import "HSScriptPrimitive.h"

// Shared conversions between JavaScript (WebScript) values and Cocoa values.
@implementation HSScriptPrimitive
+ (BOOL)scriptObject:(id)aObject hasFloatComponentsNamed:(id)aNamed
{
    for (id name in aNamed) {
        if (![name isKindOfClass:[NSString class]])
            return YES;
        if (![[aObject valueForKey:name] respondsToSelector:@selector(floatValue)])
            return NO;
    }
    return YES;
}
+ (BOOL)getString:(id *)aString fromScriptObject:(id)aObject
{
    if (![aObject isKindOfClass:[NSString class]])
        return NO;
    if (aString)
        *aString = aObject;
    return YES;
}
+ (BOOL)getBool:(BOOL *)aBool fromScriptObject:(id)aObject
{
    if (![aObject respondsToSelector:@selector(boolValue)])
        return NO;
    BOOL value = [aObject boolValue];
    if (aBool)
        *aBool = value;
    return YES;
}
+ (BOOL)getDouble:(double *)aDouble fromScriptObject:(id)aObject
{
    if (![aObject respondsToSelector:@selector(doubleValue)])
        return NO;
    double value = [aObject doubleValue];
    if (aDouble)
        *aDouble = value;
    return YES;
}
+ (BOOL)getFloat:(float *)aFloat fromScriptObject:(id)aObject
{
    if (![aObject respondsToSelector:@selector(floatValue)])
        return NO;
    float value = [aObject floatValue];
    if (aFloat)
        *aFloat = value;
    return YES;
}
+ (BOOL)getPercents:(unsigned int *)aPercents fromScriptObject:(id)aObject
{
    if (![aObject respondsToSelector:@selector(unsignedIntValue)])
        return NO;
    unsigned int value = [aObject unsignedIntValue];
    if (value > 100)
        return NO;
    if (aPercents)
        *aPercents = value;
    return YES;
}
+ (BOOL)scriptObjectToBoolean:(id)aBoolean
{
    if (aBoolean == nil || [aBoolean isKindOfClass:[WebUndefined class]])
        return NO;
    if ([aBoolean respondsToSelector:@selector(boolValue)])
        return [aBoolean boolValue];
    return YES;
}
+ (BOOL)getSize:(NSSize *)aSize fromScriptObject:(id)aObject
{
    return [HSScriptSize getSize:aSize fromScriptObject:aObject];
}
+ (BOOL)getPoint:(NSPoint *)aPoint fromScriptObject:(id)aObject
{
    return [HSScriptPoint getPoint:aPoint fromScriptObject:aObject];
}
+ (BOOL)getRect:(NSRect *)aRect fromScriptObject:(id)aObject
{
    return [HSScriptRect getRect:aRect fromScriptObject:aObject];
}
+ (NSRect)rectWithScriptObject:(id)aObject andOldRect:(NSRect)aRect
{
    return [HSScriptRect rectWithScriptObject:aObject andOldRect:aRect];
}
+ (NSSize)sizeWithScriptObject:(id)aObject andOldSize:(NSSize)aSize
{
    return [HSScriptSize sizeWithScriptObject:aObject andOldSize:aSize];
}
+ (NSPoint)pointWithScriptObject:(id)aObject andOldPoint:(NSPoint)aPoint
{
    return [HSScriptPoint pointWithScriptObject:aObject andOldPoint:aPoint];
}
+ (id)colorWithScriptArgs:(id)aArgs
{
    return [HSScriptColor colorWithScriptArgs:aArgs];
}
+ (id)colorWithScriptObject:(id)aObject andOldColor:(id)aColor
{
    return [HSScriptColor colorWithScriptObject:aObject andOldColor:aColor];
}
+ (id)scriptPrimitiveWithSize:(NSSize)aSize
{
    return [HSScriptSize scriptSizeWithSize:aSize];
}
+ (id)scriptPrimitiveWithPoint:(NSPoint)aPoint
{
    return [HSScriptPoint scriptPointWithPoint:aPoint];
}
+ (id)scriptPrimitiveWithRect:(NSRect)aRect
{
    return [HSScriptRect scriptRectWithRect:aRect];
}
+ (id)scriptPrimitiveWithColor:(id)aColor
{
    return [HSScriptColor scriptColorWithColor:aColor];
}
@end

@implementation HSScriptPrimitive (WebScripting)
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aScript
{
    return YES;
}
+ (id)webScriptNameForKey:(char *)aKey
{
    if (*aKey == '_')
        aKey++;
    return [NSString stringWithCString:aKey encoding:NSASCIIStringEncoding];
}
+ (BOOL)isKeyExcludedFromWebScript:(char *)aScript
{
    return NO;
}
@end
