#import "HyperStudioPrefix.h"
#import "HSEffectController.h"


@interface HSEffectCompositeController : HSEffectController <HSEffectsPreviewControllerDataSource, NSObject>
{
    HSEffectsPreviewController *_previewController;
    NSImage *_originalPreviewImage;
    NSView *_previewsContainer;
}
- (void)setObject:(id)aObject;
- (void)update;
- (void)didMount;
- (void)didLoadNib;
- (id)effectPreviewImage;
- (id)originalPreviewImage;
- (BOOL)isOriginalObjectFlippedHorizontally;
- (BOOL)isOriginalObjectFlippedVertically;
- (id)previewController;
- (void)dealloc;
@end

