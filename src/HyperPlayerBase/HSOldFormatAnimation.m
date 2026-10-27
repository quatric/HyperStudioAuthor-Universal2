#import "HSOldFormatAnimation.h"
// An old-format animation ("Sprt" sprite data), rebuilt as a cel movie, a
// still image or a QuickTime movie moving along a path. The sprite, its
// path and its film are big-endian 68k records; the Path and Film structs
// only describe them for 32-bit builds, so fields are read by byte offset.

static unsigned short HSOldFormatAnimationShort(const unsigned char *aBytes, NSUInteger aOffset)
{
    return (unsigned short)(aBytes[aOffset] << 8 | aBytes[aOffset + 1]);
}

static unsigned int HSOldFormatAnimationLong(const unsigned char *aBytes, NSUInteger aOffset)
{
    return (unsigned int)aBytes[aOffset] << 24 | (unsigned int)aBytes[aOffset + 1] << 16 | (unsigned int)aBytes[aOffset + 2] << 8 | aBytes[aOffset + 3];
}

static void HSOldFormatAnimationReleaseData(void *aInfo, const void *aData, size_t aSize)
{
    [(id)aInfo release];
}

// Film layout: frame count at 0x2e, the shared image data's length at 0xa6,
// then 0x78-byte cel entries from 0xf2 (bounds, frame data offset and length
// at 0x3c and 0x40, frame time at 0x50); the image data follows one entry
// after the last.
enum {
    HSOldFormatFilmFrameCount = 0x2e,
    HSOldFormatFilmImageDataLength = 0xa6,
    HSOldFormatFilmFirstCel = 0xf2,
    HSOldFormatCelSize = 0x78,
    HSOldFormatCelDataOffset = 0x3c,
    HSOldFormatCelDataLength = 0x40,
    HSOldFormatCelTime = 0x50
};

@implementation HSOldFormatAnimation

// The film's frames: decoded as a PPak sequence (format 2), a single frame,
// or ARGB frames cut from one bitmap. One frame makes an image object, more
// a cel movie; either is centred on the path's first point.
- (void)HSOldFormatAnimation_createMovieObjectWithImageSequence:(struct Film *)aSequence filmMotionTime:(NSUInteger)aTime firstPoint:(NSPoint)aPoint
{
    const unsigned char *film = (const unsigned char *)aSequence;
    unsigned int count = HSOldFormatAnimationLong(film, HSOldFormatFilmFrameCount);
    unsigned int imageDataLength = HSOldFormatAnimationLong(film, HSOldFormatFilmImageDataLength);
    if (!count || !imageDataLength)
        return;
    short (*bounds)[4] = malloc(count * sizeof(*bounds));
    unsigned short *times = malloc(count * sizeof(*times));
    unsigned int *offsets = malloc(count * sizeof(*offsets));
    unsigned int *lengths = malloc(count * sizeof(*lengths));
    if (!bounds || !times || !offsets || !lengths)
        goto done;
    for (unsigned int i = 0; i < count; i++) {
        const unsigned char *cel = film + HSOldFormatFilmFirstCel + i * HSOldFormatCelSize;
        for (int j = 0; j < 4; j++)
            bounds[i][j] = (short)HSOldFormatAnimationShort(cel, j * 2);
        offsets[i] = HSOldFormatAnimationLong(cel, HSOldFormatCelDataOffset);
        lengths[i] = HSOldFormatAnimationLong(cel, HSOldFormatCelDataLength);
        times[i] = HSOldFormatAnimationShort(cel, HSOldFormatCelTime);
    }
    const unsigned char *imageBytes = film + HSOldFormatFilmFirstCel + (count + 1) * HSOldFormatCelSize;
    NSData *imageData = [NSData dataWithBytesNoCopy:(void *)imageBytes length:imageDataLength freeWhenDone:NO];
    if (!imageData)
        goto done;
    HSOldFormatGraphicsImport *graphicsImport = [[self oldFormatDocument] graphicsImport];
    float width = fabsf((float)(bounds[0][3] - bounds[0][1]));
    float height = fabsf((float)(bounds[0][2] - bounds[0][0]));
    NSMutableArray *images = [NSMutableArray array];
    // Quirk kept: the frame times are collected but the movie doesn't use them.
    NSMutableArray *frameTimes = [NSMutableArray array];
    if (HSOldFormatAnimationShort(film, 0x20) == 2) {
        NSImage *image = [graphicsImport imageForPPakData:imageData mask:nil frameData:nil];
        if (!image)
            goto done;
        [_timeFrameArray removeAllObjects];
        [images addObject:image];
        [frameTimes addObject:[NSNumber numberWithUnsignedShort:times[0]]];
        for (unsigned int i = 1; i < count; i++) {
            NSData *frameData = [[NSData alloc] initWithBytesNoCopy:(void *)(imageBytes + imageDataLength + offsets[i]) length:lengths[i] freeWhenDone:NO];
            image = [graphicsImport imageForPPakData:imageData mask:nil frameData:frameData];
            if (!image)
                image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
            [images addObject:image];
            [frameTimes addObject:[NSNumber numberWithUnsignedShort:times[i]]];
            [_timeFrameArray addObject:[NSNumber numberWithUnsignedLong:aTime]];
            [frameData release];
        }
    } else if (count == 1) {
        NSImage *image = [graphicsImport imageForPPakData:imageData mask:nil frameData:nil];
        // Fix: a frame that doesn't decode is skipped rather than added as nil.
        if (image)
            [images addObject:image];
        [frameTimes addObject:[NSNumber numberWithUnsignedShort:times[0]]];
    } else {
        unsigned int bitmapWidth = 0;
        unsigned int bitmapHeight = 0;
        unsigned int bytesPerRow = 0;
        NSData *bitmap = [graphicsImport imageARGB8888PremultipliedDataForPPakData:imageData mask:nil width:&bitmapWidth height:&bitmapHeight bytesPerRow:&bytesPerRow];
        if (!bitmap || !bitmapWidth || !bitmapHeight || !bytesPerRow)
            goto done;
        const unsigned char *bitmapBytes = [bitmap bytes];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        for (unsigned int i = 0; i < count; i++) {
            height = (float)abs(bounds[i][2] - bounds[i][0]);
            width = (float)abs(bounds[i][3] - bounds[i][1]);
            const unsigned char *frameBytes = bitmapBytes + bounds[i][0] * (int)bytesPerRow + bounds[i][1] * 4;
            CGDataProviderRef provider = CGDataProviderCreateWithData(bitmap, frameBytes, (size_t)((float)bytesPerRow * height), HSOldFormatAnimationReleaseData);
            if (!provider)
                continue;
            [bitmap retain];
            CGImageRef cgImage = CGImageCreate((size_t)width, (size_t)height, 8, 32, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, provider, NULL, false, kCGRenderingIntentDefault);
            CGDataProviderRelease(provider);
            if (!cgImage)
                continue;
            HSCGImageImageRep *representation = [[HSCGImageImageRep alloc] initWithCGImage:cgImage];
            CGImageRelease(cgImage);
            NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
            [image addRepresentation:representation];
            [representation release];
            [images addObject:image];
            [image release];
            [frameTimes addObject:[NSNumber numberWithUnsignedShort:times[i]]];
        }
        CGColorSpaceRelease(colorSpace);
    }

    id applier;
    if ([images count] == 1 && !_imageObject) {
        HSImageObject *imageObject = [HSImageObject defaultObject];
        [imageObject setShadowEnabled:NO];
        HSOldFormatDocument *document = [self oldFormatDocument];
        id media = [document mediaForImage:[images objectAtIndex:0]];
        HSImage *image = [HSImage new];
        [image setHyperOwner:[[document parser] valuesBufferObjectForKey:@"~Card"]];
        [image setMedia:media];
        [imageObject setHyperImageObject:image];
        [image release];
        applier = [[imageObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        [imageObject moveToHyperBegin];
        [_imageObject release];
        _imageObject = [imageObject retain];
    } else {
        id framesMedia = [HSCelMovieObject framesMediaWithImages:images];
        HSCelMovieObject *movie = [[HSCelMovieObject alloc] initWithFramesMedia:framesMedia precachedFrames:images frameTimeLength:0 frameSize:NSMakeSize(width, height)];
        [[movie queryHyperInterface:@protocol(HSMutableShadowAttributes)] setShadowEnabled:NO];
        applier = [[movie queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        [movie moveToHyperBegin];
        id playable = [movie queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
        [playable setHyperPlayRange:HSMakeTimeRange(0, [playable hyperDuration])];
        [[movie queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
        // Fix: a movie from an earlier initialisation was leaked.
        [_movieObject release];
        _movieObject = (HSConcreteCardObject *)movie;
    }
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(aPoint.x + width * -0.5, aPoint.y + height * -0.5) withLayoutGuidingContext:nil];
    [applier setSize:NSMakeSize(width, height) withLayoutGuidingContext:nil];

done:
    free(offsets);
    free(times);
    free(bounds);
    free(lengths);
}

// The movie is the file named by the Pascal string; centred on the rect's
// origin, which is the path's first point.
- (void)HSOldFormatAnimation_createMovieObjectWithQTMovieData:(void *)aData objectRect:(NSRect)aRect
{
    const unsigned char *bytes = aData;
    NSString *name = [[[NSString alloc] initWithBytesNoCopy:(void *)(bytes + 1) length:bytes[0] encoding:NSMacOSRomanStringEncoding freeWhenDone:NO] autorelease];
    NSString *path = [[self oldFormatDocument] actionObjectPathForApplePath:name];
    NSData *movieData = nil;
    BOOL isDirectory = YES;
    if (path && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory)
        movieData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
    id media = [HSNewMedia mediaWithData:movieData name:@"Animation Movie" type:@"mov"];
    HSMovieObject *movie = [(HSMovieObject *)[HSMovieObject alloc] initWithMedia:media];
    [movie setHidden:YES];
    [[movie queryHyperInterface:@protocol(HSMutableShadowAttributes)] setShadowEnabled:NO];
    id applier = [[movie queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(aRect.origin.x + aRect.size.width * -0.5, aRect.origin.y + aRect.size.height * -0.5) withLayoutGuidingContext:nil];
    [applier setSize:aRect.size withLayoutGuidingContext:nil];
    [movie moveToHyperBegin];
    id playable = [movie queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
    [playable setHyperPlayRange:HSMakeTimeRange(0, [playable hyperDuration])];
    _framesPerSec = [[movie queryHyperInterface:@protocol(HSFramesPerSecondAttributes)] hyperFramesPerSecond];
    [[movie queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
    // Fix: a movie from an earlier initialisation was leaked.
    [_movieObject release];
    _movieObject = (HSConcreteCardObject *)movie;
}

// Path layout: point count at 0x6a, then 0x1c-byte points from 0x6e (x, y,
// and at 0x74 the time in ms to the next point). Key frames are the times
// (s) at which each point is reached; a zero time counts as 0.1 ms, longer
// than 9.999 s as that.
- (void)HSOldFormatAnimation_initializeBezierPath:(struct Path *)aPath pointCount:(unsigned int *)aCount firstPoint:(NSPoint *)aPoint
{
    const unsigned char *path = (const unsigned char *)aPath;
    if (!path)
        return;
    unsigned int count = HSOldFormatAnimationLong(path, 0x6a);
    if (!count)
        return;
    NSPoint *points = malloc(count * sizeof(NSPoint) + 1);
    if (!points)
        return;
    unsigned int *times = malloc(count * sizeof(unsigned int) + 1);
    if (!times) {
        free(points);
        return;
    }
    for (unsigned int i = 0; i < count; i++) {
        const unsigned char *point = path + 0x6e + i * 0x1c;
        points[i] = NSMakePoint(HSOldFormatAnimationShort(point, 0), HSOldFormatAnimationShort(point, 2));
        times[i] = HSOldFormatAnimationLong(point, 6);
    }
    NSPoint first = points[0];
    // Fix: an earlier initialisation's path and frames were leaked.
    [_bezierPath release];
    [_keyFrames release];
    [_timeFrameArray release];
    _bezierPath = [[NSBezierPath bezierPath] retain];
    [_bezierPath appendBezierPathWithPoints:points count:count];
    free(points);
    _keyFrames = [NSMutableArray new];
    _timeFrameArray = [NSMutableArray new];
    [_keyFrames addObject:[NSNumber numberWithDouble:0]];
    double keyTime = 0;
    for (unsigned int i = 0; i + 1 < count; i++) {
        unsigned int time = MIN(times[i], 9999u);
        keyTime += time ? time * 0.001 : 0.0001;
        [_keyFrames addObject:[NSNumber numberWithDouble:keyTime]];
        [_timeFrameArray addObject:[NSNumber numberWithUnsignedLong:times[i]]];
    }
    free(times);
    if (aCount)
        *aCount = count;
    if (aPoint)
        *aPoint = first;
}

- (void)HSOldFormatAnimation_setTransColor:(id)aColor
{
    if (_transColor != aColor) {
        [_transColor release];
        _transColor = [aColor retain];
    }
}

// Reads the sprite record (at least 0x258 bytes, "Sprt"): its settings, the
// path from 0x258 and the film after it, a QuickTime movie (kind 3) or a
// sequence of frames.
- (void)HSOldFormatAnimation_animationStructuresInit
{
    if (!_spriteData)
        return;
    NSUInteger length = [_spriteData length];
    if (length < 0x258) {
        _isAnimationInited = YES;
        return;
    }
    const unsigned char *sprite = [_spriteData bytes];
    _isAnimationInited = YES;
    if (!sprite || memcmp(sprite, "Sprt", 4) != 0)
        return;
    _hideMode = 3;
    unsigned int pointCount = 0;
    NSPoint firstPoint = NSZeroPoint;
    if (length >= 0x2e2)
        [self HSOldFormatAnimation_initializeBezierPath:(struct Path *)(sprite + 0x258) pointCount:&pointCount firstPoint:&firstPoint];
    _layerKind = (short)HSOldFormatAnimationShort(sprite, 0x8c);
    _triggerKind = (short)HSOldFormatAnimationShort(sprite, 0x34);
    _timerKind = (short)HSOldFormatAnimationShort(sprite, 0x14e);
    _motionKind = (short)HSOldFormatAnimationShort(sprite, 0x168);
    _isShowFirstFrame = sprite[0x82] & 1;
    _isShowLastFrame = sprite[0x83] & 1;
    _isMatchToMovement = HSOldFormatAnimationShort(sprite, 0x32) == 4;
    _isAllowClones = sprite[0x7c] & 1;
    _isEndFlip = sprite[0x8b] & 1;
    _filmMotionWhen = HSOldFormatAnimationShort(sprite, 0xf4);
    unsigned int filmMotionTime = HSOldFormatAnimationLong(sprite, 0x114);
    if (filmMotionTime)
        _framesPerSec = 1000.0 / filmMotionTime;
    _playSeconds = HSOldFormatAnimationLong(sprite, 0x54);
    _playPathRepeats = HSOldFormatAnimationLong(sprite, 0x180);
    _playFrameRepeats = HSOldFormatAnimationLong(sprite, 0x128);
    _isNonStop = HSOldFormatAnimationShort(sprite, 0x34) == 0;
    unsigned int moveTime = HSOldFormatAnimationLong(sprite, 0x16c);
    _moveTimesPerSecond = moveTime ? 1000.0 / moveTime : 1.0f;
    _moveMultiple = HSOldFormatAnimationLong(sprite, 0x170);
    _moveMultiple = _moveMultiple == 0 ? 1.0f : 100.0f / _moveMultiple;
    _moveSeconds = (moveTime * pointCount) / 1000.0;
    _isBegFlipHor = HSOldFormatAnimationShort(sprite, 0x96) == 180;
    _isBegFlipVert = HSOldFormatAnimationShort(sprite, 0x98) == 180;
    _isEndFlipHor = HSOldFormatAnimationShort(sprite, 0x9c) == 180;
    _isEndFlipVert = HSOldFormatAnimationShort(sprite, 0x9e) == 180;
    _isStartEnd = HSOldFormatAnimationLong(sprite, 0x178) == 0xffffffff;
    _goingDraw = sprite[0x85] & 1;
    _returnDraw = sprite[0x86] & 1;
    _goingOver = sprite[0x88] & 1;
    _returnOver = sprite[0x89] & 1;

    unsigned int filmOffset = HSOldFormatAnimationLong(sprite, 0x1c8);
    if (filmOffset + 0x3c2 > length)
        return;
    const unsigned char *film = sprite + 0x258 + filmOffset;
    _isHasTransColor = HSOldFormatAnimationShort(film, 0x22) != 0;
    if (HSOldFormatAnimationShort(film, 0x20) == 3) {
        float width = fabsf((float)(HSOldFormatAnimationShort(film, 0xf8) - HSOldFormatAnimationShort(film, 0xf4)));
        float height = fabsf((float)(HSOldFormatAnimationShort(film, 0xf6) - HSOldFormatAnimationShort(film, 0xf2)));
        [self HSOldFormatAnimation_createMovieObjectWithQTMovieData:(void *)(film + 0x16a) objectRect:NSMakeRect(firstPoint.x, firstPoint.y, width, height)];
        return;
    }
    [self HSOldFormatAnimation_createMovieObjectWithImageSequence:(struct Film *)film filmMotionTime:filmMotionTime firstPoint:firstPoint];
    // The transparent colour, 8-bit or 16-bit per component.
    unsigned short red = HSOldFormatAnimationShort(film, 0x28);
    unsigned short green = HSOldFormatAnimationShort(film, 0x2a);
    unsigned short blue = HSOldFormatAnimationShort(film, 0x2c);
    float scale = (unsigned short)(red | green | blue) < 0x100 ? 255.0f : 65535.0f;
    [self HSOldFormatAnimation_setTransColor:[NSColor colorWithDeviceRed:red / scale green:green / scale blue:blue / scale alpha:1]];
}

- (id)timeFrameArray
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _timeFrameArray;
}

- (id)keyFrames
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _keyFrames;
}

- (id)bezierPath
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _bezierPath;
}

- (void)setImageObject:(id)aObject
{
    if (_imageObject != aObject) {
        [_imageObject release];
        _imageObject = [aObject retain];
    }
}

- (id)imageObject
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _imageObject;
}

- (void)setMovieObject:(id)aObject
{
    if (_movieObject != aObject) {
        [_movieObject release];
        _movieObject = [aObject retain];
    }
}

- (id)movieObject
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _movieObject;
}

// New sprite data is read again on next access.
- (void)setSpriteData:(id)aData
{
    if (_spriteData != aData) {
        [_spriteData release];
        _spriteData = [aData retain];
        _isAnimationInited = NO;
    }
}

- (id)spriteData
{
    return _spriteData;
}

- (void)setOldFormatDocument:(id)aDocument
{
    _oldFormatDocument = aDocument;
}

- (id)oldFormatDocument
{
    return _oldFormatDocument;
}

- (short)hideMode
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _hideMode;
}

- (BOOL)returnOver
{
    return _returnOver;
}

- (BOOL)goingOver
{
    return _goingOver;
}

- (BOOL)returnDraw
{
    return _returnDraw;
}

- (BOOL)goingDraw
{
    return _goingDraw;
}

- (BOOL)isStartEnd
{
    return _isStartEnd;
}

- (BOOL)isEndFlipVert
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isEndFlipVert;
}

- (BOOL)isEndFlipHor
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isEndFlipHor;
}

- (BOOL)isBegFlipVert
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isBegFlipVert;
}

- (BOOL)isBegFlipHor
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isBegFlipHor;
}

- (BOOL)isEndFlip
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isEndFlip;
}

- (BOOL)isDontErase
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isDontErase;
}

- (BOOL)isFloatOver
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isFloatOver;
}

- (CGFloat)moveSeconds
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _moveSeconds;
}

- (CGFloat)moveMultiple
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _moveMultiple;
}

- (CGFloat)moveTimesPerSecond
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _moveTimesPerSecond;
}

- (NSInteger)layerType
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _layerType;
}

- (BOOL)isNonStop
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isNonStop;
}

- (CGFloat)playFrameRepeats
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _playFrameRepeats;
}

- (CGFloat)playPathRepeats
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _playPathRepeats;
}

- (CGFloat)playSeconds
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _playSeconds;
}

- (CGFloat)framesPerSec
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _framesPerSec;
}

- (NSInteger)filmMotionWhen
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _filmMotionWhen;
}

// Fix: the default was an uninitialised NSColor ([[NSColor alloc] init]);
// it's clear now.
- (id)transColor
{
    if (!_transColor)
        [self HSOldFormatAnimation_setTransColor:[NSColor clearColor]];
    return _transColor;
}

- (BOOL)isHasTransColor
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isHasTransColor;
}

- (BOOL)isAllowClones
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isAllowClones;
}

- (BOOL)isMatchToMovement
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isMatchToMovement;
}

- (BOOL)isShowLastFrame
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isShowLastFrame;
}

- (BOOL)isShowFirstFrame
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _isShowFirstFrame;
}

- (short)layerKind
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _layerKind;
}

- (short)motionKind
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _motionKind;
}

- (short)timerKind
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _timerKind;
}

- (short)triggerKind
{
    if (!_isAnimationInited)
        [self HSOldFormatAnimation_animationStructuresInit];
    return _triggerKind;
}

- (void)dealloc
{
    _oldFormatDocument = nil;
    [_spriteData release];
    [_movieObject release];
    [_imageObject release];
    [_bezierPath release];
    [_keyFrames release];
    [_timeFrameArray release];
    [_transColor release];
    [super dealloc];
}

@end
