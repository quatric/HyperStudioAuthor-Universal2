#import "HSGenericRenderLayerDelegate.h"
// Render layer delegate that forwards each rendering event to the render
// delegate, together with the renderer and the layer's index path. Sublayer
// delegates extend the index path.

@implementation HSGenericRenderLayerDelegate

+ (id)delegateWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer renderLayerIndexPath:(id)aPath
{
    return [[[self alloc] initWithRenderDelegate:aDelegate renderer:aRenderer renderLayerIndexPath:aPath] autorelease];
}

+ (id)delegateWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer
{
    return [[[self alloc] initWithRenderDelegate:aDelegate renderer:aRenderer] autorelease];
}

- (void)renderLayerIsRenderedInRegion:(id)aRegion
{
    [_renderDelegate renderer:_renderer didRenderRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath];
}

- (void)renderLayerDrawingIsCachedInRegion:(id)aRegion intoRenderCache:(id)aCache
{
    [_renderDelegate renderer:_renderer didCacheDrawingInRegion:aRegion forRenderLayerAtIndexPath:_renderLayerIndexPath intoRenderCache:aCache];
}

- (void)renderLayerIsDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache
{
    [_renderDelegate renderer:_renderer didDrawRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath intoRenderCache:aCache];
}

- (void)renderLayerDidCacheDrawingInRegion:(id)aRegion intoRenderCache:(id)aCache
{
    [_renderDelegate renderer:_renderer didCacheDrawingInRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath intoRenderCache:aCache];
}

- (id)renderLayerWillCacheDrawingInRegion:(id)aRegion
{
    return [_renderDelegate renderer:_renderer willCacheDrawingInRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath];
}

- (BOOL)renderLayerShouldBeDrawnInRegion:(id)aRegion intoRenderCache:(BOOL)aCache
{
    return [_renderDelegate renderer:_renderer shouldDrawRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath intoRenderCache:aCache];
}

- (id)renderLayerDrawingWillBeCachedInRegion:(id)aRegion
{
    return [_renderDelegate renderer:_renderer willCacheDrawingInRegion:aRegion forRenderLayerAtIndexPath:_renderLayerIndexPath];
}

- (BOOL)renderLayerShouldBeRenderedInRegion:(id)aRegion
{
    return [_renderDelegate renderer:_renderer shouldRenderRegion:aRegion ofRenderLayerAtIndexPath:_renderLayerIndexPath];
}

- (id)delegateForRenderSublayerAtIndex:(NSUInteger)aIndex
{
    id path = [_renderLayerIndexPath indexPathByAddingIndex:aIndex];
    if (!path)
        return nil;
    return [[self class] delegateWithRenderDelegate:_renderDelegate renderer:_renderer renderLayerIndexPath:path];
}

- (id)renderLayer
{
    if (!_renderLayer)
        _renderLayer = [[[_renderer rootRenderLayer] renderLayerAtIndexPath:_renderLayerIndexPath role:0] retain];
    return _renderLayer;
}

- (void)dealloc
{
    [_renderLayer release];
    [_renderDelegate release];
    [_renderer release];
    [_renderLayerIndexPath release];
    [super dealloc];
}

- (id)initWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer renderLayerIndexPath:(id)aPath
{
    self = [super init];
    if (self) {
        _renderLayerIndexPath = [aPath copy];
        if (!aPath) {
            [super release];
            return nil;
        }
        _renderDelegate = [aDelegate retain];
        _renderer = [aRenderer retain];
    }
    return self;
}

- (id)initWithRenderDelegate:(id)aDelegate renderer:(id)aRenderer
{
    return [self initWithRenderDelegate:aDelegate renderer:aRenderer renderLayerIndexPath:[[[HSIndexPath alloc] init] autorelease]];
}

// A delegate needs a renderer.
- (id)init
{
    [super release];
    return nil;
}

@end
