#import "HyperPlayerBasePrefix.h"
#import "HSScriptPrimitive.h"


@interface HSScriptSize : HSScriptPrimitive
{
    float _width;
    float _height;
}
+ (BOOL)getSize:(NSSize *)aSize fromScriptObject:(id)aObject;
+ (BOOL)isSizeObject:(id)aObject;
+ (id)sizeComponentsNames;
+ (NSSize)sizeWithScriptObject:(id)aObject andOldSize:(NSSize)aSize;
+ (id)scriptSizeWithSize:(NSSize)aSize;
@end

