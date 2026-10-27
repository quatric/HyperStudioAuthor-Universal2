#import "HSBrushTouchesStorage.h"
@implementation HSBrushTouchesStorage
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (void)addTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aDeviation rotationAngleDeviation:(CGFloat)aDeviation2 opacityDeviation:(CGFloat)aDeviation3 alternateColor:(BOOL)aColor colorHSVADeviation:(id)aDeviation4 colorNativeDeviation:(id)aDeviation5 shadowColorHSVADeviation:(id)aDeviation6 shadowColorNativeDeviation:(id)aDeviation7
{
    [super addTouchAtPoint:aPoint withSizeDeviation:aDeviation rotationAngleDeviation:aDeviation2 opacityDeviation:aDeviation3
            alternateColor:aColor colorHSVADeviation:aDeviation4 colorNativeDeviation:aDeviation5
  shadowColorHSVADeviation:aDeviation6 shadowColorNativeDeviation:aDeviation7];
    [_delegate touchStorageDidAddTouch:self];
}
@end

@implementation BTBrushTool (HSExtensions)
+ (id)hyperPreviewImageOfSize:(NSSize)aSize withToolTemplate:(id)aTemplate color:(id)aColor settingsWrapperDelegate:(id)aDelegate
{
    // A single dab in the middle of the preview, cached per preview size.
    static NSSize sTouchesSize;
    static BTBrushTouchStorage *sTouches;
    BTBrushTool *tool = [[[self class] new] autorelease];
    [tool setInputs:[BTToolSettingsSerialization toolInputsWithDictionaryRepresentation:aTemplate delegate:aDelegate]];
    [tool setColor:[BTPointer wrapperForPointer:CGEColorRetain([aColor BT_coreGraphicsExtendedColor]) withDisposer:CGEColorRelease]];
    if (!NSEqualSizes(sTouchesSize, aSize)) {
        [sTouches release];
        sTouches = [BTBrushTouchStorage new];
        sTouchesSize = aSize;
        // The original records with a fresh, unconfigured tool rather than |tool|.
        BTBrushTool *recorder = [[[self class] new] autorelease];
        CGPoint center = CGPointMake(aSize.width * 0.5f, aSize.height * 0.5f);
        [recorder recordAlongPolylineWithPoints:&center count:1 withAlternateColor:NO withPressure:1.0f to:sTouches];
    }
    return [tool hyperPreviewImageOfSize:aSize touchesProvider:sTouches];
}
- (id)hyperPreviewImageOfSize:(NSSize)aSize touchesProvider:(id)aProvider
{
    NSImage *image = [[NSImage alloc] initWithSize:aSize];
    [image lockFocus];
    [self drawWithTouchProvider:aProvider
                      inContext:[[NSGraphicsContext currentContext] CGContext]
                     withBounds:CGRectMake(CGPointZero.x, CGPointZero.y, aSize.width, aSize.height)];
    [image unlockFocus];
    return [image autorelease];
}
@end
