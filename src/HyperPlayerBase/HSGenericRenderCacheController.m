#import "HSGenericRenderCacheController.h"

// Owns the render caches of render layers: picks the best cache for a
// region/transform, creates caches when allowed, discards caches that miss
// too often, and keeps the total cache size under a memory-based budget
// (least recently used caches go first).
@implementation HSGenericRenderCacheController
- (void)renderCacheDidChangeValidness:(id)aValidness
{
    if (_renderCaches == nil)
        return;
    id cache = [(NSNotification *)aValidness object];
    float validness = [cache persistentValidness];
    if ([[(NSNotification *)aValidness name] isEqualToString:@"HSRenderCacheDidChangeTemporaryValidness"])
        validness = MAX(validness, (float)[cache validness]);
    if (validness < [self storableValidnessLimit])
        [self HSGenericRenderCacheController_discardRenderCache:cache];
}
- (void)discardAllRenderCachesForRenderLayer:(id)aLayer
{
    if (_renderCaches == nil)
        return;
    id caches = NSMapGet(_renderCaches, aLayer);
    if (caches) {
        [self HSGenericRenderCacheController_prepareToDiscardRenderCaches:caches];
        NSMapRemove(_renderCaches, aLayer);
        [aLayer unregisterWeakReferencer:self];
    }
}
- (void)discardRenderCache:(id)aCache
{
    if (_renderCaches)
        [self HSGenericRenderCacheController_discardRenderCache:aCache];
}
- (void)addRenderCache:(id)aCache
{
    if ([self HSGenericRenderCacheController_initializeMaps]) {
        id layer = [aCache renderLayer];
        [self HSGenericRenderCacheController_addRenderCache:aCache forRenderLayer:layer toSet:NSMapGet(_renderCaches, layer)];
    }
}
- (id)renderCacheForRegion:(id)aRegion ofRenderLayer:(id)aLayer withRenderLayerDelegate:(id)aDelegate acceptableValidnessLimit:(CGFloat)aLimit options:(NSInteger)aOptions
{
    if (![self HSGenericRenderCacheController_initializeMaps])
        return nil;
    id result = nil;
    float acceptableLimit = (float)aLimit;
    CGAffineTransform transform = [[NSGraphicsContext currentContext] currentHyperCGAffineTransform];
    NSScreen *screen = [NSScreen mainScreen];
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        float scale = (float)[screen backingScaleFactor];
        transform.a *= scale;
        transform.b *= scale;
        transform.c *= scale;
        transform.d *= scale;
        transform.tx *= scale;
        transform.ty *= scale;
    }

    // Candidates: this layer's own caches plus caches shared with other layers.
    NSMutableSet *ownCaches = NSMapGet(_renderCaches, aLayer);
    NSArray *sharedCaches = [aLayer sharedRenderCaches];
    NSMutableSet *candidates = [NSMutableSet set];
    if (ownCaches)
        [candidates unionSet:ownCaches];
    if (sharedCaches)
        [candidates addObjectsFromArray:sharedCaches];
    float bestValidness = 0.0f;
    for (id cache in [[candidates objectEnumerator] allObjects]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        BOOL coversRegion = [cache containsWholeRenderLayer];
        if (!coversRegion && aRegion)
            coversRegion = [cache containsRegion:aRegion];
        if (!coversRegion) {
            NSUInteger misses = (NSUInteger)NSMapGet(_renderCacheRegionMisses, cache) + 1;
            if (misses > _renderCacheRegionMissLimit) {
                [self HSGenericRenderCacheController_discardRenderCache:cache];
            } else {
                NSMapInsert(_renderCacheRegionMisses, cache, (void *)misses);
                if ((float)[cache validnessForAffineTransform:transform] < acceptableLimit)
                    [self HSGenericRenderCacheController_handleValidnessMissForRenderCache:cache];
            }
        } else {
            float validness = (float)[cache validnessForAffineTransform:transform];
            if (validness < acceptableLimit) {
                [self HSGenericRenderCacheController_handleValidnessMissForRenderCache:cache];
            } else if (result == nil || bestValidness < validness) {
                bestValidness = validness;
                result = cache;
            }
        }
        [pool release];
    }

    if (result) {
        if ([ownCaches containsObject:result]) {
            NSMapInsert(_renderCacheRegionMisses, result, 0);
            NSMapInsert(_renderCacheValidnessMisses, result, 0);
        } else if ((float)[result validness] >= (float)[self storableValidnessLimit] && ownCaches) {
            // Adopt a shared cache good enough to keep.
            [ownCaches addObject:result];
            [self noteRenderCasheUsed:result];
        }
        return result;
    }

    if ((aOptions & 1) || !_mayCreateCaches)
        return nil;
    // Tell the layer which transformations are being changed continuously
    // (live resizing/rotation) so the cache can be made reusable for them.
    struct HyperPlayerBase_anon12 intent = { 0, 0, 0, 0, 0 };
    id visualizationAttributes = [aLayer continuousChangeSensitiveVisualizationAttributes];
    for (id object in [visualizationAttributes objectEnumerator]) {
        id changing = [[[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] attributesBeingChangedContinuously];
        if ([changing containsProtocol:@protocol(HSWidthScaleAttribute)]
            || [changing containsProtocol:@protocol(HSHeightScaleAttribute)]
            || [changing containsProtocol:@protocol(HSHorizontalScaleAttribute)]
            || [changing containsProtocol:@protocol(HSVerticalScaleAttribute)])
            intent.f0 = 1;
        if ([changing containsProtocol:@protocol(HSRotationAngleAttribute)])
            intent.f1 = 3;
        if (![visualizationAttributes excludesAttributeSet:changing forObject:object])
            return nil;
    }
    id region = aRegion;
    if (!_mayCreatePartialCaches)
        region = [aLayer boundingRegion];
    id createdCache = nil;
    [aLayer cacheRenderingInRegion:region forAffineTransform:transform withTransformationIntent:&intent
          acceptableValidnessLimit:aLimit delegate:aDelegate force:(aOptions >> 1) & 1 share:YES resultCache:&createdCache];
    if (createdCache == nil)
        return nil;
    [self HSGenericRenderCacheController_addRenderCache:createdCache forRenderLayer:aLayer toSet:ownCaches];
    [self noteRenderCasheUsed:createdCache];
    return createdCache;
}
- (void)noteRenderCasheUsed:(id)aUsed
{
    if (aUsed == nil)
        return;
    struct HSGenericRenderCacheController_orderedRenderCash *entry;
    if (_renderCashesList && (entry = NSMapGet(_renderCashesList, aUsed)) != NULL) {
        // Move to the most recently used end.
        [self HSGenericRenderCacheController_removeOrderedRenderCashFromList:entry];
        [self HSGenericRenderCacheController_addOrderedRenderCashToList:entry];
        return;
    }
    entry = malloc(sizeof(*entry));
    if (entry == NULL)
        return;
    entry->f0 = aUsed;
    entry->f1 = NULL;
    entry->f2 = NULL;
    [self HSGenericRenderCacheController_addOrderedRenderCashToList:entry];
    if (_renderCashesList)
        NSMapInsert(_renderCashesList, entry->f0, entry);
}
- (id)renderCacheForRenderLayer:(id)aLayer
{
    return [self renderCacheForRegion:nil ofRenderLayer:aLayer withRenderLayerDelegate:nil acceptableValidnessLimit:1.0 options:0];
}
- (void)setMayCreateCaches:(BOOL)aCaches
{
    _mayCreateCaches = aCaches ? 1 : 0;
}
- (BOOL)mayCreateCaches
{
    return _mayCreateCaches;
}
- (CGFloat)storableValidnessLimit
{
    if (!_isStorableValidnessLimitCalculated) {
        // The original tests the limits map the wrong way round: with limits
        // registered it uses 1.0, and without them it takes the minimum over
        // an empty enumeration (10000 / 10000). Either way the result is 1.0.
        _storableValidnessLimit = 1.0f;
        _isStorableValidnessLimitCalculated = 1;
    }
    return _storableValidnessLimit;
}
- (void)releaseWithStorableValidnessLimit:(CGFloat)aLimit
{
    if (_storableValidnessLimits == nil)
        return;
    NSUInteger key = (NSUInteger)lroundf((float)aLimit * 10000.0f);
    NSUInteger count = (NSUInteger)NSMapGet(_storableValidnessLimits, (void *)key);
    if (count == 0)
        return;
    if (count == 1) {
        NSMapRemove(_storableValidnessLimits, (void *)key);
        _isStorableValidnessLimitCalculated = 0;
    } else {
        NSMapInsert(_storableValidnessLimits, (void *)key, (void *)(count - 1));
    }
    [self release];
}
- (id)retainWithStorableValidnessLimit:(CGFloat)aLimit
{
    NSUInteger key = (NSUInteger)lroundf((float)aLimit * 10000.0f);
    NSUInteger count;
    if (_storableValidnessLimits == nil) {
        _storableValidnessLimits = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
        if (_storableValidnessLimits == nil)
            return nil;
        count = 1;
    } else {
        count = (NSUInteger)NSMapGet(_storableValidnessLimits, (void *)key) + 1;
    }
    NSMapInsert(_storableValidnessLimits, (void *)key, (void *)count);
    float limit = (float)((double)key * 0.0001);
    if (_isStorableValidnessLimitCalculated && limit < _storableValidnessLimit)
        _storableValidnessLimit = limit;
    return [self retain];
}
- (void)dereferenceObject:(id)aObject
{
    if (_renderCaches == nil)
        return;
    id caches = NSMapGet(_renderCaches, aObject);
    if (caches) {
        [self HSGenericRenderCacheController_prepareToDiscardRenderCaches:caches];
        [[caches retain] autorelease];
        NSMapRemove(_renderCaches, aObject);
    }
}
- (void)dealloc
{
    if (_renderCacheRegionMisses)
        NSFreeMapTable(_renderCacheRegionMisses);
    if (_renderCacheValidnessMisses)
        NSFreeMapTable(_renderCacheValidnessMisses);
    if (_storableValidnessLimits)
        NSFreeMapTable(_storableValidnessLimits);
    if (_renderCashesList)
        NSFreeMapTable(_renderCashesList);
    while (_orderedRenderCashListHead) {
        struct HSGenericRenderCacheController_orderedRenderCash *next = _orderedRenderCashListHead->f1;
        free(_orderedRenderCashListHead);
        _orderedRenderCashListHead = next;
    }
    if (_renderCaches) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:@"HSRenderCacheDidChangePersistentValidness" object:nil];
        [center removeObserver:self name:@"HSRenderCacheDidChangeTemporaryValidness" object:nil];
        NSMapEnumerator enumerator = NSEnumerateMapTable(_renderCaches);
        void *layer;
        while (NSNextMapEnumeratorPair(&enumerator, &layer, NULL))
            [(id)layer unregisterWeakReferencer:self];
        NSEndMapTableEnumeration(&enumerator);
        NSFreeMapTable(_renderCaches);
    }
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _storableValidnessLimit = 1.0f;
        _mayCreateCaches = 1;
        _isStorableValidnessLimitCalculated = 1;
        _renderCacheValidnessMissLimit = 10;
    }
    return self;
}
- (void)HSGenericRenderCacheController_addOrderedRenderCashToList:(struct HSGenericRenderCacheController_orderedRenderCash *)aList
{
    if (aList == NULL)
        return;
    aList->f1 = NULL;
    aList->f2 = NULL;
    if (_orderedRenderCashListLast == NULL)
        _orderedRenderCashListHead = aList;
    else
        _orderedRenderCashListLast->f1 = aList;
    aList->f2 = _orderedRenderCashListLast;
    _orderedRenderCashListLast = aList;
}
- (void)HSGenericRenderCacheController_removeOrderedRenderCashFromList:(struct HSGenericRenderCacheController_orderedRenderCash *)aList
{
    if (aList == NULL)
        return;
    struct HSGenericRenderCacheController_orderedRenderCash *next = aList->f1;
    struct HSGenericRenderCacheController_orderedRenderCash *previous = aList->f2;
    if (next)
        next->f2 = previous;
    if (previous)
        previous->f1 = next;
    if (next == NULL)
        _orderedRenderCashListLast = previous;
    if (previous == NULL)
        _orderedRenderCashListHead = next;
    aList->f1 = NULL;
    aList->f2 = NULL;
}
// Keeps the total cache size within a quarter of the physical memory,
// at most 128 MB, discarding the least recently used caches.
- (void)HSGenericRenderCacheController_prepareToAddRenderCashe:(id)aCashe
{
    static NSUInteger sCacheBudget;
    if (sCacheBudget == 0) {
        // Original: Gestalt('ram ') as a signed 32-bit value.
        unsigned long long memory = [[NSProcessInfo processInfo] physicalMemory];
        sCacheBudget = memory > 0x20000003ULL ? 0x8000000 : (NSUInteger)(memory / 4);
    }
    _totalRenderCashesSize += (unsigned int)[aCashe cashSize];
    while (_totalRenderCashesSize > sCacheBudget && _orderedRenderCashListHead) {
        id oldest = _orderedRenderCashListHead->f0;
        if (oldest) {
            _totalRenderCashesSize -= (unsigned int)[oldest cashSize];
            [self HSGenericRenderCacheController_discardRenderCache:oldest];
        }
    }
}
- (void)HSGenericRenderCacheController_handleValidnessMissForRenderCache:(id)aCache
{
    if ((float)[aCache persistentValidness] > (float)[aCache validness])
        return;
    NSUInteger misses = (NSUInteger)NSMapGet(_renderCacheValidnessMisses, aCache) + 1;
    if (misses > _renderCacheValidnessMissLimit)
        [self HSGenericRenderCacheController_discardRenderCache:aCache];
    else
        NSMapInsert(_renderCacheValidnessMisses, aCache, (void *)misses);
}
- (void)HSGenericRenderCacheController_discardRenderCache:(id)aCache
{
    [self HSGenericRenderCacheController_prepareToDiscardRenderCache:aCache withNotificationCenter:[NSNotificationCenter defaultCenter]];
    [(NSMutableSet *)NSMapGet(_renderCaches, [aCache renderLayer]) removeObject:aCache];
}
- (void)HSGenericRenderCacheController_prepareToDiscardRenderCaches:(id)aCaches
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (id cache in [[aCaches objectEnumerator] allObjects])
        [self HSGenericRenderCacheController_prepareToDiscardRenderCache:cache withNotificationCenter:center];
}
- (void)HSGenericRenderCacheController_prepareToDiscardRenderCache:(id)aCache withNotificationCenter:(id)aCenter
{
    [aCenter removeObserver:self name:@"HSRenderCacheDidChangePersistentValidness" object:aCache];
    [aCenter removeObserver:self name:@"HSRenderCacheDidChangeTemporaryValidness" object:aCache];
    if (_renderCacheRegionMisses)
        NSMapRemove(_renderCacheRegionMisses, aCache);
    if (_renderCacheValidnessMisses)
        NSMapRemove(_renderCacheValidnessMisses, aCache);
    if (_renderCashesList) {
        struct HSGenericRenderCacheController_orderedRenderCash *entry = NSMapGet(_renderCashesList, aCache);
        if (entry) {
            [self HSGenericRenderCacheController_removeOrderedRenderCashFromList:entry];
            free(entry);
        }
        NSMapRemove(_renderCashesList, aCache);
    }
}
- (void)HSGenericRenderCacheController_addRenderCache:(id)aCache forRenderLayer:(id)aLayer toSet:(id)aSet
{
    if (aSet == nil) {
        aSet = [NSMutableSet set];
        if (aSet == nil)
            return;
        NSMapInsert(_renderCaches, aLayer, aSet);
        [aLayer registerWeakReferencer:self];
    }
    [self HSGenericRenderCacheController_prepareToAddRenderCashe:aCache];
    [aSet addObject:aCache];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(renderCacheDidChangeValidness:) name:@"HSRenderCacheDidChangePersistentValidness" object:aCache];
    [center addObserver:self selector:@selector(renderCacheDidChangeValidness:) name:@"HSRenderCacheDidChangeTemporaryValidness" object:aCache];
}
- (BOOL)HSGenericRenderCacheController_initializeMaps
{
    // Layer -> set of caches (layers held weakly), cache -> miss counters,
    // cache -> LRU list entry.
    if (_renderCaches == nil
        && (_renderCaches = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0)) == nil)
        return NO;
    if (_renderCacheRegionMisses == nil
        && (_renderCacheRegionMisses = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0)) == nil)
        return NO;
    if (_renderCacheValidnessMisses == nil
        && (_renderCacheValidnessMisses = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0)) == nil)
        return NO;
    if (_renderCashesList == nil)
        return (_renderCashesList = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0)) != nil;
    return YES;
}
@end
