#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSVectorBrushData : HSShadowedObjectData
{
    NSString *_objectKindName;
}
- (void)setObjectKindName:(id)aName;
- (id)objectKindName;
- (void)dealloc;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

