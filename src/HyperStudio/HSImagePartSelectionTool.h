#import "HyperStudioPrefix.h"
#import "HSBaseBitmapTool.h"


@interface HSImagePartSelectionTool : HSBaseBitmapTool
{
    id<HSImageObjectAttributes> _workObject;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    BOOL _createsWorkImage;
    void *_userInfo;
    id _delegate;
}
- (void)handleCancelOperationFromCanvasLayer:(id)aLayer;
- (void)handleInsertNewlineFromCanvasLayer:(id)aLayer;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void *)userInfo;
- (void)setUserInfo:(void *)aInfo;
- (CGAffineTransform)imageToViewTransform;
- (CGAffineTransform)transformForHiResolution:(CGAffineTransform)aResolution;
- (void)createWorkImageIfNeeded;
- (CGAffineTransform)workImageTransformForImageSize:(NSSize)aSize;
- (struct CGImage *)workImageOfSize:(NSSize *)aSize;
- (BOOL)isActiveAtPoint:(NSPoint)aPoint;
- (id)geometryAttributes;
- (id)workObject;
- (void)setWorkObject:(id)aObject;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (id)visualizationCanvasLayer;
- (BOOL)allowsSelection;
- (struct CGPath *)copiedCGPath;
- (void)dealloc;
- (id)initWithBTTool:(id)aTool obeyLayoutGuiding:(BOOL)aGuiding resetOnSave:(BOOL)aSave createWorkImage:(BOOL)aImage;
@end

@interface HSImagePartSelectionToolWorkImage : NSObject <BTCGImage, BTImage, NSObject>
{
    struct CGImage *_image;
    CGAffineTransform _affineTransform;
}
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
- (CGSize)imageSize;
- (void)dealloc;
- (id)initWithCGImage:(struct CGImage *)aImage affineTransform:(CGAffineTransform)aTransform;
- (id)init;
@end

