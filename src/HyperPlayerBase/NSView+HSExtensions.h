#import "HyperPlayerBasePrefix.h"


@interface NSView (HSExtensions)
- (id)hyperDeepestSubview;
- (void)hyperRemoveAllSubviews;
- (void)setNeedsHyperDisplayInRegion:(id)aRegion;
- (void)setHyperEnabled:(BOOL)aEnabled;
- (void)setHyperEnabled:(BOOL)aEnabled includeSelf:(BOOL)aSelf;
- (void)hyperCacheInSize:(NSSize)aSize fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheImageRep:(id *)aRep resultCacheTransform:(id *)aTransform;
- (void)hyperDrawInRect:(NSRect)aRect fromRect:(NSRect)aRect2 flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling;
- (id)hyperImage;
- (BOOL)shouldUseOffscreenWindow;
- (id)NSView_HSExtensions_bitmapImageRepInSize:(NSSize)aSize fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheTransform:(id *)aTransform;
- (void)NSView_HSExtensions_drawInSize:(NSSize)aSize toWindow:(id)aWindow fromRect:(NSRect)aRect flipped:(BOOL)aFlipped withIntegralScaling:(BOOL)aScaling resultCacheImageRep:(id *)aRep resultCacheTransform:(id *)aTransform;
- (NSSize)NSView_HSExtensions_cacheSizeForCachingRect:(NSRect)aRect inSize:(NSSize)aSize withIntegralScaling:(BOOL)aScaling cacheScale:(NSSize *)aScale integralCacheOffset:(NSSize *)aOffset compensationScale:(NSSize *)aScale2 compensationOffset:(NSSize *)aOffset2;
- (void)hyperSetNeedsDisplayInRect:(NSRect)aRect;
- (NSSize)hyperIntegralScaleFactorForScaleFactor:(NSSize)aFactor;
@end

