#import "HSGIFMovieNodeUnit.h"
#import "HSCGImageImageRep.h"
#import "HSCelMovieObjectFramesLazyCacheItem.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSUID.h"

static CFDictionaryRef sDefaultImageSourceOptions = NULL;

// A cel movie playing the frames of an animated GIF. The frames media is a
// single GIF media UID; each frame gets a generated UID and is decoded from
// the GIF on demand.
@implementation HSGIFMovieNodeUnit

+ (struct __CFDictionary *)HSGIFMovieNodeUnit_defaultImageSourceOptions
{
    if (sDefaultImageSourceOptions == NULL) {
        const void *key = kCGImageSourceShouldCache;
        const void *value = kCFBooleanFalse;
        sDefaultImageSourceOptions = CFDictionaryCreate(NULL, &key, &value, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return (struct __CFDictionary *)sDefaultImageSourceOptions;
}

+ (id)keysForStoring
{
    return [NSArray arrayWithObjects:[@"generatedFramesMedia" extraKeyForCollection], @"defaultFrameSizeData", @"framesPerSecond",
            @"playLoopMode", @"eraseWhenDone", @"croppingPath", @"animatedGIFMediaUID", nil];
}

// The frame time comes from the first frame's GIF delay.
- (void)HSGIFMovieNodeUnit_calculateFrameTimeLengthForFramesImageSource:(struct CGImageSource *)aSource
{
    if (aSource == NULL)
        return;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(aSource, 0, [HSGIFMovieNodeUnit HSGIFMovieNodeUnit_defaultImageSourceOptions]);
    if (properties == NULL)
        return;
    CFDictionaryRef GIFProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
    if (GIFProperties != NULL) {
        CFTypeRef delay = CFDictionaryGetValue(GIFProperties, kCGImagePropertyGIFDelayTime);
        double delayTime = 0;
        if (delay != NULL && CFGetTypeID(delay) == CFNumberGetTypeID() && CFNumberGetValue(delay, kCFNumberDoubleType, &delayTime)) {
            [self setFrameTimeLength:llround(delayTime * HSDefaultCelMovieScaling)];
            _calculateFrameTimeLength = NO;
        }
    }
    CFRelease(properties);
}

- (struct CGImageSource *)HSGIFMovieNodeUnit_imageSource
{
    if (_precachedGIFImageSource == NULL) {
        NSData *data = [_animatedGIFMedia mediaData];
        if (data != nil) {
            _precachedGIFImageSource = CGImageSourceCreateWithData((CFDataRef)data, [HSGIFMovieNodeUnit HSGIFMovieNodeUnit_defaultImageSourceOptions]);
            if (_calculateFrameTimeLength)
                [self HSGIFMovieNodeUnit_calculateFrameTimeLengthForFramesImageSource:_precachedGIFImageSource];
        }
    }
    return _precachedGIFImageSource;
}

// A new GIF drops the frame UIDs. With a precached source they are generated
// now; otherwise framesMedia generates them, and the frame time is read when
// the source is first created.
- (void)HSGIFMovieNodeUnit_setFramesMedia:(id)aMedia precachedSource:(struct CGImageSource *)aSource
{
    if ([aMedia count] == 0)
        return;
    id UID = [aMedia objectAtIndex:0];
    if ([UID isEqual:[_animatedGIFMedia mediaUID]])
        return;
    [_animatedGIFMedia release];
    _animatedGIFMedia = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID] retain];
    if (_precachedGIFImageSource != NULL) {
        CFRelease(_precachedGIFImageSource);
        _precachedGIFImageSource = NULL;
    }
    [_framesMediaUIDs release];
    _framesMediaUIDs = nil;
    if (aSource == NULL) {
        _playTimeRange = HSMakeTimeRange(0, 0);
        _calculateFrameTimeLength = YES;
        return;
    }
    _precachedGIFImageSource = (struct CGImageSource *)CFRetain(aSource);
    size_t count = CGImageSourceGetCount(_precachedGIFImageSource);
    NSMutableArray *UIDs = [[NSMutableArray alloc] initWithCapacity:count];
    for (; count != 0; count--)
        [UIDs addObject:[HSUID UID]];
    _framesMediaUIDs = UIDs;
    [self HSGIFMovieNodeUnit_calculateFrameTimeLengthForFramesImageSource:_precachedGIFImageSource];
    _playTimeRange = HSMakeTimeRange(0, [self duration]);
}

- (id)frameImageForMediaUID:(id)aUID
{
    id image = [HSCelMovieObjectFramesCache cachedFrameForMediaUID:aUID groupIdentifier:nil];
    if (image != nil)
        return image;
    NSArray *frames = [self framesMedia];
    if (frames == nil)
        return nil;
    struct CGImageSource *source = [self HSGIFMovieNodeUnit_imageSource];
    NSUInteger index = [frames indexOfObject:aUID];
    if (index == NSNotFound)
        return nil;
    CGImageRef frame = CGImageSourceCreateImageAtIndex(source, index, [HSGIFMovieNodeUnit HSGIFMovieNodeUnit_defaultImageSourceOptions]);
    if (frame == NULL)
        return nil;
    HSCGImageImageRep *rep = [[HSCGImageImageRep alloc] initWithCGImage:frame];
    NSSize size = [self defaultFrameSize];
    [rep setSize:size];
    NSImage *frameImage = [[NSImage alloc] initWithSize:size];
    [frameImage addRepresentation:rep];
    [frameImage setDataRetained:YES];
    [rep release];
    CFRelease(frame);
    return [frameImage autorelease];
}

- (void)setAnimatedGIFMediaUID:(id)aUID
{
    [_animatedGIFMedia release];
    _animatedGIFMedia = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
}

- (id)animatedGIFMediaUID
{
    return [_animatedGIFMedia mediaUID];
}

- (void)setCroppingPath:(id)aPath
{
    if (_croppingPath == aPath)
        return;
    [_croppingPath release];
    _croppingPath = [aPath retain];
}

- (id)croppingPath
{
    return _croppingPath;
}

- (void)setFramesMedia:(id)aMedia precachedSource:(struct CGImageSource *)aSource
{
    [self HSGIFMovieNodeUnit_setFramesMedia:aMedia precachedSource:aSource];
}

- (void)setFramesMedia:(id)aMedia precachedFrames:(id)aFrames
{
    [self HSGIFMovieNodeUnit_setFramesMedia:aMedia precachedSource:NULL];
}

- (void)setFramesMedia:(id)aMedia
{
    [self HSGIFMovieNodeUnit_setFramesMedia:aMedia precachedSource:NULL];
}

- (void)setGeneratedFramesMedia:(id)aMedia
{
    if (_framesMediaUIDs == aMedia)
        return;
    [_framesMediaUIDs release];
    _framesMediaUIDs = [aMedia retain];
    _playTimeRange = HSMakeTimeRange(0, [self duration]);
}

// Generates a UID per GIF frame the first time.
- (id)framesMedia
{
    if (_framesMediaUIDs == nil) {
        struct CGImageSource *source = [self HSGIFMovieNodeUnit_imageSource];
        if (source != NULL) {
            size_t count = CGImageSourceGetCount(source);
            NSMutableArray *UIDs = [[NSMutableArray alloc] initWithCapacity:count];
            for (; count != 0; count--)
                [UIDs addObject:[HSUID UID]];
            _framesMediaUIDs = UIDs;
            _playTimeRange = HSMakeTimeRange(0, [self duration]);
        }
    }
    return _framesMediaUIDs;
}

- (id)generatedFramesMedia
{
    return _framesMediaUIDs;
}

- (id)objectMediaUIDs
{
    if (_animatedGIFMedia == nil)
        return [NSSet set];
    return [NSSet setWithObject:[_animatedGIFMedia mediaUID]];
}

// Quirk kept: equal units must also share the same precached image source.
- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    BOOL equal = [[self objectMediaUIDs] isEqualToSet:[aEqual objectMediaUIDs]];
    if (_croppingPath != nil || [aEqual croppingPath] != nil)
        equal = equal && [_croppingPath isEqual:[aEqual croppingPath]];
    return equal && _precachedGIFImageSource == ((HSGIFMovieNodeUnit *)aEqual)->_precachedGIFImageSource;
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSGIFMovieNodeUnit *copy = [super copyWithZone:aZone];
    copy->_croppingPath = [_croppingPath copy];
    copy->_calculateFrameTimeLength = _calculateFrameTimeLength;
    copy->_precachedGIFImageSource = _precachedGIFImageSource;
    if (_precachedGIFImageSource != NULL)   // the original retained NULL too
        CFRetain(_precachedGIFImageSource);
    return copy;
}

- (void)dealloc
{
    [_animatedGIFMedia release];
    [_croppingPath release];
    if (_precachedGIFImageSource != NULL)
        CFRelease(_precachedGIFImageSource);
    [super dealloc];
}

@end
