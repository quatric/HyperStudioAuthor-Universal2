#import "HyperStudioPrefix.h"


@interface HSAnimationSetupTryItCanvasLayer : HSCompositeCanvasLayer
{
    id<HSAnimationSetupTryItCanvasLayerDelegate> _delegate;
}
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

