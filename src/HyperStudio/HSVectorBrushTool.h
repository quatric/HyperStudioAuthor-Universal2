#import "HyperStudioPrefix.h"
#import "HSBaseBitmapTool.h"


@interface HSVectorBrushTool : HSBaseBitmapTool <HSBrushTouchesStorageDelegate, NSObject>
{
    HSBrushTouchesStorage *_touchStorage;
    id<BTCocoaImage> _contextImage;
    CGRect _brushBounds;
    id _prototypeObject;
}
+ (Class)settingsSerializationClass;
+ (id)layerIdentifiersWithRootLayer:(id)aLayer;
+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer;
+ (Class)toolCanvasLayerClass;
- (void)touchStorageDidAddTouch:(id)aTouch;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (id)touchProvider;
- (void)invalidateContext;
- (void)prepareContext;
- (NSSize)contextImageSize;
- (id)contextImage;
- (CGAffineTransform)imageToViewTransform;
- (CGAffineTransform)HSVectorBrushTool_imageTransform;
- (BOOL)activateBitmapTool;
- (id)bitmapTool;
- (id)prototypeObject;
- (id)settingsIdentifiers;
- (id)primarySettingsIdentifier;
- (void)dealloc;
@end

