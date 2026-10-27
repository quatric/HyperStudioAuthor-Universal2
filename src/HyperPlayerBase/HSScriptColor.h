#import "HyperPlayerBasePrefix.h"
#import "HSScriptPrimitive.h"


@interface HSScriptColor : HSScriptPrimitive
{
    float _r;
    float _g;
    float _b;
    float _opacity;
}
+ (BOOL)canBuildColorFromArguments:(id)aArguments;
+ (id)normalizeColorSpace:(id)aSpace;
+ (id)colorWithScriptObject:(id)aObject andOldColor:(id)aColor;
+ (BOOL)isValidColorObject:(id)aObject;
+ (void)normalizeColorWithRed:(float *)aRed green:(float *)aGreen blue:(float *)aBlue alpha:(float *)aAlpha;
+ (id)scriptColorWithColor:(id)aColor;
+ (id)colorComponentsNames;
- (id)objectIdentifierString;
- (void)getRed:(float *)aRed green:(float *)aGreen blue:(float *)aBlue;
@end

