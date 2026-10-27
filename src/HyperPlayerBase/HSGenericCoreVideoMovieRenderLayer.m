#import "HSGenericCoreVideoMovieRenderLayer.h"
// Draws a movie object's current frame through its movie renderer, keying
// out the transparent colour (not for QTVR or panoramas). Cached when a
// colour is keyed out with a tolerance below the maximum (255/255.5), and
// empty when every colour would be keyed out.
@implementation HSGenericCoreVideoMovieRenderLayer
static const double HSMaximumTolerance = 0.9980392156862745;

- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce
{
    return [self willCacheRenderingInRegion:aRegion force:aForce];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    if ([_movieObjectAttributes isHyperQTVR] || [_movieObjectAttributes isHyperPanoramaObject]
        || ![_transparentColorAttributes isTransparentColorEnabled]
        || [_transparentColorAttributes transparentColor] == nil)
        return NO;
    return [_transparentColorAttributes hueTolerance] < HSMaximumTolerance
        || [_transparentColorAttributes chromaTolerance] < HSMaximumTolerance
        || [_transparentColorAttributes lightnessTolerance] < HSMaximumTolerance;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect movieRect = [_movieAttributes movieRect];
    NSRect sourceRect = [_movieAttributes relativeMovieSourceRect];
    id transparentColor = nil;
    if (![_movieObjectAttributes isHyperQTVR] && ![_movieObjectAttributes isHyperPanoramaObject]
        && [_transparentColorAttributes isTransparentColorEnabled])
        transparentColor = [_transparentColorAttributes transparentColor];
    // Flip vertically within the movie rect.
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0,
                                                      (float)(movieRect.origin.y * 2 + movieRect.size.height)));
    [(HSMovieOpenGLRenderer *)[_movieAttributes movieRenderer]
        drawCurrentFrameInRect:movieRect
              fromRelativeRect:sourceRect
          withTransparentColor:transparentColor
                  hueTolerance:[_transparentColorAttributes hueTolerance]
               chromaTolerance:[_transparentColorAttributes chromaTolerance]
            lightnessTolerance:[_transparentColorAttributes lightnessTolerance]];
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_movieAttributes movieRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSMovieRectAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return NO;
}
- (BOOL)isEmpty
{
    return ![_movieObjectAttributes isHyperQTVR] && ![_movieObjectAttributes isHyperPanoramaObject]
        && [_transparentColorAttributes isTransparentColorEnabled]
        && [_transparentColorAttributes transparentColor] != nil
        && [_transparentColorAttributes hueTolerance] >= HSMaximumTolerance
        && [_transparentColorAttributes chromaTolerance] >= HSMaximumTolerance
        && [_transparentColorAttributes lightnessTolerance] >= HSMaximumTolerance;
}
- (void)HSGenericCoreVideoMovieRenderLayer_transparentColorEnablementDidChange:(id)aChange
{
    [self visualizationMaskAttributesSetDidChange:nil];
}
- (void)HSGenericCoreVideoMovieRenderLayer_mediaDidChange:(id)aChange
{
    [self visualizationMaskAttributesSetDidChange:nil];
}
// The frame content counts too unless the movie is opaque and nothing is
// keyed out.
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSMediaAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorEnabledAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorHueToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) forObject:object];
    if ([[_movieObjectAttributes hyperMovie] isOpaque]
        && ([_movieObjectAttributes isHyperQTVR] || [_movieObjectAttributes isHyperPanoramaObject]
            || ![_transparentColorAttributes isTransparentColorEnabled]
            || [_transparentColorAttributes transparentColor] == nil))
        return;
    [aSet addAttribute:@protocol(HSMovieFrameContentAttribute) forObject:object];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSMediaAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieFrameContentAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorEnabledAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorHueToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) forObject:object];
}
- (void)dealloc
{
    id controller = [_movieAttributes attributeObservingController];
    [controller removeObserver:self
                      selector:@selector(HSGenericCoreVideoMovieRenderLayer_mediaDidChange:)
                     ofChanges:HSActualDidAttributeChanges
                   ofAttribute:@protocol(HSMediaAttribute)];
    Protocol *transparencyAttributes[] = { @protocol(HSTransparentColorEnabledAttribute),
                                           @protocol(HSTransparentColorAttribute), nil };
    [controller removeObserver:self
                      selector:@selector(HSGenericCoreVideoMovieRenderLayer_transparentColorEnablementDidChange:)
                     ofChanges:HSActualDidAttributeChanges
                  ofAttributes:(id *)transparencyAttributes];
    [_movieAttributes release];
    [_movieObjectAttributes release];
    [_transparentColorAttributes release];
    [super dealloc];
}
// Needs the movie, movie object and transparent colour interfaces.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _movieAttributes = [[aObject queryHyperInterface:@protocol(HSMovieAttributes)] retain];
    if (_movieAttributes != nil)
        _movieObjectAttributes = [[aObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] retain];
    if (_movieObjectAttributes != nil)
        _transparentColorAttributes = [[aObject queryHyperInterface:@protocol(HSTransparentColorAttributes)] retain];
    if (_transparentColorAttributes == nil) {
        [self release];
        return nil;
    }
    id controller = [_movieAttributes attributeObservingController];
    [controller addObserver:self
                   selector:@selector(HSGenericCoreVideoMovieRenderLayer_mediaDidChange:)
                  ofChanges:HSActualDidAttributeChanges
                ofAttribute:@protocol(HSMediaAttribute)
               withPriority:0.25];
    Protocol *transparencyAttributes[] = { @protocol(HSTransparentColorEnabledAttribute),
                                           @protocol(HSTransparentColorAttribute), nil };
    [controller addObserver:self
                   selector:@selector(HSGenericCoreVideoMovieRenderLayer_transparentColorEnablementDidChange:)
                  ofChanges:HSActualDidAttributeChanges
               ofAttributes:(id *)transparencyAttributes
               withPriority:0.25];
    return self;
}
@end
