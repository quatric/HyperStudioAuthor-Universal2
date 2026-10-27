#import "HyperPlayerBasePrefix.h"
#import "HSHyperImplementation.h"


@interface HSVectorGraphicsObjectHitTester : HSHyperImplementation <HSUserObjectHitTestingImplementation, HSUserObjectHitTesting, HyperInterface, NSObject, HSUserObjectInteractiveHitTesting, HSUserObjectEditorHitTesting, HSObjectTypeHitTestings, HSVectorGraphicObjectHitTesting, HSTextObjectHitTesting, HSButtonObjectHitTesting, HSEffectObjectHitTesting, HSMovieObjectHitTesting, HSImageObjectHitTesting, HSTextViewObjectHitTesting, HSCameraObjectHitTesting, HSWebObjectHitTesting, HSImageWellObjectHitTesting, HSGroupBoxObjectHitTesting, HSVectorBrushHitTesting>
{
}
- (BOOL)hitTestUserRect:(NSRect)aRect;
- (BOOL)hitTestUserPoint:(NSPoint)aPoint;
@end

