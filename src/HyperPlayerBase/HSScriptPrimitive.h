#import "HyperPlayerBasePrefix.h"


@interface HSScriptPrimitive : NSObject
{
}
+ (BOOL)scriptObject:(id)aObject hasFloatComponentsNamed:(id)aNamed;
+ (BOOL)getString:(id *)aString fromScriptObject:(id)aObject;
+ (BOOL)getBool:(BOOL *)aBool fromScriptObject:(id)aObject;
+ (BOOL)getDouble:(double *)aDouble fromScriptObject:(id)aObject;
+ (BOOL)getFloat:(float *)aFloat fromScriptObject:(id)aObject;
+ (BOOL)getPercents:(unsigned int *)aPercents fromScriptObject:(id)aObject;
+ (BOOL)scriptObjectToBoolean:(id)aBoolean;
+ (BOOL)getSize:(NSSize *)aSize fromScriptObject:(id)aObject;
+ (BOOL)getPoint:(NSPoint *)aPoint fromScriptObject:(id)aObject;
+ (BOOL)getRect:(NSRect *)aRect fromScriptObject:(id)aObject;
+ (NSRect)rectWithScriptObject:(id)aObject andOldRect:(NSRect)aRect;
+ (NSSize)sizeWithScriptObject:(id)aObject andOldSize:(NSSize)aSize;
+ (NSPoint)pointWithScriptObject:(id)aObject andOldPoint:(NSPoint)aPoint;
+ (id)colorWithScriptArgs:(id)aArgs;
+ (id)colorWithScriptObject:(id)aObject andOldColor:(id)aColor;
+ (id)scriptPrimitiveWithSize:(NSSize)aSize;
+ (id)scriptPrimitiveWithPoint:(NSPoint)aPoint;
+ (id)scriptPrimitiveWithRect:(NSRect)aRect;
+ (id)scriptPrimitiveWithColor:(id)aColor;
@end

@interface HSScriptPrimitive (WebScripting)
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aScript;
+ (id)webScriptNameForKey:(char *)aKey;
+ (BOOL)isKeyExcludedFromWebScript:(char *)aScript;
@end

