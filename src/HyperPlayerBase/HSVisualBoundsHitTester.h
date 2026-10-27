#import "HyperPlayerBasePrefix.h"
#import "HSHyperImplementation.h"


@interface HSVisualBoundsHitTester : HSHyperImplementation <HSUserObjectHitTestingImplementation, HSUserObjectHitTesting, HyperInterface, NSObject, HSUserObjectInteractiveHitTesting, HSUserObjectEditorHitTesting, HSObjectTypeHitTestings, HSVectorGraphicObjectHitTesting, HSTextObjectHitTesting, HSButtonObjectHitTesting, HSEffectObjectHitTesting, HSMovieObjectHitTesting, HSImageObjectHitTesting, HSTextViewObjectHitTesting, HSCameraObjectHitTesting, HSWebObjectHitTesting, HSImageWellObjectHitTesting, HSGroupBoxObjectHitTesting, HSVectorBrushHitTesting>
{
    Protocol *_visualizationProtocol;
}
- (BOOL)hitTestUserRect:(NSRect)aRect;
- (BOOL)hitTestUserPoint:(NSPoint)aPoint;
- (CGAffineTransform)rendererToRootUserSpaceAffineTransform;
- (id)userBoundingRegion;
- (id)renderer;
- (id)geometryAttributes;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
@end

