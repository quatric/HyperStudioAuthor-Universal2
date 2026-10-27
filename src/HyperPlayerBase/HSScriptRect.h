#import "HyperPlayerBasePrefix.h"
#import "HSScriptPrimitive.h"


@interface HSScriptRect : HSScriptPrimitive
{
    float _x;
    float _y;
    float _width;
    float _height;
}
+ (BOOL)getRect:(NSRect *)aRect fromScriptObject:(id)aObject;
+ (BOOL)isRectObject:(id)aObject;
+ (NSRect)rectWithScriptObject:(id)aObject andOldRect:(NSRect)aRect;
+ (id)scriptRectWithRect:(NSRect)aRect;
+ (id)rectComponentsNames;
- (id)objectIdentifierString;
@end

