#import "HyperPlayerBasePrefix.h"


@interface HSEditorZoomController : NSObject
{
}
+ (BOOL)canZoomToActualSizeForZoomFactor:(CGFloat)aFactor;
+ (BOOL)canZoomInForZoomFactor:(CGFloat)aFactor;
+ (BOOL)canZoomOutForZoomFactor:(CGFloat)aFactor;
+ (CGFloat)zoomFactorValueFrom:(id)aFrom;
+ (CGFloat)actualZoomFactor;
+ (CGFloat)maxZoomFactor;
+ (CGFloat)minZoomFactor;
+ (void)nextZoomOutFactor:(float *)aFactor zoomInFactor:(float *)aFactor2 forZoomFactor:(CGFloat)aFactor3;
@end

