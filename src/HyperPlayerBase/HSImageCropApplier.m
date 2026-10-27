#import "HSImageCropApplier.h"
#import "HSCurrentImageDrawing.h"
#import "HSGeometryBehaviorApplier.h"
#import "HSMediaFileWrapper.h"
#import "HSUndoManager.h"
#import "HSExecutableResourceProvider.h"
#import "NSImage+HSImageSize.h"

// Maps the unit square with y pointing up onto y pointing down.
static const CGAffineTransform HSUnitFlipTransform = { 1.0, 0.0, 0.0, -1.0, 0.0, 1.0 };

@implementation HSImageCropApplier

+ (id)cropApplierForImageObject:(id)aObject
{
    return [[[HSImageCropApplier alloc] initWithImageObject:aObject] autorelease];
}

- (NSRect)imageObjectDrawing:(id)aDrawing imageBoundsForObjectBoundingRect:(NSRect)aRect
{
    return [self croppedImageFrameForObjectBoundingRect:aRect];
}

- (void)imageObjectDrawing:(id)aDrawing willDrawImageInContext:(struct CGContext *)aContext
{
    if ([self cropPath] != NULL) {
        CGContextAddPath(aContext, [self cropPath]);
        CGContextClip(aContext);
    }
}

- (void)adjustObjectSizeToBorderSize
{
    [self adjustObjectToBorderSizeWithRelativeBorderPath:[self calculateBorderPath]];
}

- (void)updateCurrentBorderPath
{
    if ([(id)[self imageObjectAttributes] image] != nil)
        [self setCurrentBorderPath:[self calculateBorderPath] transform:NULL];
}

// The border path is relative (unit square, y up); the transform is applied
// before the flip.
- (void)setCurrentBorderPath:(id)aPath transform:(CGAffineTransform *)aTransform
{
    CGAffineTransform transform = HSUnitFlipTransform;
    if (aTransform != NULL)
        transform = CGAffineTransformConcat(*aTransform, HSUnitFlipTransform);
    id<HSMutableClipPathsAttributes> clipPaths = [self clipPathsAttributes];
    [clipPaths removeNonInitialClipPaths];
    if (!CGPathIsEmpty((CGPathRef)aPath))
        [clipPaths addRelativeClipPath:aPath transform:transform];
    [self setupInitialClipPathsIfNeeded];
}

- (void)setupInitialClipPathsIfNeeded
{
    if ([[(id)[self imageObjectAttributes] initialClipPaths] count] == 0)
        [(id)[self imageObjectAttributes] setupInitialClipPaths];
}

// Traces the opaque pixels of the current image into a smoothed path scaled
// to the unit square.
- (id)calculateBorderPath
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [(HSCurrentImageDrawing *)[self croppedImageDrawing] setDelegate:nil];
    CGMutablePathRef path = CGPathCreateMutable();
    CVPixelBufferRef buffer = [[self croppedImageDrawing] currentCVPixelBufferOfSize:NULL];
    if (buffer != NULL) {
        uint32_t color = 0;
        size_t width = CVPixelBufferGetWidth(buffer);
        size_t height = CVPixelBufferGetHeight(buffer);
        if (CVPixelBufferLockBaseAddress(buffer, 0) == kCVReturnSuccess) {
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
            void *base = CVPixelBufferGetBaseAddress(buffer);
            CGEPathAddColoredPathsFromARGB8888PremultipliedBitmap(path, NULL, base, width, height, bytesPerRow, &color, 0, 0xffffffff, 6, NULL);
            CVPixelBufferUnlockBaseAddress(buffer, 0);
            CGPathRef smoothed = BTCGPathCreateCopyWithSmoothedCorners(path);
            CGPathRelease(path);
            path = CGPathCreateMutable();
            CGAffineTransform scale = { (CGFloat)(1.0f / (float)width), 0.0, 0.0, (CGFloat)(1.0f / (float)height), 0.0, 0.0 };
            CGPathAddPath(path, &scale, smoothed);
            CGPathRelease(smoothed);
        }
    }
    [(HSCurrentImageDrawing *)[self croppedImageDrawing] setDelegate:self];
    [pool release];
    return [(id)path autorelease];
}

- (void)updateEffectedImageObject
{
    [self updateEffectedMediaAndBorderWithAdjustingToBorderSize:YES];
}

- (void)updateEffectedMediaAndBorderWithAdjustingToBorderSize:(BOOL)aSize
{
    if (![self canUpdateEffectedMedia])
        return;
    [self updateEffectedMediaWithoutAdjustingToBorderSize];
    id borderPath = [self calculateBorderPath];
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (aSize) {
        NSRect frame = [self croppedImageFrame];
        CGRect bounds = CGRectApplyAffineTransform(CGEPathGetPathBoundingBox((CGPathRef)borderPath), HSUnitFlipTransform);
        double x = (double)frame.size.width * bounds.origin.x;
        double y = (double)frame.size.height * bounds.origin.y;
        CGAffineTransform current = [[[self geometryBehaviorApplier] mutableGeometryAttributes] affineTransform];
        current.tx = current.a * (float)x + current.c * (float)y + current.tx;
        current.ty = current.b * (float)x + current.d * (float)y + current.ty;
        [[self geometryBehaviorApplier] setAffineTransform:current withLayoutGuidingContext:nil];
        [self adjustObjectToBorderSizeWithRelativeBorderPath:borderPath];
        CGRect box = CGEPathGetPathBoundingBox((CGPathRef)borderPath);
        float sx = (box.size.width != 0.0) ? 1.0f / (float)box.size.width : 1.0f;
        float sy = (box.size.height != 0.0) ? 1.0f / (float)box.size.height : 1.0f;
        transform = CGAffineTransformMake(sx, 0.0, 0.0, sy, 0.0f - (float)box.origin.x * sx, 0.0f - (float)box.origin.y * sy);
    }
    [self setCurrentBorderPath:borderPath transform:&transform];
}

// Bakes the current effect into a PNG media and resets the clip paths; the
// object grows to the union of its bounds and the cropped frame.
- (void)updateEffectedMediaWithoutAdjustingToBorderSize
{
    if (![self canUpdateEffectedMedia])
        return;
    NSData *png = [[self croppedImageDrawing] currentImagePNGRepresentationOfSize:NULL];
    if ([png length] == 0)
        return;
    NSRect frame = [self croppedImageFrame];
    id attributes = [self imageObjectAttributes];
    [[attributes queryHyperInterface:@protocol(HSEffectMutableAttributes)] setHyperEffectName:nil settings:nil];
    HSNewMedia *media = [HSNewMedia mediaWithData:png name:[[[self imageObjectAttributes] media] mediaName] type:@"png"];
    [(id)[self imageObjectAttributes] setHyperEffectedMedia:media refreshName:NO];
    [[self clipPathsAttributes] removeAllClipPaths];
    [(id)[self imageObjectAttributes] setRelativeImageRect:NSMakeRect(0.0, 0.0, 1.0, 1.0)];
    [(id)[self imageObjectAttributes] setCurrentClipPathsAreInitial:YES];
    HSGeometryBehaviorApplier *applier = [self geometryBehaviorApplier];
    id geometry = [applier mutableGeometryAttributes];
    NSRect rect = NSIntegralRect(NSUnionRect(frame, [geometry boundingRect]));
    CGAffineTransform transform = [geometry affineTransform];
    float tx = transform.a * (float)rect.origin.x + transform.c * (float)rect.origin.y + transform.tx;
    float ty = transform.b * (float)rect.origin.x + transform.d * (float)rect.origin.y + transform.ty;
    transform.tx = tx;
    transform.ty = ty;
    [applier setSize:rect.size affineTransform:transform flippedHorizontally:NO withLayoutGuidingContext:nil];
}

- (BOOL)canUpdateEffectedMedia
{
    if ([(id)[self imageObjectAttributes] hyperEffectedMedia] != nil)
        return YES;
    return [[(id)[self imageObjectAttributes] queryHyperInterface:@protocol(HSEffectMutableAttributes)] hyperEffectName] != nil;
}

// Fits the object (and the relative image rect) to the border path's bounds.
// A degenerate scale skips the inversion (original behaviour).
- (void)adjustObjectToBorderSizeWithRelativeBorderPath:(id)aPath
{
    CGPathRef path = (CGPathRef)aPath;
    if (CGPathIsEmpty(path) || CGRectIsEmpty(CGEPathGetPathBoundingBox(path)))
        return;
    HSGeometryBehaviorApplier *applier = [self geometryBehaviorApplier];
    id geometry = [applier mutableGeometryAttributes];
    NSRect frame = [self croppedImageFrame];
    NSRect bounds = [geometry boundingRect];
    NSRect united = NSUnionRect(frame, bounds);
    CGRect box = CGRectApplyAffineTransform(CGEPathGetPathBoundingBox(path), HSUnitFlipTransform);
    float minY = (float)CGRectGetMinY(box);
    float minX = (float)CGRectGetMinX(box);
    float height = (float)CGRectGetHeight(box);
    float width = (float)CGRectGetWidth(box);
    float sx = 1.0f / width;
    float sy = 1.0f / height;
    CGAffineTransform toUnit = CGAffineTransformMake(sx, 0.0, 0.0, sy, 0.0f - sx * minX, 0.0f - sy * minY);
    NSRect relative = CGRectApplyAffineTransform([(id)[self imageObjectAttributes] relativeImageRect], toUnit);
    [(id)[self imageObjectAttributes] setRelativeImageRect:relative];
    float determinant = sx * sy;
    double off = 0.0;
    float scaleX = sx, scaleY = sy;
    if (determinant != 0.0f) {
        scaleY = sx / determinant;
        scaleX = sy / determinant;
        off = -0.0f / determinant;
    }
    NSSize size;
    size.width = (float)((double)scaleX * united.size.width + off * united.size.height);
    size.height = (float)((double)scaleY * united.size.height + off * united.size.width);
    [applier setSize:size withLayoutGuidingContext:nil];
    [applier moveBy:NSMakeSize(frame.origin.x, frame.origin.y) withLayoutGuidingContext:nil];
}

- (void)cropImageObjectWithPaths:(id)aPaths modifyObjectGeometry:(BOOL)aGeometry
{
    [self updateEffectedMediaAndBorderWithAdjustingToBorderSize:NO];
    if (!aGeometry) {
        [self cropImageObjectWithPaths:aPaths];
    } else {
        NSEnumerator *e = [aPaths objectEnumerator];
        id path;
        while ((path = [e nextObject]) != nil)
            [self cropImageObjectAndModifyGeometryWithPath:(struct CGPath *)path];
    }
    [(id)[self imageObjectAttributes] setCurrentClipPathsAreInitial:YES];
}

- (void)cropImageObjectWithPath:(struct CGPath *)aPath
{
    [self updateEffectedMediaAndBorderWithAdjustingToBorderSize:NO];
    [self cropImageObjectAndModifyGeometryWithPath:aPath];
    [(id)[self imageObjectAttributes] setCurrentClipPathsAreInitial:YES];
}

- (void)cropImageObjectAndModifyGeometryWithPath:(struct CGPath *)aPath
{
    if (aPath == NULL || CGPathIsEmpty(aPath))
        return;
    [self setCropPath:aPath];
    if ([self canApplyCurrentCropPathToImageObject])
        [self cropImageObjectAndModifyGeometryWithCurrentCropPath];
    [self setCropPath:NULL];
}

// Each path crops in the coordinates left by the previous ones; the image
// rect and clip path are scaled to the object size.
- (void)cropImageObjectWithPaths:(id)aPaths
{
    NSUInteger count = [aPaths count];
    if (count == 0)
        return;
    NSSize objectSize = [(id<HSGeometryAttributes>)[(id)[self imageObjectAttributes] queryHyperInterface:@protocol(HSGeometryAttributes)] size];
    NSRect imageRect;
    imageRect.origin = NSZeroPoint;
    imageRect.size = [[(id)[self imageObjectAttributes] image] hyperPixelsSize];
    NSUInteger i;
    for (i = 0; i < count; i++) {
        CGPathRef path = (CGPathRef)[aPaths objectAtIndex:i];
        if (path == NULL || CGPathIsEmpty(path))
            continue;
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSRect rect = NSIntegralRect(NSIntersectionRect(CGEPathGetPathBoundingBox(path), imageRect));
        CGAffineTransform offset = CGAffineTransformIdentity;
        NSUInteger j;
        for (j = 0; j < i; j++) {
            NSRect previous = NSIntersectionRect(imageRect, CGEPathGetPathBoundingBox((CGPathRef)[aPaths objectAtIndex:j]));
            rect.origin.x += previous.origin.x;
            rect.origin.y += previous.origin.y;
            offset = CGAffineTransformTranslate(offset, previous.origin.x, previous.origin.y);
        }
        CGMutablePathRef clipPath = CGPathCreateMutable();
        CGPathAddPath(clipPath, &offset, path);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y);
        float sy = (rect.size.height != 0.0) ? (float)objectSize.height / (float)rect.size.height : 1.0f;
        float sx = (rect.size.width != 0.0) ? (float)objectSize.width / (float)rect.size.width : 1.0f;
        transform.ty *= sy;
        transform.tx *= sx;
        transform.d *= sy;
        transform.c *= sx;
        transform.b *= sy;
        transform.a *= sx;
        NSRect newImageRect = CGRectApplyAffineTransform(imageRect, transform);
        [(id)[self imageObjectAttributes] setImageRect:newImageRect];
        [[self clipPathsAttributes] addObjectClipPath:(id)clipPath transform:transform];
        CGPathRelease(clipPath);
        [pool release];
    }
}

- (void)cropImageObjectAndModifyGeometryWithCurrentCropPath
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSUndoManager *undoManager = [[(id)[self imageObjectAttributes] queryHyperInterface:@protocol(HSNodeSupport)] undoManager];
    [undoManager setMultipleActionsName:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cropping" value:@"" table:@"UndoManager"]];
    CGPathRef cropPath = [self cropPath];
    NSRect imageRect = [(id)[self imageObjectAttributes] imageRect];
    NSRect frame = [self croppedImageFrame];
    NSRect integral = NSIntegralRect(frame);
    HSGeometryBehaviorApplier *applier = [self geometryBehaviorApplier];
    id geometry = [applier mutableGeometryAttributes];
    CGAffineTransform transform = [geometry affineTransform];
    float tx = transform.a * (float)integral.origin.x + transform.c * (float)integral.origin.y + transform.tx;
    float ty = transform.b * (float)integral.origin.x + transform.d * (float)integral.origin.y + transform.ty;
    transform.tx = tx;
    transform.ty = ty;
    [(id<HSMutableGeometryAttributes>)geometry setSize:frame.size];
    [applier setAffineTransform:transform flippedHorizontally:NO withLayoutGuidingContext:nil];
    [(id)[self imageObjectAttributes] setImageRect:NSMakeRect(imageRect.origin.x - frame.origin.x, imageRect.origin.y - frame.origin.y, imageRect.size.width, imageRect.size.height)];
    [[self clipPathsAttributes] addObjectCropPath:(id)cropPath transform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, -frame.origin.x, -frame.origin.y)];
    [pool release];
}

- (BOOL)canApplyCurrentCropPathToImageObject
{
    if ([self cropPath] == NULL)
        return NO;
    return !NSIsEmptyRect([self croppedImageFrame]);
}

- (NSRect)croppedImageFrame
{
    return [self croppedImageFrameForObjectBoundingRect:[[self croppedImageDrawing] imageBoundingRect]];
}

- (NSRect)croppedImageFrameForObjectBoundingRect:(NSRect)aRect
{
    NSRect frame = aRect;
    if ([self cropPath] != NULL) {
        CGRect bounds = CGRectZero;
        if (!CGPathIsEmpty([self cropPath]))
            bounds = CGEPathGetPathBoundingBox([self cropPath]);
        frame = NSIntersectionRect(bounds, aRect);
    }
    return frame;
}

- (id)croppedImageDrawing
{
    if (_drawing == nil) {
        _drawing = [[HSCurrentImageDrawing alloc] initWithImageObject:[self imageObjectAttributes]];
        [_drawing setDelegate:self];
    }
    return _drawing;
}

- (void)setCropPath:(struct CGPath *)aPath
{
    if (_cropPath == aPath)
        return;
    CGPathRelease(_cropPath);
    _cropPath = aPath ? (struct CGPath *)CGPathRetain(aPath) : NULL;
}

- (struct CGPath *)cropPath
{
    return _cropPath;
}

- (id)geometryBehaviorApplier
{
    return [[(id)[self imageObjectAttributes] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
}

- (id)clipPathsAttributes
{
    return [(id)[self imageObjectAttributes] queryHyperInterface:@protocol(HSMutableClipPathsAttributes)];
}

- (id)imageObjectAttributes
{
    return _imageObjectAttributes;
}

- (void)dealloc
{
    [_imageObjectAttributes release];
    if (_cropPath != NULL)
        CGPathRelease(_cropPath);
    [_drawing release];
    [super dealloc];
}

- (id)initWithImageObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        id attributes = [aObject queryHyperInterface:@protocol(HSImageObjectAttributes)];
        if (attributes == nil) {
            [self release];
            return nil;
        }
        _imageObjectAttributes = [attributes retain];
    }
    return self;
}

@end
