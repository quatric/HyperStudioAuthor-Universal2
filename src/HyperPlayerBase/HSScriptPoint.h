#import "HyperPlayerBasePrefix.h"
#import "HSScriptPrimitive.h"


@interface HSScriptPoint : HSScriptPrimitive
{
    float _x;
    float _y;
}
+ (BOOL)getPoint:(NSPoint *)aPoint fromScriptObject:(id)aObject;
+ (BOOL)isPointObject:(id)aObject;
+ (id)pointComponentsNames;
+ (NSPoint)pointWithScriptObject:(id)aObject andOldPoint:(NSPoint)aPoint;
+ (id)scriptPointWithPoint:(NSPoint)aPoint;
- (id)objectIdentifierString;
@end

