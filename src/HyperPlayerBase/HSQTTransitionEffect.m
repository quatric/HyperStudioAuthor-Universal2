#import "HSQTTransitionEffect.h"
#import "HSQTAtomContainer.h"
#import "HSPointer.h"
#import "CGEImage.h"
#import <sys/stat.h>

// A QuickTime transition: an effect description (atom container) read from
// a .qfx file in the Transitions folder or stored in the document. The
// effect's two sources get 'src ' atoms srcA and srcB; swapped transitions
// feed the end image to srcA.

static void HSQTTransitionDisposeAtomContainer(void *aContainer)
{
    HSQTDisposeAtomContainer((HSQTAtomContainer)aContainer);
}

@implementation HSQTTransitionEffect

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"atomContainerData"];
}

// Stored data makes the effect external (it no longer comes from a file).
- (void)setAtomContainerData:(id)aData
{
    if (aData == nil || [aData length] == 0)
        return;
    Handle handle = NewHandle([aData length]);
    if (handle == NULL)
        return;
    HLock(handle);
    [aData getBytes:*handle length:[aData length]];
    HUnlock(handle);
    // Fix: the original replaced the description without releasing it.
    [_effectDescription release];
    _effectDescription = [[HSPointer alloc] initWithPointer:handle disposer:(void *)HSQTTransitionDisposeAtomContainer];
    _swapsInputs = 0;
    _isExternal = 1;
}

- (id)atomContainerData
{
    Handle description = (Handle)[self HSQTTransitionEffect_effectDescription];
    if (description == NULL)
        return nil;
    Size size = GetHandleSize(description);
    if (size == 0)
        return nil;
    return [NSData dataWithBytes:*description length:size];
}

- (BOOL)isExternal
{
    return _isExternal;
}

- (id)createQuartzRendererForSize:(CGSize)aSize
{
    if ([self HSQTTransitionEffect_effectDescription] == NULL)
        return nil;
    return [[HSQTTransitionQuartzRenderer alloc] initWithSize:aSize effectDescription:_effectDescription swappedInputs:_swapsInputs];
}

- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat
{
    return nil;
}

- (BOOL)hasOpenGLRenderer
{
    return NO;
}

- (BOOL)hasQuartzRenderer
{
    return YES;
}

// Frames step with the effect's time base (scale 0x7fffffff).
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2
{
    return (int)floor(aTime * 2147483647.0) != (int)floor(aTime2 * 2147483647.0);
}

- (BOOL)isSlow
{
    return NO;
}

- (NSUInteger)hash
{
    Handle description = (Handle)[self HSQTTransitionEffect_effectDescription];
    return description ? GetHandleSize(description) : 0;
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSQTTransitionEffect class]])
        return NO;
    // A subclass instance decides.
    if (![aEqual isMemberOfClass:[self class]] && [aEqual isKindOfClass:[self class]])
        return [aEqual isEqual:self];
    if ((BOOL)_swapsInputs != [aEqual HSQTTransitionEffect_swapsInputs])
        return NO;
    Handle other = (Handle)[aEqual HSQTTransitionEffect_effectDescription];
    Handle mine = (Handle)[self HSQTTransitionEffect_effectDescription];
    if (other == NULL)
        return mine == NULL;
    if (mine == NULL)
        return NO;
    Size size = GetHandleSize(mine);
    return size == GetHandleSize(other) && memcmp(*mine, *other, size) == 0;
}

- (BOOL)HSQTTransitionEffect_swapsInputs
{
    return _swapsInputs;
}

// Reads the effect file the first time it's needed and appends the two
// source atoms; the file reference is dropped once that worked.
- (char **)HSQTTransitionEffect_effectDescription
{
    if (_effectDescription == nil && [_effectReference isKindOfClass:[NSString class]]) {
        const char *path = [_effectReference fileSystemRepresentation];
        int fd = path ? open(path, O_RDONLY) : -1;
        if (fd != -1) {
            struct stat info;
            if (fstat(fd, &info) != -1 && info.st_size >= 0 && info.st_size <= INT32_MAX) {
                Handle handle = NewHandle((Size)info.st_size);
                if (handle != NULL) {
                    if (read(fd, *handle, (size_t)info.st_size) == info.st_size) {
                        OSType sourceA = CFSwapInt32HostToBig('srcA'), sourceB = CFSwapInt32HostToBig('srcB');
                        if (HSQTInsertChild(handle, kHSQTParentAtomIsContainer, 'src ', 1, 0, 4, &sourceA, NULL) == noErr
                            && HSQTInsertChild(handle, kHSQTParentAtomIsContainer, 'src ', 2, 0, 4, &sourceB, NULL) == noErr)
                            _effectDescription = [[HSPointer alloc] initWithPointer:handle disposer:(void *)HSQTTransitionDisposeAtomContainer];
                    }
                    if (_effectDescription == nil)
                        HSQTDisposeAtomContainer(handle);
                    else {
                        [_effectReference release];
                        _effectReference = nil;
                    }
                }
            }
            close(fd);
        }
    }
    return [_effectDescription pointer];
}

- (void)dealloc
{
    [_effectReference release];
    [_effectDescription release];
    [super dealloc];
}

- (id)initWithAtomContainerData:(id)aData
{
    if (aData == nil) {
        [self release];
        return nil;
    }
    if ((self = [super init]))
        [self setAtomContainerData:aData];
    return self;
}

- (id)initWithEffectFilePath:(id)aPath swappedInputs:(BOOL)aInputs
{
    if (!(self = [super init]))
        return nil;
    _effectReference = [aPath copy];
    if (_effectReference == nil) {
        [self release];
        return nil;
    }
    _swapsInputs = aInputs;
    return self;
}

- (id)initWithEffectFilePath:(id)aPath
{
    return [self initWithEffectFilePath:aPath swappedInputs:NO];
}

@end

#pragma mark - Rendering

// QuickTime rendered the transition with its effect components (SMPTE
// wipes, dissolve, explode, implode, push, slide, zoom). Here the effect
// description's parameters drive Quartz drawing that follows those effects:
// the percent atom, tweened over the transition, says how much of source B
// covers source A.

// A parameter atom at the root: a 16.16 fixed leaf, or a container holding a
// fixed tween ('twnt' type 3 with start/end in 'data') evaluated at aTime.
static float HSQTTransitionFixed(HSQTAtomContainer aContainer, OSType aType, float aTime, float aDefault)
{
    HSQTAtom atom = HSQTFindChildByID(aContainer, kHSQTParentAtomIsContainer, aType, 0, NULL);
    if (atom == 0)
        return aDefault;
    SInt32 size = 0;
    const UInt8 *data = HSQTGetAtomDataPtr(aContainer, atom, &size);
    if (data != NULL)
        return size >= 4 ? (SInt32)CFSwapInt32BigToHost(*(const UInt32 *)data) / 65536.0f : aDefault;
    HSQTAtom tween = HSQTFindChildByID(aContainer, atom, 'data', 0, NULL);
    data = HSQTGetAtomDataPtr(aContainer, tween, &size);
    if (data == NULL || size < 8)
        return aDefault;
    float start = (SInt32)CFSwapInt32BigToHost(*(const UInt32 *)data) / 65536.0f;
    float end = (SInt32)CFSwapInt32BigToHost(*(const UInt32 *)(data + 4)) / 65536.0f;
    return start + (end - start) * aTime;
}

static SInt32 HSQTTransitionLong(HSQTAtomContainer aContainer, OSType aType, SInt32 aDefault)
{
    SInt32 value = 0;
    HSQTAtom atom = HSQTFindChildByID(aContainer, kHSQTParentAtomIsContainer, aType, 0, NULL);
    if (atom == 0 || HSQTCopyAtomDataToPtr(aContainer, atom, false, 4, &value, NULL) != noErr)
        return aDefault;
    return (SInt32)CFSwapInt32BigToHost((UInt32)value);
}

// Shapes are laid out top-down in a cell and flipped into Quartz space.
typedef struct {
    CGMutablePathRef path;
    CGAffineTransform transform;   // cell space (top-left origin) to context space
} HSQTWipeShape;

static void HSQTWipeAddPolygon(HSQTWipeShape *aShape, const CGPoint *aPoints, size_t aCount)
{
    CGPathAddLines(aShape->path, &aShape->transform, aPoints, aCount);
    CGPathCloseSubpath(aShape->path);
}

static void HSQTWipeAddSector(HSQTWipeShape *aShape, CGPoint aCenter, CGFloat aRadius, CGFloat aStart, CGFloat aSweep)
{
    // In top-down space a growing angle turns clockwise on screen.
    enum { kSteps = 48 };
    CGPoint points[kSteps + 2];
    points[0] = aCenter;
    for (int i = 0; i <= kSteps; i++) {
        CGFloat angle = aStart + aSweep * i / kSteps;
        points[i + 1] = CGPointMake(aCenter.x + aRadius * cos(angle), aCenter.y + aRadius * sin(angle));
    }
    HSQTWipeAddPolygon(aShape, points, kSteps + 2);
}

static void HSQTWipeAddStar(HSQTWipeShape *aShape, CGPoint aCenter, CGFloat aRadius)
{
    CGPoint points[10];
    for (int i = 0; i < 10; i++) {
        CGFloat radius = (i & 1) ? aRadius * 0.382 : aRadius;
        CGFloat angle = -M_PI_2 + i * M_PI / 5;
        points[i] = CGPointMake(aCenter.x + radius * cos(angle), aCenter.y + radius * sin(angle));
    }
    HSQTWipeAddPolygon(aShape, points, 10);
}

static void HSQTWipeAddHeart(HSQTWipeShape *aShape, CGPoint aCenter, CGFloat aSize)
{
    CGFloat s = aSize / 2;
    CGMutablePathRef path = aShape->path;
    const CGAffineTransform *t = &aShape->transform;
    CGPathMoveToPoint(path, t, aCenter.x, aCenter.y + s);
    CGPathAddCurveToPoint(path, t, aCenter.x - s * 1.2, aCenter.y + s * 0.2, aCenter.x - s * 1.1, aCenter.y - s * 0.9, aCenter.x, aCenter.y - s * 0.45);
    CGPathAddCurveToPoint(path, t, aCenter.x + s * 1.1, aCenter.y - s * 0.9, aCenter.x + s * 1.2, aCenter.y + s * 0.2, aCenter.x, aCenter.y + s);
    CGPathCloseSubpath(path);
}

// Grid of blocks revealed in order; the order table maps each step to a block.
static void HSQTWipeAddBlocks(HSQTWipeShape *aShape, CGRect aCell, int aColumns, int aRows, const int *aOrder, CGFloat aPercent)
{
    int count = aColumns * aRows;
    CGFloat revealed = aPercent * count;
    CGFloat w = aCell.size.width / aColumns, h = aCell.size.height / aRows;
    for (int i = 0; i < count && i < revealed; i++) {
        int block = aOrder[i];
        CGFloat fraction = MIN(revealed - i, 1);
        CGRect rect = CGRectMake(aCell.origin.x + (block % aColumns) * w, aCell.origin.y + (block / aColumns) * h, w * fraction, h);
        CGPathAddRect(aShape->path, &aShape->transform, rect);
    }
}

// The SMPTE wipe codes the shipped transitions use; others fall back to a
// left-to-right bar wipe.
static void HSQTWipeAddShape(HSQTWipeShape *aShape, SInt32 aWipeID, CGRect aCell, CGFloat p)
{
    CGFloat x = aCell.origin.x, y = aCell.origin.y, w = aCell.size.width, h = aCell.size.height;
    CGPoint center = CGPointMake(x + w / 2, y + h / 2);
    CGFloat diagonal = hypot(w, h);
    switch (aWipeID) {
        case 2:      // top to bottom
            CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(x, y, w, h * p));
            break;
        case 21:     // vertical barn door
            CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(center.x - w * p / 2, y, w * p, h));
            break;
        case 22:     // horizontal barn door
            CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(x, center.y - h * p / 2, w, h * p));
            break;
        case 41: {   // diagonal from the top left corner
            CGPoint points[3] = { { x, y }, { x + 2 * p * w, y }, { x, y + 2 * p * h } };
            HSQTWipeAddPolygon(aShape, points, 3);
            break;
        }
        case 47: {   // diagonal barn door opening along the main diagonal
            CGPoint points[4] = { { x - w, y + h * (-1 - p) }, { x + 2 * w, y + h * (2 - p) }, { x + 2 * w, y + h * (2 + p) }, { x - w, y + h * (-1 + p) } };
            HSQTWipeAddPolygon(aShape, points, 4);
            break;
        }
        case 74: {   // jaws: a wedge closing in from the right
            CGFloat apex = 1 - 2 * p;
            CGPoint points[3] = { { x + apex * w, center.y }, { x + 2 * w, y + h * (1 + p) }, { x + 2 * w, y - h * p } };
            HSQTWipeAddPolygon(aShape, points, 3);
            break;
        }
        case 101:    // rectangle iris
            CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(center.x - w * p / 2, center.y - h * p / 2, w * p, h * p));
            break;
        case 102: {  // diamond iris
            CGPoint points[4] = { { center.x, center.y - h * p }, { center.x + w * p, center.y }, { center.x, center.y + h * p }, { center.x - w * p, center.y } };
            HSQTWipeAddPolygon(aShape, points, 4);
            break;
        }
        case 119: {  // circle iris
            CGFloat radius = p * diagonal / 2;
            CGPathAddEllipseInRect(aShape->path, &aShape->transform, CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2));
            break;
        }
        case 128:    // five-pointed star iris
            HSQTWipeAddStar(aShape, center, p * diagonal * 1.35);
            break;
        case 130:    // heart iris
            HSQTWipeAddHeart(aShape, center, p * diagonal * 2.2);
            break;
        case 201:    // clock, from twelve
            HSQTWipeAddSector(aShape, center, diagonal, -M_PI_2, 2 * M_PI * p);
            break;
        case 207:    // four-blade windmill
            for (int i = 0; i < 4; i++)
                HSQTWipeAddSector(aShape, center, diagonal, -M_PI_2 + i * M_PI_2, M_PI_2 * p);
            break;
        case 223:    // wiper sweeping over the bottom centre
            HSQTWipeAddSector(aShape, CGPointMake(center.x, y + h), diagonal, M_PI, M_PI * p);
            break;
        case 231:    // spotlight: fans opening up and down from the centre
            HSQTWipeAddSector(aShape, center, diagonal, -M_PI_2 - M_PI_2 * p, M_PI * p);
            HSQTWipeAddSector(aShape, center, diagonal, M_PI_2 - M_PI_2 * p, M_PI * p);
            break;
        case 301: {  // lawnmower: rows mowed back and forth
            enum { kColumns = 8, kRows = 8 };
            int order[kColumns * kRows];
            for (int row = 0; row < kRows; row++)
                for (int column = 0; column < kColumns; column++)
                    order[row * kColumns + column] = row * kColumns + ((row & 1) ? kColumns - 1 - column : column);
            HSQTWipeAddBlocks(aShape, aCell, kColumns, kRows, order, p);
            break;
        }
        case 310: {  // spiral of blocks from the outside in
            enum { kColumns = 8, kRows = 8 };
            int order[kColumns * kRows], count = 0;
            int left = 0, top = 0, right = kColumns - 1, bottom = kRows - 1;
            while (left <= right && top <= bottom) {
                for (int i = left; i <= right; i++) order[count++] = top * kColumns + i;
                for (int i = top + 1; i <= bottom; i++) order[count++] = i * kColumns + right;
                if (top < bottom)
                    for (int i = right - 1; i >= left; i--) order[count++] = bottom * kColumns + i;
                if (left < right)
                    for (int i = bottom - 1; i > top; i--) order[count++] = i * kColumns + left;
                left++; top++; right--; bottom--;
            }
            HSQTWipeAddBlocks(aShape, aCell, kColumns, kRows, order, p);
            break;
        }
        case 350: {  // waterfall: columns falling one after another
            enum { kColumns = 8 };
            CGFloat stagger = 0.5;
            for (int i = 0; i < kColumns; i++) {
                CGFloat fall = MIN(MAX(p * (1 + stagger) - stagger * i / (kColumns - 1), 0), 1);
                CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(x + w * i / kColumns, y, w / kColumns, h * fall));
            }
            break;
        }
        default:     // left to right
            CGPathAddRect(aShape->path, &aShape->transform, CGRectMake(x, y, w * p, h));
            break;
    }
}

static void HSQTDrawImage(CGContextRef aContext, CGImageRef aImage, CGRect aRect, CGFloat aAlpha)
{
    if (aImage == NULL || aAlpha <= 0)
        return;
    CGContextSaveGState(aContext);
    CGContextSetAlpha(aContext, aAlpha);
    CGContextDrawImage(aContext, aRect, aImage);
    CGContextRestoreGState(aContext);
}

static void HSQTDrawScaledImage(CGContextRef aContext, CGImageRef aImage, CGRect aBounds, CGPoint aCenter, CGFloat aScale, CGFloat aAlpha)
{
    CGRect rect = CGRectMake(aCenter.x - (aCenter.x - aBounds.origin.x) * aScale, aCenter.y - (aCenter.y - aBounds.origin.y) * aScale, aBounds.size.width * aScale, aBounds.size.height * aScale);
    HSQTDrawImage(aContext, aImage, rect, aAlpha);
}

static void HSQTTransitionDraw(CGContextRef aContext, CGRect aBounds, HSQTAtomContainer aDescription, CGImageRef aSourceA, CGImageRef aSourceB, CGFloat aTime)
{
    CGFloat p = MIN(MAX(HSQTTransitionFixed(aDescription, 'pcnt', aTime, aTime), 0), 1);
    CGFloat w = aBounds.size.width, h = aBounds.size.height;
    OSType what = 0;
    HSQTAtom whatAtom = HSQTFindChildByID(aDescription, kHSQTParentAtomIsContainer, 'what', 0, NULL);
    if (whatAtom != 0 && HSQTCopyAtomDataToPtr(aDescription, whatAtom, false, 4, &what, NULL) == noErr)
        what = CFSwapInt32BigToHost(what);
    CGPoint center = CGPointMake(w / 2 * (1 + HSQTTransitionFixed(aDescription, 'xcnt', aTime, 0)), h / 2 * (1 + HSQTTransitionFixed(aDescription, 'ycnt', aTime, 0)));
    switch (what) {
        case 'dslv':
            HSQTDrawImage(aContext, aSourceA, aBounds, 1);
            HSQTDrawImage(aContext, aSourceB, aBounds, p);
            break;
        case 'push': {
            // From: 0 top, 2 left, 3 bottom, 4 (and 1) right.
            CGPoint direction;
            switch (HSQTTransitionLong(aDescription, 'from', 0)) {
                case 2: direction = CGPointMake(-w, 0); break;
                case 3: direction = CGPointMake(0, -h); break;
                case 1: case 4: direction = CGPointMake(w, 0); break;
                default: direction = CGPointMake(0, h); break;
            }
            HSQTDrawImage(aContext, aSourceA, CGRectOffset(aBounds, -direction.x * p, -direction.y * p), 1);
            HSQTDrawImage(aContext, aSourceB, CGRectOffset(aBounds, direction.x * (1 - p), direction.y * (1 - p)), 1);
            break;
        }
        case 'slid': {
            // The angle is the direction B slides in: 0 down, 90 left, 180 up, 270 right.
            CGFloat angle = HSQTTransitionFixed(aDescription, 'angl', aTime, 0) * M_PI / 180;
            HSQTDrawImage(aContext, aSourceA, aBounds, 1);
            HSQTDrawImage(aContext, aSourceB, CGRectOffset(aBounds, sin(angle) * w * (1 - p), cos(angle) * h * (1 - p)), 1);
            break;
        }
        case 'zoom':
            HSQTDrawImage(aContext, aSourceA, aBounds, 1);
            HSQTDrawScaledImage(aContext, aSourceB, aBounds, center, p, 1);
            break;
        case 'xplo': {  // A bursts outwards from the centre, which opens onto B
            CGFloat reach = 0;
            for (int i = 0; i < 4; i++)
                reach = MAX(reach, hypot(((i & 1) ? w : 0) - center.x, ((i & 2) ? h : 0) - center.y));
            CGFloat radius = p * reach;
            HSQTDrawScaledImage(aContext, aSourceA, aBounds, center, 1 + p * 2, 1);
            CGContextSaveGState(aContext);
            CGContextAddEllipseInRect(aContext, CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2));
            CGContextClip(aContext);
            HSQTDrawImage(aContext, aSourceB, aBounds, 1);
            CGContextRestoreGState(aContext);
            break;
        }
        case 'mplo':  // A collapses into the centre, revealing B
            HSQTDrawImage(aContext, aSourceB, aBounds, 1);
            HSQTDrawScaledImage(aContext, aSourceA, aBounds, center, 1 - p, 1);
            break;
        case 'smpt': case 'smp2': case 'smp3': case 'smp4': {
            // Repeated 'hori' x 'vert' times; 'soft' edges are drawn hard.
            SInt32 columns = MAX(HSQTTransitionLong(aDescription, 'hori', 1), 1), rows = MAX(HSQTTransitionLong(aDescription, 'vert', 1), 1);
            SInt32 wipeID = HSQTTransitionLong(aDescription, 'wpID', 1);
            HSQTDrawImage(aContext, aSourceA, aBounds, 1);
            HSQTWipeShape shape = { CGPathCreateMutable(), CGAffineTransformMake(1, 0, 0, -1, aBounds.origin.x, aBounds.origin.y + h) };
            CGFloat cellWidth = w / columns, cellHeight = h / rows;
            for (SInt32 row = 0; row < rows; row++)
                for (SInt32 column = 0; column < columns; column++) {
                    CGRect cell = CGRectMake(column * cellWidth, row * cellHeight, cellWidth, cellHeight);
                    CGPathRelease(shape.path);
                    shape.path = CGPathCreateMutable();
                    HSQTWipeAddShape(&shape, wipeID, cell, p);
                    CGContextSaveGState(aContext);
                    CGContextClipToRect(aContext, CGRectApplyAffineTransform(cell, shape.transform));
                    CGContextAddPath(aContext, shape.path);
                    if (!CGPathIsEmpty(shape.path)) {
                        CGContextClip(aContext);
                        HSQTDrawImage(aContext, aSourceB, aBounds, 1);
                    }
                    CGContextRestoreGState(aContext);
                    SInt32 border = HSQTTransitionLong(aDescription, 'widt', 0);
                    if (border > 0 && p > 0 && p < 1 && !CGPathIsEmpty(shape.path)) {
                        UInt16 rgb[3] = { 0, 0, 0 };
                        HSQTAtom color = HSQTFindChildByID(aDescription, kHSQTParentAtomIsContainer, 'bclr', 0, NULL);
                        HSQTCopyAtomDataToPtr(aDescription, color, true, 6, rgb, NULL);
                        CGContextSaveGState(aContext);
                        CGContextClipToRect(aContext, CGRectApplyAffineTransform(cell, shape.transform));
                        CGContextAddPath(aContext, shape.path);
                        CGContextSetRGBStrokeColor(aContext, CFSwapInt16BigToHost(rgb[0]) / 65535.0, CFSwapInt16BigToHost(rgb[1]) / 65535.0, CFSwapInt16BigToHost(rgb[2]) / 65535.0, 1);
                        CGContextSetLineWidth(aContext, border);
                        CGContextStrokePath(aContext);
                        CGContextRestoreGState(aContext);
                    }
                }
            CGPathRelease(shape.path);
            break;
        }
        default:      // unknown effects cut halfway
            HSQTDrawImage(aContext, p < 0.5 ? aSourceA : aSourceB, aBounds, 1);
            break;
    }
}

// NSImage, CGImage or CVPixelBuffer sources become CGImages.
static CGImageRef HSQTTransitionCreateImage(id aImage)
{
    if (aImage == nil)
        return NULL;
    if ([aImage isKindOfClass:[NSImage class]]) {
        NSSize size = [(NSImage *)aImage size];
        if (size.width <= 0 || size.height <= 0)
            return NULL;
        return CGImageRetain([(NSImage *)aImage CGImageForProposedRect:NULL context:nil hints:nil]);
    }
    CFTypeID type = CFGetTypeID((CFTypeRef)aImage);
    if (type == CGImageGetTypeID())
        return CGImageRetain((CGImageRef)aImage);
    if (type == CVPixelBufferGetTypeID())
        return CGEImageCreateWithPixelBuffer((CVPixelBufferRef)aImage, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    return NULL;
}

@implementation HSQTTransitionQuartzRenderer

// Original quirk kept: frames only come through renderFrameAtTime:.
- (struct CGImage *)frameImageAtTime:(double)aTime
{
    return NULL;
}

- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext
{
    CGImageRef image = [self HSQTTransitionQuartzRenderer_createFrameImageAtTime:aTime];
    if (image != NULL) {
        CGContextDrawImage(aContext, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
        CGImageRelease(image);
    }
}

- (struct CGImage *)HSQTTransitionQuartzRenderer_createFrameImageAtTime:(double)aTime
{
    if (_size.width <= 0 || _size.height <= 0)
        return NULL;
    size_t width = lroundf(ceilf(_size.width)), height = lroundf(ceilf(_size.height));
    if (width == 0 || height == 0)
        return NULL;
    if (_isSizeChanged && _frameContext != NULL) {
        CGContextRelease(_frameContext);
        _frameContext = NULL;
        free(_frameBuffer);
        _frameBuffer = NULL;
    }
    _isSizeChanged = 0;
    if (_frameContext == NULL) {
        size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
        _frameBuffer = calloc(height, rowBytes);
        if (_frameBuffer == NULL)
            return NULL;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _frameContext = colorSpace ? CGBitmapContextCreate(_frameBuffer, width, height, 8, rowBytes, colorSpace, (CGBitmapInfo)(kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)) : NULL;
        CGColorSpaceRelease(colorSpace);
        if (_frameContext == NULL) {
            free(_frameBuffer);
            _frameBuffer = NULL;
            return NULL;
        }
        CGContextSetInterpolationQuality(_frameContext, kCGInterpolationHigh);
    }
    if (_startFrame == NULL)
        _startFrame = HSQTTransitionCreateImage(_startImage);
    if (_endFrame == NULL)
        _endFrame = HSQTTransitionCreateImage(_endImage);
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGContextClearRect(_frameContext, bounds);
    HSQTTransitionDraw(_frameContext, bounds, (HSQTAtomContainer)[_effectDescription pointer],
                       _swapsInputs ? _endFrame : _startFrame, _swapsInputs ? _startFrame : _endFrame,
                       MIN(MAX(aTime, 0), 1));
    return CGBitmapContextCreateImage(_frameContext);
}

- (void)setEndImage:(id)aImage
{
    if (_endImage != aImage) {
        [aImage retain];
        [_endImage release];
        _endImage = aImage;
        CGImageRelease(_endFrame);
        _endFrame = NULL;
    }
}

- (void)setStartImage:(id)aImage
{
    if (_startImage != aImage) {
        [aImage retain];
        [_startImage release];
        _startImage = aImage;
        CGImageRelease(_startFrame);
        _startFrame = NULL;
    }
}

- (void)setRendererSize:(CGSize)aSize
{
    if (!CGSizeEqualToSize(_size, aSize)) {
        _size = aSize;
        _isSizeChanged = 1;
    }
}

- (CGSize)rendererSize
{
    return _size;
}

- (char **)effectDescription
{
    return [_effectDescription pointer];
}

- (void)dealloc
{
    CGContextRelease(_frameContext);
    free(_frameBuffer);
    CGImageRelease(_startFrame);
    CGImageRelease(_endFrame);
    [_startImage release];
    [_endImage release];
    [_effectDescription release];
    [super dealloc];
}

- (id)initWithSize:(CGSize)aSize effectDescription:(id)aDescription swappedInputs:(BOOL)aInputs
{
    if ((self = [super init])) {
        _effectDescription = [aDescription retain];
        _size = aSize;
        _swapsInputs = aInputs;
    }
    return self;
}

// A renderer needs an effect description.
- (id)init
{
    [self release];
    return nil;
}

@end
