#import "HyperPlayerBasePrefix.h"
#import "HSUserObjectInteractiveView.h"


@interface HSCardObjectView : HSUserObjectInteractiveView
{
}
- (void)drawViewLayerContentRect:(NSRect)aRect;
- (id)userSpaceToViewSpaceTransform;
- (id)presentationContext;
- (id)createCanvasHitTester;
- (id)createRootCanvasLayer;
- (NSRect)userObjectBounds;
- (BOOL)isFlipped;
- (NSPoint)cardObjectOrigin;
- (NSSize)cardObjectSize;
@end

