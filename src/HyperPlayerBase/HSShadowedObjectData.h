#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObjectData.h"


@interface HSShadowedObjectData : HSConcreteCardObjectData
{
    NSShadow *_shadow;
    BOOL _shadowEnabled;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setShadowEnabled:(BOOL)aEnabled;
- (BOOL)isShadowEnabled;
- (void)setShadow:(id)aShadow;
- (id)shadow;
- (void)dealloc;
@end

