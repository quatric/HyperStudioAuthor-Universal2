#import "HyperPlayerBasePrefix.h"
#import "HSButtonObject.h"
#import "HSCard.h"
#import "HSImageObject.h"
#import "HSShapeObject.h"
#import "HSStack.h"
#import "HSSystemTextView.h"
#import "HSUserObject.h"
#import "HSVectorBrushObject.h"


@interface HSSystemTextView (HSSystemTextViewVisualExtensions)
- (id)imageFromBackground;
- (BOOL)needsToStoreBackgroundAsImage;
@end

@interface HSVectorBrushObject (HSUserObjectVisualExtensions)
- (Class)shapeRenderLayerClass;
@end

@interface HSVectorGraphicsObject (HSUserObjectVisualExtensions)
- (Class)shapeRenderLayerClass;
@end

@interface HSButtonObject (HSUserObjectVisualExtensions)
- (Class)shapeRenderLayerClass;
- (id)shapeImageWithSize:(NSSize)aSize;
@end

@interface HSImageObject (HSUserObjectVisualExtensions)
- (Class)shapeRenderLayerClass;
@end

@interface HSStack (HSUserObjectVisualExtensionsPrivate)
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport;
- (id)HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:(id)aProtocol;
- (NSSize)HSUserObjectVisualExtensions_size;
@end

@interface HSCard (HSUserObjectVisualExtensionsPrivate)
- (id)imageOfSize:(NSSize)aSize forPresentationContext:(id)aContext;
- (id)imageForPlayerOfSize:(NSSize)aSize;
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport withLiveVideo:(BOOL)aVideo;
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport;
- (NSRect)boundingRectUsingRenderer:(id)aRenderer;
- (void)HSUserObject_HSUserObjectVisualExtensions_webElementDidLoad:(id)aLoad;
- (void)playedObjectDidChangeVideoFrame:(id)aFrame;
- (NSSize)HSUserObjectVisualExtensions_size;
@end

@interface HSUserObject (HSUserObjectVisualExtensions)
- (id)shapeImageWithSize:(NSSize)aSize;
- (Class)shapeRenderLayerClass;
- (id)imageForHTML5Export;
- (CGAffineTransform)affineTransformIncludingShadowOffset;
- (NSRect)affineFrameBoundingRectIncludingShadow;
- (id)imageForIPadExport;
- (NSRect)boundsForIPadExport;
- (id)imageForExportOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol;
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol;
- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport;
- (NSRect)boundingRectUsingRenderer:(id)aRenderer;
- (id)imageWithVisualizationProtocol:(id)aProtocol;
- (id)imageOfSize:(NSSize)aSize forPresentationContext:(id)aContext;
- (id)imageForPresentationContext:(id)aContext;
- (id)HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:(id)aProtocol;
- (NSSize)HSUserObjectVisualExtensions_size;
- (id)previewForHTML5Export;
- (id)imageForExport;
- (id)image;
- (id)imageForExportOfSize:(NSSize)aSize;
- (id)imageOfSize:(NSSize)aSize;
@end

