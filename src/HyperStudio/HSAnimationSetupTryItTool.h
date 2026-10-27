#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSAnimationSetupTryItTool : HSTool <HSAnimationSetupTryItCanvasLayerDelegate>
{
    id<HSAnimationSetupTryItToolDelegate> _delegate;
    HSAnimationSetupTryItCanvasLayer *_tryItCanvasLayer;
}
- (void)cancelForTryItCanvasLayer:(id)aLayer;
- (id)tryItCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldResetToolOnAddObjects;
- (void)dealloc;
- (BOOL)shouldResetToolOnSelectObjects;
@end

