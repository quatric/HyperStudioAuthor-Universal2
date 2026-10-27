#import "HyperPlayerBasePrefix.h"
#import "HSHyperImplementation.h"


@interface HSVisualHitTester : HSHyperImplementation <HSUserObjectHitTestingImplementation, HSUserObjectHitTesting, HyperInterface, NSObject, HSUserObjectInteractiveHitTesting, HSUserObjectEditorHitTesting, HSObjectTypeHitTestings, HSVectorGraphicObjectHitTesting, HSTextObjectHitTesting, HSButtonObjectHitTesting, HSEffectObjectHitTesting, HSMovieObjectHitTesting, HSImageObjectHitTesting, HSTextViewObjectHitTesting, HSCameraObjectHitTesting, HSWebObjectHitTesting, HSImageWellObjectHitTesting, HSGroupBoxObjectHitTesting, HSVectorBrushHitTesting>
{
    Protocol *_visualizationProtocol;
    id<HSRenderer> _renderer;
}
+ (id)sharedRenderDelegate;
- (BOOL)hitTestUserRect:(NSRect)aRect;
- (BOOL)hitTestUserPoint:(NSPoint)aPoint;
- (CGAffineTransform)rendererToRootUserSpaceAffineTransform;
- (id)userBoundingRegion;
- (id)renderer;
- (id)geometryAttributes;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
- (id)initWithHyperObject:(id)aObject;
@end

