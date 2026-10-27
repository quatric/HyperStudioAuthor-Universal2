#import "HSImageObjectsOptimizer.h"

static float HSOptimizerMagnitude(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

// Within 0.0005 of the larger magnitude (zero counting as 1).
static BOOL HSOptimizerFloatsAreEqual(float aValue, float aValue2)
{
    return fabsf(aValue - aValue2) <= MAX(HSOptimizerMagnitude(aValue), HSOptimizerMagnitude(aValue2)) * 0.0005f;
}

// Each axis is compared relative to the larger |origin| + size.
static BOOL HSOptimizerRectsAreEqual(NSRect aRect, NSRect aRect2)
{
    float xMagnitude = MAX(HSOptimizerMagnitude(fabsf((float)aRect.origin.x) + aRect.size.width), HSOptimizerMagnitude(fabsf((float)aRect2.origin.x) + aRect2.size.width));
    float yMagnitude = MAX(HSOptimizerMagnitude(fabsf((float)aRect.origin.y) + aRect.size.height), HSOptimizerMagnitude(fabsf((float)aRect2.origin.y) + aRect2.size.height));
    return fabsf((float)(aRect.origin.x - aRect2.origin.x)) <= xMagnitude * 0.0005f
        && fabsf((float)(aRect.origin.y - aRect2.origin.y)) <= yMagnitude * 0.0005f
        && fabsf((float)(aRect.size.width - aRect2.size.width)) <= xMagnitude * 0.0005f
        && fabsf((float)(aRect.size.height - aRect2.size.height)) <= yMagnitude * 0.0005f;
}

@implementation HSImageObjectsOptimizer

+ (BOOL)canConsolidateObject:(id)aObject
{
    id imageObject = [aObject queryHyperInterface:@protocol(HSImageObjectAttributes)];
    if (imageObject == nil || ![imageObject canBeOptimized])
        return NO;
    NSRect rect = [imageObject relativeImageRect];
    if (rect.size.width <= 1.01 && rect.size.height <= 1.01 && -0.01 <= rect.origin.x && -0.01 <= rect.origin.y) {
        NSSize defaultSize = [[imageObject queryHyperInterface:@protocol(HSSizeAttributes)] defaultSize];
        NSSize size = [(id<HSSizeAttributes>)[imageObject queryHyperInterface:@protocol(HSSizeAttributes)] size];
        if (ceilf(defaultSize.width) <= ceilf(size.width) && ceilf(defaultSize.height) <= ceilf(size.height)
            && [[imageObject queryHyperInterface:@protocol(HSEffectAttributes)] effectSettings] == nil)
            return [imageObject canRestoreToInitialClipPaths];
    }
    return YES;
}

+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    if (aUID != nil && [aObjects count] != 0 && [self isImageObjectsInSet:aObjects])
        return [self canOptimizeImageObjectsInSet:aObjects];
    return NO;
}

// The objects sharing a media must show the same part of it: equal image rects and clip paths.
+ (BOOL)canOptimizeImageObjectsInSet:(id)aSet
{
    if ([aSet count] < 2)
        return YES;
    id first = [aSet anyObject];
    NSRect reference = NSZeroRect;
    id referenceClipPaths = nil;
    NSEnumerator *enumerator = [aSet objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        NSRect rect = [[object queryHyperInterface:@protocol(HSImageObjectAttributes)] imageRect];
        if (HSOptimizerFloatsAreEqual(rect.size.width, NSZeroSize.width) && HSOptimizerFloatsAreEqual(rect.size.height, NSZeroSize.height))
            continue;
        // Original quirk kept: the clip paths are always taken from the same (any) object.
        id clipPaths = [[first queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] clipPaths];
        if (HSOptimizerRectsAreEqual(reference, NSZeroRect)) {
            reference = rect;
            referenceClipPaths = clipPaths;
        }
        if (![referenceClipPaths isEqualToArray:clipPaths])
            return NO;
        if (!HSOptimizerRectsAreEqual(rect, reference))
            return NO;
    }
    return YES;
}

+ (BOOL)isImageObjectsInSet:(id)aSet
{
    if ([aSet count] == 0)
        return NO;
    NSEnumerator *enumerator = [aSet objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if (![object conformsToProtocol:@protocol(HSImageObjectAttributes)] || ![object implementsHyperInterface:@protocol(HSMutableClipPathsAttributes)])
            return NO;
    }
    return YES;
}

- (void)postprocessAfterOptimization
{
    NSEnumerator *enumerator = [[self nonEmptyObjects] objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [[object queryHyperInterface:@protocol(HSImageObjectAttributes)] setShouldUseCurrentMediaAsLegacyCroppedImageMedia:NO];
}

// Replaces the shared media with a PNG of the visible part when that is smaller (or the media
// is effected or cropped), then resets the objects to show all of it.
- (void)optimizeIgnoringDataLength:(BOOL)aLength
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [[self emptyObjects] makeObjectsPerformSelector:@selector(removeFromParent)];
    NSSet *appliers = [self cropAppliers];
    [appliers makeObjectsPerformSelector:@selector(updateEffectedImageObject)];
    NSSize size = NSZeroSize;
    NSData *png = [[[appliers anyObject] croppedImageDrawing] optimizedCurrentImagePNGRepresentationOfSize:&size];
    id imageObject = [[[self nonEmptyObjects] anyObject] queryHyperInterface:@protocol(HSImageObjectAttributes)];
    BOOL replace = png != nil;
    if (!aLength && png != nil && [imageObject hyperEffectedMedia] == nil && ![imageObject canRestoreToInitialClipPaths]) {
        NSUInteger length = [[[[imageObject media] fileRepresentation] mediaData] length];
        if (length == 0)
            length = [[[imageObject media] mediaData] length];
        replace = [png length] < length;
    }
    if (replace) {
        NSString *name = [[imageObject media] mediaName];
        if ([name length] != 0)
            name = [[name stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        id media = [HSNewMedia mediaWithData:png name:name type:@"png"];
        NSEnumerator *enumerator = [[self nonEmptyObjects] objectEnumerator];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            id attributes = [object queryHyperInterface:@protocol(HSImageObjectAttributes)];
            [[attributes queryHyperInterface:@protocol(HSMediaAttributes)] setMedia:media];
            [[attributes queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
            [attributes setRelativeImageRect:NSMakeRect(0.0, 0.0, 1.0, 1.0)];
            [attributes dropInitialClipPaths];
        }
        [appliers makeObjectsPerformSelector:@selector(updateCurrentBorderPath)];
    } else {
        [imageObject setCanBeOptimized:NO];
    }
    NSEnumerator *enumerator = [[self nonEmptyObjects] objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id attributes = [object queryHyperInterface:@protocol(HSImageObjectAttributes)];
        [attributes setCurrentClipPathsAreInitial:NO];
        [attributes setShouldUseCurrentMediaAsLegacyCroppedImageMedia:YES];
    }
    [pool release];
}

- (void)optimize
{
    [self optimizeIgnoringDataLength:NO];
}

- (id)emptyObjects
{
    if (_emptyObjects == nil)
        [self filterObjects];
    return _emptyObjects;
}

- (id)nonEmptyObjects
{
    if (_nonEmptyObjects == nil)
        [self filterObjects];
    return _nonEmptyObjects;
}

// Objects whose image rect has no size show nothing.
- (void)filterObjects
{
    NSMutableSet *emptyObjects = [NSMutableSet new];
    NSMutableSet *nonEmptyObjects = [[NSMutableSet alloc] initWithCapacity:[[self objects] count]];
    for (id object in [self objects]) {
        NSRect rect = [[object queryHyperInterface:@protocol(HSImageObjectAttributes)] imageRect];
        if (HSOptimizerFloatsAreEqual(rect.size.width, NSZeroSize.width) && HSOptimizerFloatsAreEqual(rect.size.height, NSZeroSize.height))
            [emptyObjects addObject:object];
        else
            [nonEmptyObjects addObject:object];
    }
    _emptyObjects = emptyObjects;
    // Fix: the set was retained a second time and leaked.
    _nonEmptyObjects = nonEmptyObjects;
}

- (id)cropAppliers
{
    NSMutableSet *appliers = [NSMutableSet setWithCapacity:[[self nonEmptyObjects] count]];
    NSEnumerator *enumerator = [[self nonEmptyObjects] objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        HSImageCropApplier *applier = [[HSImageCropApplier alloc] initWithImageObject:object];
        if (applier != nil) {
            [appliers addObject:applier];
            // Fix: the appliers were never released.
            [applier release];
        }
    }
    return appliers;
}

- (void)dealloc
{
    [_nonEmptyObjects release];
    [_emptyObjects release];
    [super dealloc];
}

@end
