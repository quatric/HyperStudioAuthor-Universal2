#import "HyperPlayerBasePrefix.h"
#import "HSTextObject.h"


@interface HSHeadlineObject : HSTextObject <HSBackgroundRenderer, HSMutableBackgroundAttributes, HSBackgroundAttributes, HSAttributes, HyperInterface, NSObject, HSBackgroundGraphicsAttribute, HSBackgroundAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSBackgroundBoundsAttribute, HSHeadlineObjectAttributes, HSMutableOutlineAttributes, HSOutlineAttributes, HSOutlineAvailabilityAttribute, HSOutlineWidthAttribute, HSOutlineColorAttribute, HSVectorAttributes, HSStrokeColorVectorAttribute, HSVectorAttribute, HSFillGraphicsVectorAttribute, HSBezierPathVectorAttribute, HSBackgroundAttributesContainerPrimitives>
{
}
+ (id)sharedRenderingLayoutManager;
+ (id)backgroundAttributesSerializationKey;
+ (Class)nodeDataClass;
- (void)setOutlineColor:(id)aColor;
- (id)outlineColor;
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize;
- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)backgroundThumbnail;
- (void)_setBackgroundGraphics:(id)aGraphics;
- (id)backgroundGraphics;
- (NSRect)backgroundBounds;
- (void)setHyperOutlineColor:(id)aColor;
- (id)hyperOutlineColor;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (CGFloat)hyperOutlineWidth;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (BOOL)isHyperOutlineEnabled;
- (id)bezierPath;
- (id)fillGraphics;
- (id)strokeColor;
- (void)setOutlineEnabled:(BOOL)aEnabled;
- (BOOL)isOutlineEnabled;
- (void)setOutlineWidth:(CGFloat)aWidth;
- (CGFloat)outlineWidth;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)init;
@end

