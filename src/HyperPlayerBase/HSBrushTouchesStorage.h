#import "HyperPlayerBasePrefix.h"


@interface HSBrushTouchesStorage : BTBrushTouchStorage
{
    id<HSBrushTouchesStorageDelegate> _delegate;
}
- (void)setDelegate:(id)aDelegate;
- (void)addTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aDeviation rotationAngleDeviation:(CGFloat)aDeviation2 opacityDeviation:(CGFloat)aDeviation3 alternateColor:(BOOL)aColor colorHSVADeviation:(id)aDeviation4 colorNativeDeviation:(id)aDeviation5 shadowColorHSVADeviation:(id)aDeviation6 shadowColorNativeDeviation:(id)aDeviation7;
@end

@interface BTBrushTool (HSExtensions)
+ (id)hyperPreviewImageOfSize:(NSSize)aSize withToolTemplate:(id)aTemplate color:(id)aColor settingsWrapperDelegate:(id)aDelegate;
- (id)hyperPreviewImageOfSize:(NSSize)aSize touchesProvider:(id)aProvider;
@end

