#import "HyperPlayerBasePrefix.h"
#import "HSVectorDrawingNodeUnit.h"


@interface HSVectorBrushNodeUnit : HSVectorDrawingNodeUnit
{
    BTBrushTouchStorage *_touchStorage;
    CGRect _boundingRect;
    unsigned int _areBoundsValid:1;
    unsigned int _isPatternPhaseSet:1;
    HSVectorBrushRenderer *_brushRenderer;
    HSNewMedia *_rendererCacheMedia;
    struct CGImage *_rendererCacheImage;
}
+ (id)createNewTool;
- (NSSize)HSVectorBrushNodeUnit_normalizeStorageBounds;
- (void)HSVectorBrushNodeUnit_recreateRendererCacheIfNeeded;
- (void)HSVectorBrushNodeUnit_createRendererCacheImageWithData:(id)aData;
- (id)HSVectorBrushNodeUnit_rendererCacheImageData;
- (struct CGImage *)HSVectorBrushNodeUnit_rendererCacheImage;
- (id)mediaUIDs;
- (void)setRendererCacheImageUID:(id)aUID;
- (id)rendererCacheImageUID;
- (void)setTouchStorageData:(id)aData;
- (id)touchStorageData;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setting:(id)aSetting didChangeInSerialization:(id)aSerialization;
- (void)setting:(id)aSetting willChangeInSerialization:(id)aSerialization;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)brushRenderer;
- (NSRect)toolBoundingRect;
- (void)setTouchStorage:(id)aStorage;
- (id)touchProvider;
- (id)tool;
- (id)attributes;
- (void)dealloc;
- (id)init;
@end

