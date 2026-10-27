#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSVectorGraphicsObjectData : HSShadowedObjectData <HSGraphicsDelegate, HyperInterface, NSObject, HSVectorGraphicsOwner, HSVectorGraphicsLineEndingOwner>
{
    NSString *_objectKindName;
    HSVectorGraphics *_vg;
    HSVectorGraphicsLineEnding *_headEnding;
    HSVectorGraphicsLineEnding *_tailEnding;
    NSImage *_backgroundThumbnail;
    HSGraphics *_backgroundGraphics;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)hyperObjectForLineEnding:(id)aEnding;
- (id)hyperObjectForVectorGraphics:(id)aGraphics;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (void)setBackgroundGraphics:(id)aGraphics;
- (id)backgroundGraphics;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)backgroundThumbnail;
- (void)setTailEnding:(id)aEnding;
- (id)tailEnding;
- (void)setHeadEnding:(id)aEnding;
- (id)headEnding;
- (void)setVg:(id)aVg;
- (id)vg;
- (void)setObjectKindName:(id)aName;
- (id)objectKindName;
- (void)dealloc;
@end

