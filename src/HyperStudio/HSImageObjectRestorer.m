#import "HSImageObjectRestorer.h"

// Whether aRect is not (0, 0, 1, 1), within 0.001.
static BOOL HSImageRectDiffersFromUnit(NSRect aRect)
{
    return fabs(aRect.origin.x) > 0.001 || fabs(aRect.origin.y) > 0.001 || fabs(aRect.size.width - 1.0) > 0.001 || fabs(aRect.size.height - 1.0) > 0.001;
}

@implementation HSImageObjectRestorer

+ (void)restoreNodeToOriginal:(id)aOriginal
{
    id image = [aOriginal queryHyperInterface:@protocol(HSImageObjectAttributes)];
    if (image == nil)
        return;
    id undoManager = [[[aOriginal queryHyperInterface:@protocol(HSNodeSupportAttributes)] support] undoManager];
    [undoManager setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Restoring to Original Graphic" value:@"" table:@"UndoManager"]];
    BOOL cacheEnabled = [image isEnabledCacheImage];
    if (cacheEnabled)
        [image setEnabledCacheImageForAllGroupObjects:NO setUpUndoManager:YES];
    if ([self canRestoreEffectedImage:image])
        [self restoreEffectedImage:image];
    if ([self canRestoreClippedImage:image])
        [self restoreClippedImage:image];
    if ([self canRestoreImageGeometry:image])
        [self restoreImageGeometry:image];
    if (cacheEnabled)
        [image setEnabledCacheImageForAllGroupObjects:YES setUpUndoManager:YES];
}

+ (void)restoreImageGeometry:(id)aGeometry
{
    id applier = [[aGeometry queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    id geometry = [applier mutableGeometryAttributes];
    if (applier == nil)
        return;
    if (!NSEqualSizes([geometry sizeScale], NSMakeSize(1.0, 1.0)))
        [applier sizeScaleTo:NSMakeSize(1.0, 1.0) aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
    NSSize size = [geometry defaultSize];
    NSRect imageRect = [aGeometry relativeImageRect];
    if (imageRect.size.height != 0.0)
        size.height = size.height / imageRect.size.height;
    if (imageRect.size.width != 0.0)
        size.width = size.width / imageRect.size.width;
    [applier resizeFrameTo:size aboutRelativePoint:NSMakePoint(0.5, 0.5) followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
    NSRect frame = [geometry frameBoundingRect];
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(roundf(frame.origin.x), roundf(frame.origin.y)) withLayoutGuidingContext:nil];
}

+ (void)restoreClippedImage:(id)aImage
{
    CGRect unitRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    NSArray *initialPaths = [aImage initialClipPaths];
    id clipPaths = [aImage queryHyperInterface:@protocol(HSMutableClipPathsAttributes)];
    [clipPaths removeAllClipPaths];
    CGRect bounds = unitRect;
    if ([initialPaths count] != 0) {
        for (id path in initialPaths)
            bounds = CGRectIntersection(bounds, CGEPathGetPathBoundingBox((CGPathRef)path));
    }
    float scaleX = bounds.size.width != 0.0 ? (float)(unitRect.size.width / bounds.size.width) : 1.0f;
    float scaleY = bounds.size.height != 0.0 ? (float)(unitRect.size.height / bounds.size.height) : 1.0f;
    CGAffineTransform transform = CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, (float)(unitRect.origin.x - bounds.origin.x * scaleX), (float)(unitRect.origin.y - bounds.origin.y * scaleY));
    [aImage setRelativeImageRect:NSRectFromCGRect(CGRectApplyAffineTransform(unitRect, transform))];
    if ([initialPaths count] == 0) {
        [[HSImageCropApplier cropApplierForImageObject:aImage] updateCurrentBorderPath];
    } else {
        for (id path in initialPaths)
            [clipPaths addRelativeClipPath:path transform:transform];
    }
    [clipPaths setAllClipPathsAsInitial];
    [aImage setCurrentClipPathsAreInitial:NO];
}

+ (void)restoreEffectedImage:(id)aImage
{
    [aImage setHyperEffectedMedia:nil refreshName:YES];
    [aImage setRelativeImageRect:NSMakeRect(0.0, 0.0, 1.0, 1.0) updateClipPaths:NO];
    [[aImage queryHyperInterface:@protocol(HSEffectMutableAttributes)] setHyperEffectName:nil settings:nil];
    [[aImage queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
    [aImage dropInitialClipPaths];
    HSImageCropApplier *applier = [[HSImageCropApplier alloc] initWithImageObject:aImage];
    [applier updateCurrentBorderPath];
    [applier release];
}

+ (BOOL)canRestoreNode:(id)aNode
{
    id image = [aNode queryHyperInterface:@protocol(HSImageObjectAttributes)];
    if (image == nil)
        return NO;
    return [self canRestoreEffectedImage:image] || [self canRestoreClippedImage:image] || [self canRestoreImageGeometry:image];
}

+ (BOOL)canRestoreImageGeometry:(id)aGeometry
{
    id<HSGeometryAttributes> geometry = [aGeometry queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NO;
    float widthScale = [geometry widthScale];
    if (widthScale < 0.9999f || widthScale > 1.0001f)
        return YES;
    float heightScale = [geometry heightScale];
    if (heightScale < 0.9999f || heightScale > 1.0001f)
        return YES;
    NSSize size = [geometry defaultSize];
    NSRect imageRect = [aGeometry relativeImageRect];
    float width = size.width;
    float height = size.height;
    if (imageRect.size.width != 0.0)
        width = width / imageRect.size.width;
    if (imageRect.size.height != 0.0)
        height = height / imageRect.size.height;
    float currentWidth = [geometry width];
    if (currentWidth < width - 0.001f || currentWidth > width + 0.001f)
        return YES;
    float currentHeight = [geometry height];
    return currentHeight < height - 0.001f || height + 0.001f < currentHeight;
}

+ (BOOL)canRestoreClippedImage:(id)aImage
{
    return [aImage canRestoreToInitialClipPaths] || [self canRestoreClippedImageRect:aImage];
}

+ (BOOL)canRestoreClippedImageRect:(id)aRect
{
    NSRect imageRect = [aRect relativeImageRect];
    if (!HSImageRectDiffersFromUnit(imageRect))
        return NO;
    NSRect visibleRect = imageRect;
    NSArray *initialPaths = [aRect initialClipPaths];
    if ([initialPaths count] != 0) {
        CGAffineTransform transform = CGAffineTransformMake(imageRect.size.width / 1.0, 0.0, 0.0, imageRect.size.height / 1.0, imageRect.origin.x - (imageRect.size.width / 1.0) * 0.0, imageRect.origin.y - (imageRect.size.height / 1.0) * 0.0);
        for (id path in initialPaths) {
            CGRect pathRect = CGRectApplyAffineTransform(CGEPathGetPathBoundingBox((CGPathRef)path), transform);
            visibleRect = NSIntersectionRect(visibleRect, NSRectFromCGRect(pathRect));
        }
    }
    return HSImageRectDiffersFromUnit(visibleRect);
}

+ (BOOL)canRestoreEffectedImage:(id)aImage
{
    if ([aImage hyperEffectedMedia] != nil)
        return YES;
    return [[aImage queryHyperInterface:@protocol(HSCardObjectEffectPerObjectAttribute)] hasEffectPerObject];
}

@end
