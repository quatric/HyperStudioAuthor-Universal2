#import "HSStreamDrawable.h"
// A drawable backed by a pool of pixel buffers (for streaming the card,
// e.g. to a presentation mirror). -pixelBuffer redraws into a new buffer
// only the invalidated rects, copying the rest from the previous one; the
// new buffer carries the changed rects as an attachment.
//
// The invalid rects are kept disjoint, in CFMutableData chunks of eight in
// _invalidRectsDataArray.

#define HSStreamDrawableRectsPerChunk 8
// Edges this close count as touching, not overlapping.
#define HSStreamDrawableTolerance 0.001953125

typedef struct {
    const unsigned char *source;
    unsigned char *destination;
    size_t width;
    size_t height;
    size_t bytesPerRow;
    size_t bytesPerPixel;
} HSStreamDrawableBitmap;

static NSRect *HSStreamDrawableRectAtIndex(CFArrayRef aChunks, NSUInteger aIndex)
{
    CFMutableDataRef chunk = (CFMutableDataRef)CFArrayGetValueAtIndex(aChunks, aIndex / HSStreamDrawableRectsPerChunk);
    return (NSRect *)CFDataGetMutableBytePtr(chunk) + aIndex % HSStreamDrawableRectsPerChunk;
}

// The parts of aRect outside aCovering (up to four: below, above, left,
// right), or -1 if they don't overlap.
static int HSStreamDrawableSubtractRect(NSRect aRect, NSRect aCovering, NSRect aPieces[4], CGFloat aTolerance)
{
    CGFloat minX = aRect.origin.x, minY = aRect.origin.y;
    CGFloat maxX = minX + aRect.size.width, maxY = minY + aRect.size.height;
    CGFloat coverMinX = aCovering.origin.x, coverMinY = aCovering.origin.y;
    CGFloat coverMaxX = coverMinX + aCovering.size.width, coverMaxY = coverMinY + aCovering.size.height;
    if (!(coverMinX < maxX - aTolerance && minX + aTolerance < coverMaxX && coverMinY < maxY - aTolerance && minY + aTolerance < coverMaxY))
        return -1;
    int count = 0;
    CGFloat bottom = minY, top = maxY;
    if (minY + aTolerance < coverMinY) {
        aPieces[count++] = NSMakeRect(minX, minY, aRect.size.width, coverMinY - minY);
        bottom = coverMinY;
    }
    if (coverMaxY < maxY - aTolerance) {
        aPieces[count++] = NSMakeRect(minX, coverMaxY, aRect.size.width, maxY - coverMaxY);
        top = coverMaxY;
    }
    if (minX + aTolerance < coverMinX)
        aPieces[count++] = NSMakeRect(minX, bottom, coverMinX - minX, top - bottom);
    if (coverMaxX < maxX - aTolerance)
        aPieces[count++] = NSMakeRect(coverMaxX, bottom, maxX - coverMaxX, top - bottom);
    return count;
}

static void HSStreamDrawableRemoveRect(CFArrayRef aChunks, unsigned int *aCount, NSUInteger aIndex)
{
    for (NSUInteger i = aIndex; i + 1 < *aCount; i++)
        *HSStreamDrawableRectAtIndex(aChunks, i) = *HSStreamDrawableRectAtIndex(aChunks, i + 1);
    (*aCount)--;
}

// Adds aRect to the rects from aStart on: a rect it contains is dropped,
// one it overlaps splits it and its pieces go on with the following rects.
// (The original compacts the list in place as it goes; this keeps the same
// pieces with plain removal.)
static BOOL HSStreamDrawableAddRect(CFMutableArrayRef aChunks, unsigned int *aCount, NSUInteger aStart, NSRect aRect)
{
    for (NSUInteger i = aStart; i < *aCount; i++) {
        NSRect pieces[4];
        int count = HSStreamDrawableSubtractRect(aRect, *HSStreamDrawableRectAtIndex(aChunks, i), pieces, HSStreamDrawableTolerance);
        if (count < 0)
            continue;
        if (count == 0)
            return NO;
        if (count == 4) {
            HSStreamDrawableRemoveRect(aChunks, aCount, i);
            i--;
            continue;
        }
        BOOL added = NO;
        for (int piece = 0; piece < count; piece++)
            added |= HSStreamDrawableAddRect(aChunks, aCount, i + 1, pieces[piece]);
        return added;
    }
    NSUInteger chunk = *aCount / HSStreamDrawableRectsPerChunk;
    if (chunk >= (NSUInteger)CFArrayGetCount(aChunks)) {
        CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, HSStreamDrawableRectsPerChunk * sizeof(NSRect));
        if (data == NULL)
            return NO;
        CFDataSetLength(data, HSStreamDrawableRectsPerChunk * sizeof(NSRect));
        CFArrayAppendValue(aChunks, data);
        CFRelease(data);
    }
    *HSStreamDrawableRectAtIndex(aChunks, *aCount) = aRect;
    (*aCount)++;
    return YES;
}

// Rows of aRect (in bottom-up coordinates) in the bitmap's memory.
static void HSStreamDrawableRectRows(const HSStreamDrawableBitmap *aBitmap, NSRect aRect, size_t *aOffset, size_t *aLength, long *aRows)
{
    CGRect rect = CGRectIntegral(NSRectToCGRect(aRect));
    long y = lroundf((float)rect.origin.y);
    long width = lroundf((float)rect.size.width);
    long height = lroundf((float)rect.size.height);
    size_t row = aBitmap->height - (y + height);
    *aOffset = row * aBitmap->bytesPerRow + lroundf((float)rect.origin.x) * aBitmap->bytesPerPixel;
    *aLength = width * aBitmap->bytesPerPixel;
    *aRows = height;
}

// Copies the parts of aRect outside the rects from the old buffer.
// (The original stops subtracting at a rect a piece doesn't overlap and so
// also copies some invalid areas; they're cleared afterwards anyway.)
static void HSStreamDrawableCopyOutsideRects(NSRect aRect, const NSRect *aRects, unsigned int aCount, const HSStreamDrawableBitmap *aBitmap)
{
    if (CGRectIsEmpty(NSRectToCGRect(aRect)))
        return;
    if (aCount == 0) {
        size_t offset, length;
        long rows;
        HSStreamDrawableRectRows(aBitmap, aRect, &offset, &length, &rows);
        for (; rows > 0; rows--, offset += aBitmap->bytesPerRow)
            memcpy(aBitmap->destination + offset, aBitmap->source + offset, length);
        return;
    }
    NSRect pieces[4];
    int count = HSStreamDrawableSubtractRect(aRect, aRects[0], pieces, 0);
    if (count < 0) {
        HSStreamDrawableCopyOutsideRects(aRect, aRects + 1, aCount - 1, aBitmap);
        return;
    }
    for (int piece = 0; piece < count; piece++)
        HSStreamDrawableCopyOutsideRects(pieces[piece], aRects + 1, aCount - 1, aBitmap);
}

@implementation HSStreamDrawable
// Redraws if anything changed (or there's no buffer yet).
- (struct __CVBuffer *)pixelBuffer
{
    if (_currentPixelBuffer != NULL && _invalidRectCount == 0)
        return _currentPixelBuffer;
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferPool, &buffer);
    if (buffer == NULL)
        return _currentPixelBuffer;
    if (_colorSpace != NULL)
        CVBufferSetAttachment(buffer, kCVImageBufferCGColorSpaceKey, _colorSpace, kCVAttachmentMode_ShouldPropagate);
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(buffer, 0);
    if (context == NULL) {
        CVPixelBufferRelease(buffer);
        return _currentPixelBuffer;
    }
    NSRect bounds = NSMakeRect(CGPointZero.x, CGPointZero.y, (float)CVPixelBufferGetWidth(buffer), (float)CVPixelBufferGetHeight(buffer));
    NSRect *rects = NULL;
    unsigned int count = 0;
    [self getRectsBeingDrawn:&rects count:&count];
    if (_currentPixelBuffer != NULL) {
        if (CVPixelBufferLockBaseAddress(_currentPixelBuffer, 0) != kCVReturnSuccess) {
            CVPixelBufferRelease(_currentPixelBuffer);
            _currentPixelBuffer = NULL;
        } else {
            BOOL copied = YES;
            if (!_clearsContextBeforeDraw)
                memcpy(CGBitmapContextGetData(context), CVPixelBufferGetBaseAddress(_currentPixelBuffer), CVEPixelBufferGetDataSize(_currentPixelBuffer));
            else {
                // Keep what's outside the rects, clear what's inside
                // (whole-byte single-pixel-block formats only).
                int blockWidth = 0;
                int bitsPerBlock = 0;
                CFDictionaryRef format = CVPixelFormatDescriptionCreateWithPixelFormatType(NULL, CVPixelBufferGetPixelFormatType(_currentPixelBuffer));
                if (format != NULL) {
                    CFNumberRef number = NULL;
                    if (CFDictionaryGetValueIfPresent(format, kCVPixelFormatBlockWidth, (const void **)&number))
                        CFNumberGetValue(number, kCFNumberIntType, &blockWidth);
                    else
                        blockWidth = 1;
                    CFNumberGetValue(CFDictionaryGetValue(format, kCVPixelFormatBitsPerBlock), kCFNumberIntType, &bitsPerBlock);
                    CFRelease(format);
                }
                if (format == NULL || blockWidth != 1 || (bitsPerBlock & 7) != 0)
                    copied = NO;
                else {
                    HSStreamDrawableBitmap bitmap = { CVPixelBufferGetBaseAddress(_currentPixelBuffer), CGBitmapContextGetData(context),
                        CVPixelBufferGetWidth(_currentPixelBuffer), CVPixelBufferGetHeight(_currentPixelBuffer),
                        CVPixelBufferGetBytesPerRow(_currentPixelBuffer), bitsPerBlock / 8 };
                    HSStreamDrawableCopyOutsideRects(bounds, rects, count, &bitmap);
                    HSStreamDrawableBitmap target = { NULL, CGBitmapContextGetData(context), CGBitmapContextGetWidth(context),
                        CGBitmapContextGetHeight(context), CGBitmapContextGetBytesPerRow(context),
                        CGBitmapContextGetBitsPerPixel(context) / CGBitmapContextGetBitsPerComponent(context) };
                    if (rects != NULL && count != 0 && target.destination != NULL && target.bytesPerRow != 0 && target.bytesPerPixel != 0) {
                        for (unsigned int i = 0; i < count; i++) {
                            size_t offset, length;
                            long rows;
                            HSStreamDrawableRectRows(&target, rects[i], &offset, &length, &rows);
                            for (; rows > 0; rows--, offset += target.bytesPerRow)
                                memset(target.destination + offset, 0, length);
                        }
                    }
                }
            }
            if (copied) {
                CVPixelBufferUnlockBaseAddress(_currentPixelBuffer, 0);
                CGContextBeginPath(context);
                CGContextAddRects(context, (const CGRect *)rects, count);
                CGContextClip(context);
            } else {
                // The original left the old buffer locked here (and the new
                // one undrawn outside the rects, still the case).
                CVPixelBufferUnlockBaseAddress(_currentPixelBuffer, 0);
            }
        }
    }
    if (_currentPixelBuffer == NULL)
        memset(CGBitmapContextGetData(context), 0, CGBitmapContextGetBytesPerRow(context) * CGBitmapContextGetHeight(context));
    // Draw with our profile and color space attached to the context.
    CFStringRef profileKey = (CFStringRef)kCGEContextColorSyncProfileAttachmentKey;
    CFTypeRef oldProfile = CGEContextGetAttachmentForKey(context, profileKey);
    if (oldProfile != NULL)
        CFRetain(oldProfile);
    CGEContextSetAttachmentForKey(context, profileKey, _colorProfile);
    CFStringRef colorSpaceKey = (CFStringRef)kCGEContextColorSpaceAttachmentKey;
    CFTypeRef oldColorSpace = CGEContextGetAttachmentForKey(context, colorSpaceKey);
    if (oldColorSpace != NULL)
        CFRetain(oldColorSpace);
    CGEContextSetAttachmentForKey(context, colorSpaceKey, _colorSpace);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self drawRect:CGContextGetClipBoundingBox(context) inCoreGraphicsContext:context];
    [pool release];
    CGEContextSetAttachmentForKey(context, colorSpaceKey, oldColorSpace);
    if (oldColorSpace != NULL)
        CFRelease(oldColorSpace);
    CGEContextSetAttachmentForKey(context, profileKey, oldProfile);
    if (oldProfile != NULL)
        CFRelease(oldProfile);
    CGContextRelease(context);
    CVPixelBufferRelease(_currentPixelBuffer);
    _currentPixelBuffer = buffer;
    if (count != 0) {
        CFDataRef changed = CFDataCreate(NULL, (const UInt8 *)rects, count * sizeof(NSRect));
        if (changed != NULL) {
            CVBufferSetAttachment(_currentPixelBuffer, (CFStringRef)kCVEImageBufferChangedRegionKey, changed, kCVAttachmentMode_ShouldNotPropagate);
            CFRelease(changed);
        }
    }
    [_invalidRectsData release];
    _invalidRectsData = nil;
    if (_invalidRectsDataArray != NULL) {
        CFRelease(_invalidRectsDataArray);
        _invalidRectsDataArray = NULL;
    }
    _invalidRectCount = 0;
    return _currentPixelBuffer;
}
// Subclasses draw (in the buffer's bottom-up coordinates).
- (void)drawRect:(NSRect)aRect
{
}
- (void)drawRect:(CGRect)aRect inCoreGraphicsContext:(struct CGContext *)aContext
{
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:aContext flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [self drawRect:NSRectFromCGRect(aRect)];
    [NSGraphicsContext restoreGraphicsState];
}
- (BOOL)needsToDrawRect:(NSRect)aRect
{
    size_t width, height;
    if (_currentPixelBuffer == NULL) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        width = [[attributes objectForKey:(NSString *)kCVPixelBufferWidthKey] unsignedLongValue];
        height = [[attributes objectForKey:(NSString *)kCVPixelBufferHeightKey] unsignedLongValue];
    } else {
        width = CVPixelBufferGetWidth(_currentPixelBuffer);
        height = CVPixelBufferGetHeight(_currentPixelBuffer);
    }
    CGRect bounds = CGRectMake(CGPointZero.x, CGPointZero.y, (float)width, (float)height);
    if (!CGRectIntersectsRect(NSRectToCGRect(aRect), bounds))
        return NO;
    if (_currentPixelBuffer == NULL)
        return YES;
    if (_invalidRectsDataArray != NULL)
        for (unsigned int i = 0; i < _invalidRectCount; i++)
            if (CGRectIntersectsRect(NSRectToCGRect(aRect), NSRectToCGRect(*HSStreamDrawableRectAtIndex(_invalidRectsDataArray, i))))
                return YES;
    return NO;
}
// Everything before the first buffer; the rects are valid until the next
// change.
- (void)getRectsBeingDrawn:(NSRect **)aDrawn count:(unsigned int *)aCount
{
    if (_invalidRectsData != nil) {
        *aDrawn = (NSRect *)[_invalidRectsData bytes];
        *aCount = _invalidRectCount;
        return;
    }
    if (_currentPixelBuffer == NULL) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        NSRect bounds = NSMakeRect(CGPointZero.x, CGPointZero.y,
            (float)[[attributes objectForKey:(NSString *)kCVPixelBufferWidthKey] unsignedLongValue],
            (float)[[attributes objectForKey:(NSString *)kCVPixelBufferHeightKey] unsignedLongValue]);
        _invalidRectsData = [[NSData alloc] initWithBytes:&bounds length:sizeof(bounds)];
        if (_invalidRectsData == nil)
            return;
        _invalidRectCount = 1;
        *aDrawn = (NSRect *)[_invalidRectsData bytes];
        *aCount = _invalidRectCount;
        return;
    }
    unsigned int count = _invalidRectCount;
    if (count == 0) {
        *aDrawn = NULL;
        *aCount = 0;
        return;
    }
    if (count <= HSStreamDrawableRectsPerChunk) {
        *aDrawn = HSStreamDrawableRectAtIndex(_invalidRectsDataArray, 0);
        *aCount = count;
        return;
    }
    // More than one chunk: gather them.
    NSRect *rects = malloc(count * sizeof(NSRect));
    if (rects == NULL)
        return;
    for (unsigned int i = 0; i < count; i++)
        rects[i] = *HSStreamDrawableRectAtIndex(_invalidRectsDataArray, i);
    _invalidRectsData = [[NSData alloc] initWithBytesNoCopy:rects length:count * sizeof(NSRect) freeWhenDone:YES];
    if (_invalidRectsData == nil) {
        free(rects);
        return;
    }
    *aDrawn = rects;
    *aCount = _invalidRectCount;
}
- (void)setClearsContextBeforeDraw:(BOOL)aDraw
{
    _clearsContextBeforeDraw = aDraw;
}
- (BOOL)clearsContextBeforeDraw
{
    return _clearsContextBeforeDraw;
}
// (Before the first buffer everything gets drawn anyway.)
- (void)invalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount
{
    if (_currentPixelBuffer == NULL)
        return;
    if (_invalidRectsDataArray == NULL) {
        _invalidRectsDataArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (_invalidRectsDataArray == NULL)
            return;
    }
    [_invalidRectsData release];
    _invalidRectsData = nil;
    CGRect bounds = CGRectMake(CGPointZero.x, CGPointZero.y, (float)CVPixelBufferGetWidth(_currentPixelBuffer), (float)CVPixelBufferGetHeight(_currentPixelBuffer));
    for (NSInteger i = 0; i < (NSInteger)aCount; i++) {
        CGRect rect = CGRectIntersection(NSRectToCGRect(aRects[i]), bounds);
        if (!CGRectIsEmpty(rect))
            HSStreamDrawableAddRect((CFMutableArrayRef)_invalidRectsDataArray, &_invalidRectCount, 0, NSRectFromCGRect(rect));
    }
    // Drop chunks no longer used.
    CFIndex used = (_invalidRectCount + HSStreamDrawableRectsPerChunk - 1) / HSStreamDrawableRectsPerChunk;
    CFIndex chunks = CFArrayGetCount(_invalidRectsDataArray);
    if (used < chunks)
        CFArrayReplaceValues((CFMutableArrayRef)_invalidRectsDataArray, CFRangeMake(used, chunks - used), NULL, 0);
}
- (void)invalidateInRect:(NSRect)aRect
{
    [self invalidateInRects:&aRect count:1];
}
// Drops the buffer: the next one is drawn whole.
- (void)invalidate
{
    if (_currentPixelBuffer == NULL)
        return;
    [_invalidRectsData release];
    _invalidRectsData = nil;
    if (_invalidRectsDataArray != NULL) {
        CFRelease(_invalidRectsDataArray);
        _invalidRectsDataArray = NULL;
    }
    _invalidRectCount = 0;
    CVPixelBufferRelease(_currentPixelBuffer);
    _currentPixelBuffer = NULL;
}
// Without a color space, one is made from the profile. (ColorSync profile
// references are CF objects on 64-bit: CMCloneProfileRef / CMCloseProfile
// become CFRetain / CFRelease.)
- (void)setColorProfile:(struct OpaqueCMProfileRef *)aProfile colorSpace:(struct CGColorSpace *)aSpace
{
    struct OpaqueCMProfileRef *profile = _colorProfile;
    if (profile != aProfile) {
        if (aProfile != NULL)
            CFRetain(aProfile);
        if (_colorProfile != NULL)
            CFRelease(_colorProfile);
        _colorProfile = aProfile;
        profile = aProfile;
    }
    CGColorSpaceRef created = NULL;
    if (aSpace == NULL && profile != NULL) {
        created = CGColorSpaceCreateWithPlatformColorSpace(profile);
        aSpace = created;
    }
    BOOL changed = aSpace == NULL ? _colorSpace != NULL : (_colorSpace == NULL || !CFEqual(aSpace, _colorSpace));
    if (changed) {
        if (aSpace == created)
            created = NULL;
        else
            CGColorSpaceRetain(aSpace);
        CGColorSpaceRelease(_colorSpace);
        _colorSpace = aSpace;
        [self invalidate];
    }
    CGColorSpaceRelease(created);
}
- (struct CGColorSpace *)colorSpace
{
    return _colorSpace;
}
- (struct OpaqueCMProfileRef *)colorProfile
{
    return _colorProfile;
}
- (void)dealloc
{
    [_invalidRectsData release];
    if (_invalidRectsDataArray != NULL)
        CFRelease(_invalidRectsDataArray);
    CVPixelBufferRelease(_currentPixelBuffer);
    if (_colorProfile != NULL)
        CFRelease(_colorProfile);
    CGColorSpaceRelease(_colorSpace);
    CVPixelBufferPoolRelease(_pixelBufferPool);
    [super dealloc];
}
- (id)initWithPixelBufferPoolAttributes:(id)aAttributes pixelBufferAttributes:(id)aAttributes2
{
    self = [super init];
    if (self == nil)
        return nil;
    CVPixelBufferPoolCreate(kCFAllocatorDefault, (CFDictionaryRef)aAttributes, (CFDictionaryRef)aAttributes2, &_pixelBufferPool);
    if (_pixelBufferPool == NULL) {
        [super release];
        return nil;
    }
    _clearsContextBeforeDraw = YES;
    return self;
}
// 32-bit BGRA buffers usable as bitmap contexts and images, alpha info 1
// (premultiplied last) attached.
- (id)initWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    NSDictionary *attachments = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], kCVEPixelBufferAlphaInfoKey, nil];
    NSDictionary *attributes = nil;
    if (attachments != nil)
        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
            [NSNumber numberWithUnsignedLong:aWidth], kCVPixelBufferWidthKey,
            [NSNumber numberWithUnsignedLong:aHeight], kCVPixelBufferHeightKey,
            kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey,
            kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey,
            attachments, kCVBufferNonPropagatedAttachmentsKey, nil];
    if (attributes == nil) {
        [super release];
        return nil;
    }
    return [self initWithPixelBufferPoolAttributes:nil pixelBufferAttributes:attributes];
}
// A size is needed.
- (id)init
{
    [super release];
    return nil;
}
@end
