#import "HSGenericRenderDelegate.h"

// Bridges renderers to a drawable and a render cache controller; draws from
// a cache when one is available. While caches are being created the counter
// is nonzero and the drawable is not told about drawing.
@implementation HSGenericRenderDelegate
+ (id)delegateWithDrawable:(id)aDrawable
{
    return [[[self alloc] initWithDrawable:aDrawable] autorelease];
}
- (void)renderer:(id)aRenderer didRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath
{
    [_drawable renderer:aRenderer didRenderRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:self];
}
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache
{
    _isCreatingRenderCacheCounter--;
    if (aCache)
        [[self renderCacheController] addRenderCache:aCache];
}
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache
{
    if (!aCache && _isCreatingRenderCacheCounter == 0)
        [_drawable renderer:aRenderer didDrawRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:self];
}
- (void)renderer:(id)aRenderer didCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(id)aCache
{
    _isCreatingRenderCacheCounter--;
    if (aCache)
        [[self renderCacheController] addRenderCache:aCache];
}
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath
{
    _isCreatingRenderCacheCounter++;
    return nil;
}
// Returns NO when it drew the region itself from a cache.
- (BOOL)renderer:(id)aRenderer shouldDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath intoRenderCache:(BOOL)aCache
{
    if (!aCache && _isCreatingRenderCacheCounter == 0 && _drawable && ![_drawable renderer:aRenderer shouldDrawRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:self])
        return NO;
    id cache = [self HSGenericRenderDelegate_renderCacheForRegion:aRegion ofRenderLayerAtIndexPath:aPath inRenderLayerTreeOfRenderer:aRenderer blockingCreation:aCache];
    if (!cache)
        return YES;
    [cache drawRegion:aRegion];
    if (!aCache && _isCreatingRenderCacheCounter == 0)
        [_drawable renderer:aRenderer didDrawRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:self];
    return NO;
}
- (id)renderer:(id)aRenderer willCacheDrawingInRegion:(id)aRegion forRenderLayerAtIndexPath:(id)aPath
{
    _isCreatingRenderCacheCounter++;
    id cache = [self HSGenericRenderDelegate_renderCacheForRegion:aRegion ofRenderLayerAtIndexPath:aPath inRenderLayerTreeOfRenderer:aRenderer blockingCreation:YES];
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:cache, nil], @"HSProposedRenderCachesKey", nil];
}
// Option bit 1 blocks cache creation; the drawable may adjust the options
// and validness limit or veto the query.
- (id)HSGenericRenderDelegate_renderCacheForRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath inRenderLayerTreeOfRenderer:(id)aRenderer blockingCreation:(BOOL)aCreation
{
    int options = (aCreation || _isCreatingRenderCacheCounter != 0) ? 1 : 0;
    float limit = 1.0f;
    if (_drawable && ![_drawable renderDelegate:self willQueryRenderCacheForRegion:aRegion ofRenderLayerAtIndexPath:aPath inRenderer:aRenderer withOptions:&options acceptableValidnessLimit:&limit])
        return nil;
    if (aCreation)
        options |= 1;
    id role = nil;
    id layer = [[aRenderer rootRenderLayer] renderLayerAtIndexPath:aPath role:&role];
    id layerDelegate = [HSGenericRenderLayerDelegate delegateWithRenderDelegate:self renderer:aRenderer renderLayerIndexPath:aPath];
    BOOL isPrivateGroup = [role isEqualToString:@"HSPrivateGroupRenderLayerRole"];
    if (!isPrivateGroup)
        _isCreatingRenderCacheCounter++;
    id cache = [[self renderCacheController] renderCacheForRegion:aRegion ofRenderLayer:layer withRenderLayerDelegate:layerDelegate acceptableValidnessLimit:limit options:options];
    if (!isPrivateGroup)
        _isCreatingRenderCacheCounter--;
    return cache;
}
- (BOOL)renderer:(id)aRenderer shouldRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath
{
    if (!_drawable)
        return YES;
    return [_drawable renderer:aRenderer shouldRenderRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:self];
}
- (void)setRenderCacheController:(id)aController
{
    if (_renderCacheController != aController) {
        [_renderCacheController release];
        _renderCacheController = [aController retain];
    }
    _isRenderCacheControllerSet = 1;
}
// Defaults to a controller that only reuses caches.
- (id)renderCacheController
{
    if (!_isRenderCacheControllerSet) {
        _renderCacheController = [[HSGenericRenderCacheController alloc] init];
        [_renderCacheController setMayCreateCaches:NO];
        _isRenderCacheControllerSet = 1;
    }
    return _renderCacheController;
}
- (void)clearDrawable
{
    _drawable = nil;
}
- (id)drawable
{
    return _drawable;
}
- (void)dealloc
{
    [_renderCacheController release];
    [super dealloc];
}
// The drawable is not retained.
- (id)initWithDrawable:(id)aDrawable
{
    self = [super init];
    if (self)
        _drawable = aDrawable;
    return self;
}
- (id)init
{
    return [self initWithDrawable:nil];
}
@end

@implementation NSObject (HSRenderDelegateDrawable)
- (BOOL)renderDelegate:(id)aDelegate willQueryRenderCacheForRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath inRenderer:(id)aRenderer withOptions:(int *)aOptions acceptableValidnessLimit:(float *)aLimit
{
    return YES;
}
- (void)renderer:(id)aRenderer didRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
}
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
}
- (BOOL)renderer:(id)aRenderer shouldDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
    return YES;
}
- (BOOL)renderer:(id)aRenderer shouldRenderRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
    return YES;
}
@end
