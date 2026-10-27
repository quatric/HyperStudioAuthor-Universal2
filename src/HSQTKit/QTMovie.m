#import "HSQTKit.h"

#define QTSTRING(name) NSString * const name = @#name

NSString * const QTMoviePasteboardType = @"com.apple.quicktime-movie";
QTSTRING(QTMovieEditabilityDidChangeNotification);
QTSTRING(QTMovieEditedNotification);
QTSTRING(QTMovieLoadStateDidChangeNotification);
QTSTRING(QTMovieRateDidChangeNotification);
QTSTRING(QTMovieSelectionDidChangeNotification);
QTSTRING(QTMovieSizeDidChangeNotification);
QTSTRING(QTMovieStatusStringPostedNotification);
QTSTRING(QTMovieTimeDidChangeNotification);
QTSTRING(QTMovieVolumeDidChangeNotification);
QTSTRING(QTMovieDidEndNotification);
QTSTRING(QTMovieRateDidChangeNotificationParameter);

QTSTRING(QTMovieDataReferenceAttribute);
QTSTRING(QTMoviePasteboardAttribute);
QTSTRING(QTMovieDataAttribute);
QTSTRING(QTMovieFileOffsetAttribute);
QTSTRING(QTMovieResolveDataRefsAttribute);
QTSTRING(QTMovieAskUnresolvedDataRefsAttribute);
QTSTRING(QTMovieOpenAsyncOKAttribute);
QTSTRING(QTMovieOpenAsyncRequiredAttribute);
QTSTRING(QTMovieOpenForPlaybackAttribute);
QTSTRING(QTMovieDontInteractWithUserAttribute);
QTSTRING(QTMovieIsActiveAttribute);
QTSTRING(QTMovieActiveSegmentAttribute);
QTSTRING(QTMovieAutoAlternatesAttribute);
QTSTRING(QTMovieCopyrightAttribute);
QTSTRING(QTMovieCreationTimeAttribute);
QTSTRING(QTMovieCurrentSizeAttribute);
QTSTRING(QTMovieCurrentTimeAttribute);
QTSTRING(QTMovieDataSizeAttribute);
QTSTRING(QTMovieDelegateAttribute);
QTSTRING(QTMovieDisplayNameAttribute);
QTSTRING(QTMovieDurationAttribute);
QTSTRING(QTMovieEditableAttribute);
QTSTRING(QTMovieFileNameAttribute);
QTSTRING(QTMovieHasApertureModeDimensionsAttribute);
QTSTRING(QTMovieHasAudioAttribute);
QTSTRING(QTMovieHasDurationAttribute);
QTSTRING(QTMovieHasVideoAttribute);
QTSTRING(QTMovieIsInteractiveAttribute);
QTSTRING(QTMovieIsLinearAttribute);
QTSTRING(QTMovieIsSteppableAttribute);
QTSTRING(QTMovieLoadStateAttribute);
QTSTRING(QTMovieLoopsAttribute);
QTSTRING(QTMovieLoopsBackAndForthAttribute);
QTSTRING(QTMovieModificationTimeAttribute);
QTSTRING(QTMovieMutedAttribute);
QTSTRING(QTMovieNaturalSizeAttribute);
QTSTRING(QTMoviePlaysAllFramesAttribute);
QTSTRING(QTMoviePlaysSelectionOnlyAttribute);
QTSTRING(QTMoviePosterTimeAttribute);
QTSTRING(QTMoviePreferredMutedAttribute);
QTSTRING(QTMoviePreferredRateAttribute);
QTSTRING(QTMoviePreferredVolumeAttribute);
QTSTRING(QTMoviePreviewModeAttribute);
QTSTRING(QTMoviePreviewRangeAttribute);
QTSTRING(QTMovieRateAttribute);
QTSTRING(QTMovieSelectionAttribute);
QTSTRING(QTMovieTimeScaleAttribute);
QTSTRING(QTMovieURLAttribute);
QTSTRING(QTMovieVolumeAttribute);
QTSTRING(QTMovieRateChangesPreservePitchAttribute);
QTSTRING(QTMovieExport);
QTSTRING(QTMovieExportType);
QTSTRING(QTMovieExportManufacturer);
QTSTRING(QTMovieExportSettings);
QTSTRING(QTMovieFlatten);
QTSTRING(QTAddImageCodecType);
QTSTRING(QTAddImageCodecQuality);
QTSTRING(QTMovieFrameImageSize);
QTSTRING(QTMovieFrameImageType);
QTSTRING(QTMovieFrameImageTypeNSImage);
QTSTRING(QTMovieFrameImageTypeCGImageRef);
QTSTRING(QTMovieFrameImageTypeCIImage);
QTSTRING(QTMovieFrameImageTypeCVPixelBufferRef);
QTSTRING(QTMovieFrameImageTypeCVOpenGLTextureRef);
QTSTRING(QTMovieFrameImageOpenGLContext);
QTSTRING(QTMovieFrameImagePixelFormat);
QTSTRING(QTMovieFrameImageRepresentationsType);
QTSTRING(QTMovieFrameImageDeinterlaceFields);
QTSTRING(QTMovieFrameImageHighQuality);
QTSTRING(QTMovieFrameImageSingleField);
QTSTRING(QTMovieFrameImageSessionMode);

static NSError *movieError(NSInteger code, NSString *description)
{
    return [NSError errorWithDomain:QTKitErrorDomain code:code
                           userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

static void setError(NSError **errorPtr, NSError *error)
{
    if (errorPtr)
        *errorPtr = error;
}

// A new file in the temporary folder, with the given extension.
static NSURL *temporaryURL(NSString *extension)
{
    NSString *name = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:extension];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

// QuickTime's export component types (QTMovieExportType) as files.
static AVFileType fileTypeForExportType(OSType type, NSString **presetPtr)
{
    switch (type) {
    case 'mpg4': *presetPtr = AVAssetExportPresetHighestQuality; return AVFileTypeMPEG4;
    case 'M4V ': *presetPtr = AVAssetExportPresetHighestQuality; return AVFileTypeAppleM4V;
    case 'M4A ': case 'mp4a': *presetPtr = AVAssetExportPresetAppleM4A; return AVFileTypeAppleM4A;
    case 'AIFF': case 'AIFC': *presetPtr = nil; return AVFileTypeAIFF;
    case 'WAVE': case '.WAV': *presetPtr = nil; return AVFileTypeWAVE;
    case 'caff': *presetPtr = nil; return AVFileTypeCoreAudioFormat;
    default: *presetPtr = AVAssetExportPresetHighestQuality; return AVFileTypeQuickTimeMovie;
    }
}

// Runs an export session to the end.
static BOOL runExport(AVAssetExportSession *session, NSError **errorPtr)
{
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_semaphore_signal(done);
    }];
    dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
    dispatch_release(done);
    if ([session status] != AVAssetExportSessionStatusCompleted) {
        setError(errorPtr, [session error] ? [session error] : movieError(QTErrorUnknown, @"The movie could not be exported."));
        return NO;
    }
    return YES;
}

// Writes the sound of an asset as linear PCM (AIFF, WAVE or CAF).
static BOOL writePCM(AVAsset *asset, NSURL *url, AVFileType fileType, NSError **errorPtr)
{
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (![tracks count]) {
        setError(errorPtr, movieError(QTErrorUnknown, @"The movie has no sound to export."));
        return NO;
    }
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:errorPtr];
    if (!reader)
        return NO;
    NSDictionary *readSettings = @{ AVFormatIDKey: @(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey: @16,
                                    AVLinearPCMIsFloatKey: @NO, AVLinearPCMIsNonInterleaved: @NO,
                                    AVLinearPCMIsBigEndianKey: @([fileType isEqualToString:AVFileTypeAIFF]) };
    AVAssetReaderAudioMixOutput *output = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:tracks audioSettings:readSettings];
    [reader addOutput:output];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:url fileType:fileType error:errorPtr];
    if (!writer)
        return NO;
    AudioStreamBasicDescription asbd = { 0 };
    CMFormatDescriptionRef format = (CMFormatDescriptionRef)[[[tracks objectAtIndex:0] formatDescriptions] firstObject];
    if (format && CMAudioFormatDescriptionGetStreamBasicDescription(format))
        asbd = *CMAudioFormatDescriptionGetStreamBasicDescription(format);
    double rate = asbd.mSampleRate > 0 ? asbd.mSampleRate : 44100;
    int channels = asbd.mChannelsPerFrame > 0 && asbd.mChannelsPerFrame <= 2 ? asbd.mChannelsPerFrame : 2;
    NSMutableDictionary *writeSettings = [[readSettings mutableCopy] autorelease];
    [writeSettings setObject:@(rate) forKey:AVSampleRateKey];
    [writeSettings setObject:@(channels) forKey:AVNumberOfChannelsKey];
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:writeSettings];
    [writer addInput:input];
    if (![reader startReading] || ![writer startWriting]) {
        setError(errorPtr, [reader error] ? [reader error] : [writer error]);
        return NO;
    }
    [writer startSessionAtSourceTime:kCMTimeZero];
    BOOL ok = YES;
    while (ok) {
        CMSampleBufferRef buffer = [output copyNextSampleBuffer];
        if (!buffer)
            break;
        while (![input isReadyForMoreMediaData])
            usleep(1000);
        ok = [input appendSampleBuffer:buffer];
        CFRelease(buffer);
    }
    [input markAsFinished];
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    [writer finishWritingWithCompletionHandler:^{
        dispatch_semaphore_signal(done);
    }];
    dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
    dispatch_release(done);
    if (!ok || [writer status] != AVAssetWriterStatusCompleted || [reader status] == AVAssetReaderStatusFailed) {
        setError(errorPtr, [writer error] ? [writer error] : [reader error]);
        return NO;
    }
    return YES;
}

// An image as a 32-bit ARGB pixel buffer of the given size.
static CVPixelBufferRef newPixelBuffer(NSImage *image, CGSize size)
{
    CVPixelBufferRef buffer = NULL;
    NSDictionary *attributes = @{ (id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                                  (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES,
                                  (id)kCVPixelBufferIOSurfacePropertiesKey: @{} };
    if (CVPixelBufferCreate(NULL, (size_t)size.width, (size_t)size.height, kCVPixelFormatType_32ARGB,
                            (CFDictionaryRef)attributes, &buffer) != kCVReturnSuccess)
        return NULL;
    CVPixelBufferLockBaseAddress(buffer, 0);
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(buffer), (size_t)size.width, (size_t)size.height, 8,
                                                 CVPixelBufferGetBytesPerRow(buffer), space, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (context) {
        CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
        NSGraphicsContext *graphics = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphics];
        [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect
                operation:NSCompositingOperationCopy fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
        CGContextRelease(context);
    }
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return buffer;
}

// QuickTime image codecs that VideoToolbox can't write become the nearest
// one it can: Photo JPEG for the lossy ones, ProRes 4444 (with alpha) for
// the lossless ones.
static CMVideoCodecType encoderCodec(OSType codec)
{
    switch (codec) {
    case 'avc1': return kCMVideoCodecType_H264;
    case 'hvc1': return kCMVideoCodecType_HEVC;
    case 'jpeg': case 'mjpa': case 'mjpb': case 'cvid': case 'SVQ1': case 'SVQ3': case 'mp4v':
    case 'h263': case 'rpza': case 'smc ': case 'dvc ': case 'dvcp':
        return kCMVideoCodecType_JPEG;
    case 'apcn': return kCMVideoCodecType_AppleProRes422;
    default: return kCMVideoCodecType_AppleProRes4444;
    }
}

// Media data storage in a file, which must exist before samples go in.
static AVMediaDataStorage *newStorage(NSURL *url)
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        [[NSData data] writeToURL:url atomically:NO];
    return [[AVMediaDataStorage alloc] initWithURL:url options:nil];
}

static void imageEncoded(void *refcon, void *frameRefcon, OSStatus status, VTEncodeInfoFlags flags, CMSampleBufferRef buffer)
{
    if (status == noErr && buffer)
        *(CMSampleBufferRef *)frameRefcon = (CMSampleBufferRef)CFRetain(buffer);
}

@interface QTTrack (HSQTKitPrivate)
- (void)setAssetTrack:(AVAssetTrack *)track;
@end

@interface QTMovie (HSQTKitPrivate)
- (BOOL)loadURL:(NSURL *)url error:(NSError **)errorPtr;
- (void)movieChanged;
- (AVPlayer *)player;
- (long)timeScale;
- (QTTime)scaled:(CMTime)time;
@end

@implementation QTMovie

// ---- class

+ (NSArray *)movieUnfilteredFileTypes
{
    NSMutableArray *types = [NSMutableArray array];
    for (NSString *uti in [AVURLAsset audiovisualTypes]) {
        UTType *type = [UTType typeWithIdentifier:uti];
        for (NSString *extension in [[type tags] objectForKey:UTTagClassFilenameExtension])
            if (![types containsObject:extension])
                [types addObject:extension];
        for (NSString *ostype in [[type tags] objectForKey:@"com.apple.ostype"])
            if (![types containsObject:[NSString stringWithFormat:@"'%@'", ostype]])
                [types addObject:[NSString stringWithFormat:@"'%@'", ostype]];
    }
    return types;
}

+ (NSArray *)movieFileTypes:(QTMovieFileTypeOptions)types
{
    NSMutableArray *result = [[[self movieUnfilteredFileTypes] mutableCopy] autorelease];
    if (types & QTIncludeStillImageTypes)
        for (NSString *type in [NSImage imageTypes])
            for (NSString *extension in [[[UTType typeWithIdentifier:type] tags] objectForKey:UTTagClassFilenameExtension])
                if (![result containsObject:extension])
                    [result addObject:extension];
    return result;
}

+ (NSArray *)movieTypesWithOptions:(QTMovieFileTypeOptions)types
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:[AVURLAsset audiovisualTypes]];
    if (types & QTIncludeStillImageTypes)
        [result addObjectsFromArray:[NSImage imageTypes]];
    return result;
}

+ (NSArray *)movieUnfilteredPasteboardTypes
{
    return [NSArray arrayWithObjects:QTMoviePasteboardType, NSPasteboardTypeFileURL, nil];
}

+ (BOOL)canInitWithURL:(NSURL *)url
{
    if (!url)
        return NO;
    if (![url isFileURL])
        return YES;
    NSString *uti = nil;
    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    UTType *type = uti ? [UTType typeWithIdentifier:uti] : [UTType typeWithFilenameExtension:[url pathExtension]];
    if (!type)
        return NO;
    for (NSString *movieType in [AVURLAsset audiovisualTypes]) {
        UTType *movie = [UTType typeWithIdentifier:movieType];
        if (movie && [type conformsToType:movie])
            return YES;
    }
    return NO;
}

+ (BOOL)canInitWithFile:(NSString *)fileName
{
    return fileName && [self canInitWithURL:[NSURL fileURLWithPath:fileName]];
}

+ (BOOL)canInitWithDataReference:(QTDataReference *)dataReference
{
    if ([dataReference referenceData])
        return YES;
    return [self canInitWithURL:[dataReference referenceURL]];
}

+ (BOOL)canInitWithPasteboard:(NSPasteboard *)pasteboard
{
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:QTMoviePasteboardType]])
        return YES;
    NSArray *urls = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                              options:@{ NSPasteboardURLReadingFileURLsOnlyKey: @YES }];
    return [urls count] && [self canInitWithURL:[urls objectAtIndex:0]];
}

+ (id)movie { return [[[self alloc] init] autorelease]; }
+ (id)movieWithFile:(NSString *)fileName error:(NSError **)errorPtr { return [[[self alloc] initWithFile:fileName error:errorPtr] autorelease]; }
+ (id)movieWithURL:(NSURL *)url error:(NSError **)errorPtr { return [[[self alloc] initWithURL:url error:errorPtr] autorelease]; }
+ (id)movieWithDataReference:(QTDataReference *)dataReference error:(NSError **)errorPtr { return [[[self alloc] initWithDataReference:dataReference error:errorPtr] autorelease]; }
+ (id)movieWithPasteboard:(NSPasteboard *)pasteboard error:(NSError **)errorPtr { return [[[self alloc] initWithPasteboard:pasteboard error:errorPtr] autorelease]; }
+ (id)movieWithData:(NSData *)data error:(NSError **)errorPtr { return [[[self alloc] initWithData:data error:errorPtr] autorelease]; }
+ (id)movieWithAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr { return [[[self alloc] initWithAttributes:attributes error:errorPtr] autorelease]; }
+ (id)movieWithQuickTimeMovie:(void *)movie disposeWhenDone:(BOOL)dispose error:(NSError **)errorPtr { return [[[self alloc] initWithQuickTimeMovie:movie disposeWhenDone:dispose error:errorPtr] autorelease]; }

+ (id)movieNamed:(NSString *)name error:(NSError **)errorPtr
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension]
                                                     ofType:[[name pathExtension] length] ? [name pathExtension] : @"mov"];
    if (!path) {
        setError(errorPtr, movieError(-43, @"The movie could not be found."));
        return nil;
    }
    return [self movieWithFile:path error:errorPtr];
}

// AVFoundation is thread safe: nothing to do.
+ (void)enterQTKitOnThread {}
+ (void)enterQTKitOnThreadDisablingThreadSafetyProtection {}
+ (void)exitQTKitOnThread {}
- (BOOL)attachToCurrentThread { return YES; }
- (BOOL)detachFromCurrentThread { return YES; }
- (void)setIdling:(BOOL)state {}
- (BOOL)isIdling { return YES; }

// ---- initialization

// An empty, editable movie whose new media goes into a temporary file.
- (id)init
{
    if (!(self = [super init]))
        return nil;
    _attributes = [[NSMutableDictionary alloc] init];
    _tempURLs = [[NSMutableArray alloc] init];
    _preferredRate = 1.0;
    _volume = 1.0;
    _selection = QTZeroTimeRange;
    _asset = [[AVMutableMovie alloc] initWithSettingsFromMovie:nil options:nil error:NULL];
    [_asset setTimescale:600];
    NSURL *storage = temporaryURL(@"mov");
    [_tempURLs addObject:storage];
    [_asset setDefaultMediaDataStorage:[newStorage(storage) autorelease]];
    _editable = YES;
    return self;
}

- (BOOL)loadURL:(NSURL *)url error:(NSError **)errorPtr
{
    AVMutableMovie *movie = [[AVMutableMovie alloc] initWithURL:url options:@{ AVURLAssetPreferPreciseDurationAndTimingKey: @YES } error:errorPtr];
    if (!movie)
        return NO;
    // loads the tracks: a file AVFoundation can't read has none
    if (![[movie tracks] count] && ![movie isReadable]) {
        [movie release];
        setError(errorPtr, movieError(-2048, @"The file is not a movie AVFoundation can open."));
        return NO;
    }
    if (![movie defaultMediaDataStorage]) {
        NSURL *storage = temporaryURL(@"mov");
        [_tempURLs addObject:storage];
        [movie setDefaultMediaDataStorage:[newStorage(storage) autorelease]];
    }
    [_asset release];
    _asset = movie;
    [_url release];
    _url = [url retain];
    return YES;
}

- (id)initWithURL:(NSURL *)url error:(NSError **)errorPtr
{
    if (!url) {
        setError(errorPtr, movieError(-50, @"No movie was given."));
        [self release];
        return nil;
    }
    return [self initWithAttributes:[NSDictionary dictionaryWithObject:url forKey:QTMovieURLAttribute] error:errorPtr];
}

- (id)initWithFile:(NSString *)fileName error:(NSError **)errorPtr
{
    if (!fileName) {
        setError(errorPtr, movieError(-50, @"No movie was given."));
        [self release];
        return nil;
    }
    return [self initWithAttributes:[NSDictionary dictionaryWithObject:fileName forKey:QTMovieFileNameAttribute] error:errorPtr];
}

- (id)initWithDataReference:(QTDataReference *)dataReference error:(NSError **)errorPtr
{
    if (!dataReference) {
        setError(errorPtr, movieError(-50, @"No movie was given."));
        [self release];
        return nil;
    }
    return [self initWithAttributes:[NSDictionary dictionaryWithObject:dataReference forKey:QTMovieDataReferenceAttribute] error:errorPtr];
}

- (id)initWithPasteboard:(NSPasteboard *)pasteboard error:(NSError **)errorPtr
{
    if (!pasteboard) {
        setError(errorPtr, movieError(-50, @"No movie was given."));
        [self release];
        return nil;
    }
    return [self initWithAttributes:[NSDictionary dictionaryWithObject:pasteboard forKey:QTMoviePasteboardAttribute] error:errorPtr];
}

- (id)initWithData:(NSData *)data error:(NSError **)errorPtr
{
    if (!data) {
        setError(errorPtr, movieError(-50, @"No movie was given."));
        [self release];
        return nil;
    }
    return [self initWithAttributes:[NSDictionary dictionaryWithObject:data forKey:QTMovieDataAttribute] error:errorPtr];
}

- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
    if (!(self = [self init]))
        return nil;
    NSURL *url = [attributes objectForKey:QTMovieURLAttribute];
    NSString *file = [attributes objectForKey:QTMovieFileNameAttribute];
    QTDataReference *reference = [attributes objectForKey:QTMovieDataReferenceAttribute];
    NSData *data = [attributes objectForKey:QTMovieDataAttribute];
    NSPasteboard *pasteboard = [attributes objectForKey:QTMoviePasteboardAttribute];
    if (file)
        url = [NSURL fileURLWithPath:file];
    if (reference) {
        url = [reference referenceURL];
        data = [reference referenceData];
    }
    if (pasteboard) {
        data = [pasteboard dataForType:QTMoviePasteboardType];
        if (!data) {
            NSArray *urls = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                                      options:@{ NSPasteboardURLReadingFileURLsOnlyKey: @YES }];
            url = [urls firstObject];
        }
    }
    BOOL fromData = NO;
    if (!url && data) {
        url = temporaryURL(@"mov");
        if (![data writeToURL:url atomically:NO]) {
            setError(errorPtr, movieError(-34, @"The movie data could not be stored."));
            [self release];
            return nil;
        }
        [_tempURLs addObject:url];
        fromData = YES;
    }
    if (url) {
        if (![self loadURL:url error:errorPtr]) {
            [self release];
            return nil;
        }
        if (fromData) {
            [_url release];
            _url = nil;
        }
        _editable = NO;
    }
    else if (pasteboard) {
        setError(errorPtr, movieError(-2048, @"The pasteboard holds no movie."));
        [self release];
        return nil;
    }
    for (NSString *key in attributes) {
        if ([key isEqualToString:QTMovieURLAttribute] || [key isEqualToString:QTMovieFileNameAttribute]
            || [key isEqualToString:QTMovieDataReferenceAttribute] || [key isEqualToString:QTMovieDataAttribute]
            || [key isEqualToString:QTMoviePasteboardAttribute])
            continue;
        [self setAttribute:[attributes objectForKey:key] forKey:key];
    }
    return self;
}

// QuickTime movies are gone: what was a Movie is a QTMovie now.
// -quickTimeMovie returns the QTMovie itself, so a QTMovie made from it is
// that same movie, sharing its state as two QTKit wrappers of one Movie did.
- (id)initWithQuickTimeMovie:(void *)movie disposeWhenDone:(BOOL)dispose error:(NSError **)errorPtr
{
    [self release];
    if (![(id)movie isKindOfClass:[QTMovie class]]) {
        setError(errorPtr, movieError(-2010, @"QuickTime movies are not supported."));
        return nil;
    }
    return [(QTMovie *)movie retain];
}

- (id)initWithMovie:(QTMovie *)movie timeRange:(QTTimeRange)range error:(NSError **)errorPtr
{
    if (!(self = [self init]))
        return nil;
    [_asset setTimescale:(CMTimeScale)[movie timeScale]];
    if (![_asset insertTimeRange:HSCMTimeRangeFromQTTimeRange(range) ofAsset:[movie AVAsset] atTime:kCMTimeZero
                  copySampleData:NO error:errorPtr]) {
        [self release];
        return nil;
    }
    return self;
}

- (id)initToWritableFile:(NSString *)filename error:(NSError **)errorPtr
{
    if (!(self = [self init]))
        return nil;
    [[NSFileManager defaultManager] removeItemAtPath:filename error:NULL];
    _url = [[NSURL fileURLWithPath:filename] retain];
    [_asset setDefaultMediaDataStorage:[newStorage(_url) autorelease]];
    return self;
}

- (id)initToWritableData:(NSMutableData *)data error:(NSError **)errorPtr
{
    return [self init];
}

- (id)movieWithTimeRange:(QTTimeRange)range error:(NSError **)errorPtr
{
    return [[[QTMovie alloc] initWithMovie:self timeRange:range error:errorPtr] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[QTMovie allocWithZone:zone] initWithMovie:self timeRange:QTMakeTimeRange(QTZeroTime, [self duration]) error:NULL];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSData *data = [coder decodeObjectForKey:@"movieData"];
    NSURL *url = [coder decodeObjectForKey:@"movieURL"];
    if (url)
        return [self initWithURL:url error:NULL];
    return data ? [self initWithData:data error:NULL] : [self init];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (_url && ![_asset isModified])
        [coder encodeObject:_url forKey:@"movieURL"];
    else
        [coder encodeObject:[self movieFormatRepresentation] forKey:@"movieData"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_observingRate)
        [_player removeObserver:self forKeyPath:@"rate"];
    [_player pause];
    [_player release];
    [_item release];
    [_imageGenerator release];
    if (_imageSession) {
        VTCompressionSessionInvalidate(_imageSession);
        CFRelease(_imageSession);
    }
    [_imageTrack release];
    [_asset release];
    [_url release];
    [_attributes release];
    for (NSURL *url in _tempURLs)
        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    [_tempURLs release];
    [super dealloc];
}

// ---- playback

// The player item is made again after the movie changes.
- (AVPlayer *)player
{
    if (_item)
        return _player;
    CMTime time = _player ? [_player currentTime] : kCMTimeZero;
    float rate = _player ? [_player rate] : 0;
    _item = [[AVPlayerItem alloc] initWithAsset:[[_asset copy] autorelease]];
    [_item setAudioTimePitchAlgorithm:AVAudioTimePitchAlgorithmSpectral];
    if (!_player) {
        _player = [[AVPlayer alloc] initWithPlayerItem:_item];
        [_player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
        [_player setVolume:_volume];
        [_player setMuted:_muted];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
        _observingRate = YES;
    }
    else
        [_player replaceCurrentItemWithPlayerItem:_item];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    if (CMTIME_COMPARE_INLINE(time, >, kCMTimeZero))
        [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if ([[_attributes objectForKey:QTMoviePlaysSelectionOnlyAttribute] boolValue] && QTTimeCompare(_selection.duration, QTZeroTime) == NSOrderedDescending)
        [_item setForwardPlaybackEndTime:HSCMTimeFromQTTime(QTTimeRangeEnd(_selection))];
    if (rate)
        [_player setRate:rate];
    return _player;
}

- (void)itemDidPlayToEnd:(NSNotification *)notification
{
    if (_loops || [[_attributes objectForKey:QTMovieLoopsBackAndForthAttribute] boolValue]) {
        BOOL selectionOnly = [[_attributes objectForKey:QTMoviePlaysSelectionOnlyAttribute] boolValue];
        [self setCurrentTime:selectionOnly ? _selection.time : QTZeroTime];
        [[self player] setRate:_preferredRate];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieDidEndNotification object:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != _player)
        return;
    NSNumber *rate = [NSNumber numberWithFloat:[_player rate]];
    void (^post)(void) = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieRateDidChangeNotification object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:rate forKey:QTMovieRateDidChangeNotificationParameter]];
    };
    if ([NSThread isMainThread])
        post();
    else
        dispatch_async(dispatch_get_main_queue(), post);
}

- (long)timeScale
{
    CMTimeScale scale = [_asset timescale];
    return scale > 0 ? scale : 600;
}

- (QTTime)scaled:(CMTime)time
{
    QTTime t = HSQTTimeFromCMTime(time);
    return QTTimeIsIndefinite(t) ? t : QTMakeTimeScaled(t, [self timeScale]);
}

- (QTTime)currentTime
{
    if (_seeks)
        return [self scaled:_seekTarget];
    if (!_player)
        return QTMakeTime(0, [self timeScale]);
    return [self scaled:[_player currentTime]];
}

- (void)setCurrentTime:(QTTime)time
{
    CMTime target = HSCMTimeFromQTTime(time);
    if (CMTIME_IS_INDEFINITE(target))
        return;
    _seekTarget = target;
    _seeks++;
    [self retain];
    [[self player] seekToTime:target toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _seeks--;
            [self release];
        });
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieTimeDidChangeNotification object:self];
}

- (QTTime)duration
{
    return [self scaled:[_asset duration]];
}

- (void)gotoBeginning { [self setCurrentTime:QTMakeTime(0, [self timeScale])]; }
- (void)gotoEnd { [self setCurrentTime:[self duration]]; }
- (void)gotoPosterTime { [self setCurrentTime:[[self attributeForKey:QTMoviePosterTimeAttribute] QTTimeValue]]; }

- (void)gotoNextSelectionPoint
{
    QTTime now = [self currentTime];
    if (QTTimeCompare(now, _selection.time) == NSOrderedAscending)
        [self setCurrentTime:_selection.time];
    else if (QTTimeCompare(now, QTTimeRangeEnd(_selection)) == NSOrderedAscending)
        [self setCurrentTime:QTTimeRangeEnd(_selection)];
}

- (void)gotoPreviousSelectionPoint
{
    QTTime now = [self currentTime];
    if (QTTimeCompare(now, QTTimeRangeEnd(_selection)) == NSOrderedDescending)
        [self setCurrentTime:QTTimeRangeEnd(_selection)];
    else if (QTTimeCompare(now, _selection.time) == NSOrderedDescending)
        [self setCurrentTime:_selection.time];
}

- (void)stepForward
{
    [[self player] pause];
    [[[self player] currentItem] stepByCount:1];
}

- (void)stepBackward
{
    [[self player] pause];
    [[[self player] currentItem] stepByCount:-1];
}

- (void)play
{
    AVPlayer *player = [self player];
    if (QTTimeCompare([self currentTime], [self duration]) != NSOrderedAscending)
        [self gotoBeginning];
    [player setRate:_preferredRate];
}

- (void)stop { [[self player] pause]; }
- (float)rate { return _player ? [_player rate] : 0; }

- (void)setRate:(float)rate
{
    [[self player] setRate:rate];
}

- (float)volume { return _volume; }

- (void)setVolume:(float)volume
{
    _volume = volume;
    [_player setVolume:volume];
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieVolumeDidChangeNotification object:self];
}

- (BOOL)muted { return _muted; }

- (void)setMuted:(BOOL)mute
{
    _muted = mute;
    [_player setMuted:mute];
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieVolumeDidChangeNotification object:self];
}

// ---- selection

- (void)setSelection:(QTTimeRange)selection
{
    _selection = selection;
    if ([[_attributes objectForKey:QTMoviePlaysSelectionOnlyAttribute] boolValue] && _item)
        [_item setForwardPlaybackEndTime:QTTimeCompare(selection.duration, QTZeroTime) == NSOrderedDescending
                                             ? HSCMTimeFromQTTime(QTTimeRangeEnd(selection)) : kCMTimeInvalid];
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieSelectionDidChangeNotification object:self];
}

- (QTTime)selectionStart { return _selection.time; }
- (QTTime)selectionEnd { return QTTimeRangeEnd(_selection); }
- (QTTime)selectionDuration { return _selection.duration; }

// ---- attributes

- (NSSize)naturalSize
{
    NSRect bounds = NSZeroRect;
    for (AVAssetTrack *track in [_asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual]) {
        if (![track isEnabled])
            continue;
        CGRect r = CGRectApplyAffineTransform(CGRectMake(0, 0, [track naturalSize].width, [track naturalSize].height),
                                              [track preferredTransform]);
        bounds = NSUnionRect(bounds, NSMakeRect(0, 0, fabs(r.size.width), fabs(r.size.height)));
    }
    return bounds.size;
}

- (NSDictionary *)movieAttributes
{
    NSArray *keys = [NSArray arrayWithObjects:QTMovieCopyrightAttribute, QTMovieCreationTimeAttribute, QTMovieCurrentSizeAttribute,
                     QTMovieCurrentTimeAttribute, QTMovieDataSizeAttribute, QTMovieDisplayNameAttribute, QTMovieDurationAttribute,
                     QTMovieEditableAttribute, QTMovieFileNameAttribute, QTMovieHasAudioAttribute, QTMovieHasDurationAttribute,
                     QTMovieHasVideoAttribute, QTMovieIsInteractiveAttribute, QTMovieIsLinearAttribute, QTMovieIsSteppableAttribute,
                     QTMovieLoadStateAttribute, QTMovieLoopsAttribute, QTMovieModificationTimeAttribute, QTMovieMutedAttribute,
                     QTMovieNaturalSizeAttribute, QTMoviePlaysSelectionOnlyAttribute, QTMoviePosterTimeAttribute,
                     QTMoviePreferredRateAttribute, QTMoviePreferredVolumeAttribute, QTMovieRateAttribute, QTMovieSelectionAttribute,
                     QTMovieTimeScaleAttribute, QTMovieURLAttribute, QTMovieVolumeAttribute, nil];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:_attributes];
    for (NSString *key in keys) {
        id value = [self attributeForKey:key];
        if (value)
            [result setObject:value forKey:key];
    }
    return result;
}

- (void)setMovieAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes)
        [self setAttribute:[attributes objectForKey:key] forKey:key];
}

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTMovieNaturalSizeAttribute] || [key isEqualToString:QTMovieCurrentSizeAttribute]) {
        id size = [_attributes objectForKey:QTMovieCurrentSizeAttribute];
        if (size && [key isEqualToString:QTMovieCurrentSizeAttribute])
            return size;
        return [NSValue valueWithSize:[self naturalSize]];
    }
    if ([key isEqualToString:QTMovieDurationAttribute])
        return [NSValue valueWithQTTime:[self duration]];
    if ([key isEqualToString:QTMovieCurrentTimeAttribute])
        return [NSValue valueWithQTTime:[self currentTime]];
    if ([key isEqualToString:QTMovieTimeScaleAttribute])
        return [NSNumber numberWithLong:[self timeScale]];
    if ([key isEqualToString:QTMovieEditableAttribute])
        return [NSNumber numberWithBool:_editable];
    if ([key isEqualToString:QTMovieURLAttribute])
        return _url;
    if ([key isEqualToString:QTMovieFileNameAttribute])
        return [_url isFileURL] ? [_url path] : nil;
    if ([key isEqualToString:QTMovieDisplayNameAttribute]) {
        id name = [_attributes objectForKey:key];
        if (name)
            return name;
        for (AVMetadataItem *item in [AVMetadataItem metadataItemsFromArray:[_asset commonMetadata] withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon])
            if ([item stringValue])
                return [item stringValue];
        return _url ? [[_url lastPathComponent] stringByDeletingPathExtension] : @"Untitled";
    }
    if ([key isEqualToString:QTMovieCopyrightAttribute]) {
        for (AVMetadataItem *item in [AVMetadataItem metadataItemsFromArray:[_asset commonMetadata] withKey:AVMetadataCommonKeyCopyrights keySpace:AVMetadataKeySpaceCommon])
            if ([item stringValue])
                return [item stringValue];
        return nil;
    }
    if ([key isEqualToString:QTMovieHasVideoAttribute])
        return [NSNumber numberWithBool:[[_asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count] != 0];
    if ([key isEqualToString:QTMovieHasAudioAttribute])
        return [NSNumber numberWithBool:[[_asset tracksWithMediaCharacteristic:AVMediaCharacteristicAudible] count] != 0];
    if ([key isEqualToString:QTMovieIsSteppableAttribute])
        return [NSNumber numberWithBool:[[_asset tracksWithMediaType:AVMediaTypeVideo] count] != 0];
    if ([key isEqualToString:QTMovieHasDurationAttribute] || [key isEqualToString:QTMovieIsLinearAttribute])
        return [NSNumber numberWithBool:YES];
    if ([key isEqualToString:QTMovieIsInteractiveAttribute] || [key isEqualToString:QTMovieHasApertureModeDimensionsAttribute])
        return [NSNumber numberWithBool:NO];
    if ([key isEqualToString:QTMovieLoadStateAttribute])
        return [NSNumber numberWithLong:QTMovieLoadStateComplete];
    if ([key isEqualToString:QTMovieLoopsAttribute])
        return [NSNumber numberWithBool:_loops];
    if ([key isEqualToString:QTMovieRateAttribute])
        return [NSNumber numberWithFloat:[self rate]];
    if ([key isEqualToString:QTMoviePreferredRateAttribute])
        return [NSNumber numberWithFloat:_preferredRate];
    if ([key isEqualToString:QTMovieVolumeAttribute])
        return [NSNumber numberWithFloat:_volume];
    if ([key isEqualToString:QTMoviePreferredVolumeAttribute])
        return [NSNumber numberWithFloat:[_asset preferredVolume]];
    if ([key isEqualToString:QTMovieMutedAttribute])
        return [NSNumber numberWithBool:_muted];
    if ([key isEqualToString:QTMovieSelectionAttribute])
        return [NSValue valueWithQTTimeRange:_selection];
    if ([key isEqualToString:QTMoviePosterTimeAttribute]) {
        id time = [_attributes objectForKey:key];
        return time ? time : [NSValue valueWithQTTime:QTMakeTime(0, [self timeScale])];
    }
    if ([key isEqualToString:QTMovieDelegateAttribute])
        return _delegate;
    if ([key isEqualToString:QTMovieRateChangesPreservePitchAttribute])
        return [NSNumber numberWithBool:![[_item audioTimePitchAlgorithm] isEqualToString:AVAudioTimePitchAlgorithmVarispeed]];
    if ([key isEqualToString:QTMovieDataSizeAttribute] || [key isEqualToString:QTMovieCreationTimeAttribute]
        || [key isEqualToString:QTMovieModificationTimeAttribute]) {
        if (![_url isFileURL])
            return nil;
        NSDictionary *file = [[NSFileManager defaultManager] attributesOfItemAtPath:[_url path] error:NULL];
        if ([key isEqualToString:QTMovieDataSizeAttribute])
            return [NSNumber numberWithLongLong:[file fileSize]];
        return [key isEqualToString:QTMovieCreationTimeAttribute] ? [file fileCreationDate] : [file fileModificationDate];
    }
    return [_attributes objectForKey:key];
}

- (void)setAttribute:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:QTMovieEditableAttribute]) {
        _editable = [value boolValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieEditabilityDidChangeNotification object:self];
    }
    else if ([key isEqualToString:QTMovieLoopsAttribute])
        _loops = [value boolValue];
    else if ([key isEqualToString:QTMovieRateAttribute])
        [self setRate:[value floatValue]];
    else if ([key isEqualToString:QTMoviePreferredRateAttribute]) {
        _preferredRate = [value floatValue];
        [_asset setPreferredRate:_preferredRate];
    }
    else if ([key isEqualToString:QTMovieVolumeAttribute])
        [self setVolume:[value floatValue]];
    else if ([key isEqualToString:QTMoviePreferredVolumeAttribute])
        [_asset setPreferredVolume:[value floatValue]];
    else if ([key isEqualToString:QTMovieMutedAttribute])
        [self setMuted:[value boolValue]];
    else if ([key isEqualToString:QTMovieSelectionAttribute])
        [self setSelection:[value QTTimeRangeValue]];
    else if ([key isEqualToString:QTMovieCurrentTimeAttribute])
        [self setCurrentTime:[value QTTimeValue]];
    else if ([key isEqualToString:QTMovieTimeScaleAttribute])
        [_asset setTimescale:(CMTimeScale)[value longValue]];
    else if ([key isEqualToString:QTMovieDelegateAttribute])
        [self setDelegate:value];
    else if ([key isEqualToString:QTMovieRateChangesPreservePitchAttribute])
        [_item setAudioTimePitchAlgorithm:[value boolValue] ? AVAudioTimePitchAlgorithmSpectral : AVAudioTimePitchAlgorithmVarispeed];
    else if ([key isEqualToString:QTMovieCurrentSizeAttribute]) {
        [_attributes setObject:value forKey:key];
        [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieSizeDidChangeNotification object:self];
    }
    else if ([key isEqualToString:QTMovieURLAttribute] || [key isEqualToString:QTMovieFileNameAttribute]) {
        [_url release];
        _url = [([value isKindOfClass:[NSURL class]] ? value : [NSURL fileURLWithPath:value]) retain];
    }
    else if (value)
        [_attributes setObject:value forKey:key];
    else
        [_attributes removeObjectForKey:key];
    if ([key isEqualToString:QTMoviePlaysSelectionOnlyAttribute] && _item)
        [_item setForwardPlaybackEndTime:[value boolValue] && QTTimeCompare(_selection.duration, QTZeroTime) == NSOrderedDescending
                                             ? HSCMTimeFromQTTime(QTTimeRangeEnd(_selection)) : kCMTimeInvalid];
}

- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }

// ---- tracks

- (NSArray *)tracks
{
    NSMutableArray *tracks = [NSMutableArray array];
    for (AVAssetTrack *track in [_asset tracks])
        [tracks addObject:[[[QTTrack alloc] initWithMovie:self assetTrack:track] autorelease]];
    return tracks;
}

- (NSArray *)tracksOfMediaType:(NSString *)type
{
    NSMutableArray *tracks = [NSMutableArray array];
    for (AVAssetTrack *track in [_asset tracksWithMediaType:HSAVMediaTypeFromQTMediaType(type)])
        [tracks addObject:[[[QTTrack alloc] initWithMovie:self assetTrack:track] autorelease]];
    return tracks;
}

- (void)removeTrack:(QTTrack *)track
{
    [_asset removeTrack:(AVMovieTrack *)[track AVAssetTrack]];
    [self movieChanged];
}

- (QTTrack *)insertSegmentOfTrack:(QTTrack *)track timeRange:(QTTimeRange)range atTime:(QTTime)time
{
    AVMutableMovieTrack *target = [_asset mutableTrackCompatibleWithTrack:[track AVAssetTrack]];
    if (!target)
        target = [_asset addMutableTrackWithMediaType:[[track AVAssetTrack] mediaType] copySettingsFromTrack:[track AVAssetTrack] options:nil];
    if (![target insertTimeRange:HSCMTimeRangeFromQTTimeRange(range) ofTrack:[track AVAssetTrack]
                          atTime:HSCMTimeFromQTTime(time) copySampleData:NO error:NULL])
        return nil;
    [self movieChanged];
    return [[[QTTrack alloc] initWithMovie:self assetTrack:target] autorelease];
}

// ---- images

- (void *)frameImageAtTime:(QTTime)time withAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
    AVAssetImageGenerator *generator = _imageGenerator;
    if (!generator) {
        generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
        [generator setAppliesPreferredTrackTransform:YES];
        [generator setRequestedTimeToleranceBefore:kCMTimeZero];
        [generator setRequestedTimeToleranceAfter:kCMTimeZero];
        if ([[attributes objectForKey:QTMovieFrameImageSessionMode] boolValue])
            _imageGenerator = [generator retain];
    }
    NSValue *size = [attributes objectForKey:QTMovieFrameImageSize];
    [generator setMaximumSize:size ? NSSizeToCGSize([size sizeValue]) : CGSizeZero];
    CMTime at = HSCMTimeFromQTTime(time);
    if (CMTIME_IS_INDEFINITE(at))
        at = kCMTimeZero;
    CGImageRef image = [generator copyCGImageAtTime:at actualTime:NULL error:errorPtr];
    if (!image && CMTIME_COMPARE_INLINE(at, >=, [_asset duration])) {
        // the end of the movie shows its last frame
        CMTime last = CMTimeSubtract([_asset duration], CMTimeMake(1, [self timeScale]));
        image = [generator copyCGImageAtTime:CMTIME_COMPARE_INLINE(last, <, kCMTimeZero) ? kCMTimeZero : last actualTime:NULL error:errorPtr];
    }
    if (!image)
        return NULL;
    CFAutorelease(image);
    NSString *type = [attributes objectForKey:QTMovieFrameImageType];
    if ([type isEqualToString:QTMovieFrameImageTypeCGImageRef])
        return image;
    if ([type isEqualToString:QTMovieFrameImageTypeCIImage])
        return [CIImage imageWithCGImage:image];
    if ([type isEqualToString:QTMovieFrameImageTypeCVPixelBufferRef]) {
        NSImage *wrapper = [[[NSImage alloc] initWithCGImage:image size:NSZeroSize] autorelease];
        CVPixelBufferRef buffer = newPixelBuffer(wrapper, CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)));
        return buffer ? (void *)CFAutorelease(buffer) : NULL;
    }
    if ([type isEqualToString:QTMovieFrameImageTypeCVOpenGLTextureRef]) {
        setError(errorPtr, movieError(-50, @"OpenGL texture frame images are not supported."));
        return NULL;
    }
    NSImage *result = [[[NSImage alloc] initWithCGImage:image size:NSZeroSize] autorelease];
    return result;
}

- (NSImage *)frameImageAtTime:(QTTime)time
{
    return (NSImage *)[self frameImageAtTime:time withAttributes:@{ QTMovieFrameImageType: QTMovieFrameImageTypeNSImage } error:NULL];
}

- (NSImage *)posterImage { return [self frameImageAtTime:[[self attributeForKey:QTMoviePosterTimeAttribute] QTTimeValue]]; }
- (NSImage *)currentFrameImage { return [self frameImageAtTime:[self currentTime]]; }

// ---- editing

- (void)movieChanged
{
    [_item release];
    _item = nil;
    [_imageGenerator release];
    _imageGenerator = nil;
    if (_player)
        [self player];
    [[NSNotificationCenter defaultCenter] postNotificationName:QTMovieEditedNotification object:self];
}

- (void)insertSegmentOfMovie:(QTMovie *)movie timeRange:(QTTimeRange)range atTime:(QTTime)time
{
    if ([_asset insertTimeRange:HSCMTimeRangeFromQTTimeRange(range) ofAsset:[movie AVAsset]
                         atTime:HSCMTimeFromQTTime(time) copySampleData:NO error:NULL])
        [self movieChanged];
}

- (void)insertSegmentOfMovie:(QTMovie *)movie fromRange:(QTTimeRange)srcRange scaledToRange:(QTTimeRange)dstRange
{
    CMTime at = HSCMTimeFromQTTime(dstRange.time);
    if (![_asset insertTimeRange:HSCMTimeRangeFromQTTimeRange(srcRange) ofAsset:[movie AVAsset] atTime:at copySampleData:NO error:NULL])
        return;
    [_asset scaleTimeRange:CMTimeRangeMake(at, HSCMTimeFromQTTime(srcRange.duration)) toDuration:HSCMTimeFromQTTime(dstRange.duration)];
    [self movieChanged];
}

- (void)insertEmptySegmentAt:(QTTimeRange)range
{
    [_asset insertEmptyTimeRange:HSCMTimeRangeFromQTTimeRange(range)];
    [self movieChanged];
}

- (void)deleteSegment:(QTTimeRange)segment
{
    [_asset removeTimeRange:HSCMTimeRangeFromQTTimeRange(segment)];
    [self movieChanged];
}

- (void)scaleSegment:(QTTimeRange)segment newDuration:(QTTime)newDuration
{
    [_asset scaleTimeRange:HSCMTimeRangeFromQTTimeRange(segment) toDuration:HSCMTimeFromQTTime(newDuration)];
    [self movieChanged];
}

- (void)appendSelectionFromMovie:(id)aMovie
{
    QTMovie *movie = aMovie;
    QTTimeRange range = [movie selectionDuration].timeValue ? QTMakeTimeRange([movie selectionStart], [movie selectionDuration])
                                                            : QTMakeTimeRange(QTZeroTime, [movie duration]);
    [self insertSegmentOfMovie:movie timeRange:range atTime:[self duration]];
}

- (void)replaceSelectionWithSelectionFromMovie:(id)aMovie
{
    QTMovie *movie = aMovie;
    if (_selection.duration.timeValue)
        [_asset removeTimeRange:HSCMTimeRangeFromQTTimeRange(_selection)];
    QTTimeRange range = [movie selectionDuration].timeValue ? QTMakeTimeRange([movie selectionStart], [movie selectionDuration])
                                                            : QTMakeTimeRange(QTZeroTime, [movie duration]);
    [self insertSegmentOfMovie:movie timeRange:range atTime:_selection.time];
    [self setSelection:QTMakeTimeRange(_selection.time, range.duration)];
}

// Adds the image as a video frame at the end of the movie, compressed with
// QTAddImageCodecType (a four-character code string) at QTAddImageCodecQuality.
- (void)addImage:(NSImage *)image forDuration:(QTTime)duration withAttributes:(NSDictionary *)attributes
{
    if (!image)
        return;
    NSString *codecName = [attributes objectForKey:QTAddImageCodecType];
    OSType codec = 'jpeg';
    if ([codecName length] == 4)
        codec = (OSType)([codecName characterAtIndex:0] << 24 | [codecName characterAtIndex:1] << 16
                         | [codecName characterAtIndex:2] << 8 | [codecName characterAtIndex:3]);
    long quality = [attributes objectForKey:QTAddImageCodecQuality] ? [[attributes objectForKey:QTAddImageCodecQuality] longValue] : codecNormalQuality;
    CGSize size = NSSizeToCGSize([image size]);
    NSImageRep *rep = [[image representations] firstObject];
    if ([rep pixelsWide] > 0 && [rep pixelsHigh] > 0)
        size = CGSizeMake([rep pixelsWide], [rep pixelsHigh]);
    size.width = MAX(1, round(size.width));
    size.height = MAX(1, round(size.height));

    // one compression session for a run of frames with the same codec
    if (_imageSession && (_imageCodec != codec)) {
        VTCompressionSessionCompleteFrames(_imageSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_imageSession);
        CFRelease(_imageSession);
        _imageSession = NULL;
    }
    if (!_imageSession) {
        if (!_imageTrack || !CGSizeEqualToSize(_imageSize, size) || _imageCodec != codec) {
            [_imageTrack release];
            _imageTrack = [[_asset addMutableTrackWithMediaType:AVMediaTypeVideo copySettingsFromTrack:nil options:nil] retain];
            [_imageTrack setTimescale:(CMTimeScale)[self timeScale]];
            [_imageTrack setNaturalSize:size];
            _imageSize = size;
        }
        VTCompressionSessionRef session = NULL;
        CMVideoCodecType encoder = encoderCodec(codec);
        if (VTCompressionSessionCreate(NULL, (int32_t)_imageSize.width, (int32_t)_imageSize.height, encoder,
                                       NULL, NULL, NULL, imageEncoded, NULL, &session) != noErr)
            return;
        float q = quality >= codecLosslessQuality ? 1.0f : (float)quality / codecMaxQuality;
        VTSessionSetProperty(session, kVTCompressionPropertyKey_Quality, (CFNumberRef)[NSNumber numberWithFloat:q]);
        VTSessionSetProperty(session, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
        VTSessionSetProperty(session, kVTCompressionPropertyKey_MaxKeyFrameInterval, (CFNumberRef)@1);
        _imageSession = session;
        _imageCodec = codec;
    }
    CVPixelBufferRef pixels = newPixelBuffer(image, _imageSize);
    if (!pixels)
        return;
    CMTime length = HSCMTimeFromQTTime(duration);
    CMTimeRange media = [_imageTrack mediaPresentationTimeRange];
    CMTime mediaEnd = CMTIMERANGE_IS_VALID(media) && !CMTIMERANGE_IS_EMPTY(media) ? CMTimeRangeGetEnd(media) : kCMTimeZero;
    CMSampleBufferRef sample = NULL;
    VTCompressionSessionEncodeFrame(_imageSession, pixels, mediaEnd, length, NULL, &sample, NULL);
    VTCompressionSessionCompleteFrames(_imageSession, kCMTimeInvalid);
    CVPixelBufferRelease(pixels);
    if (!sample)
        return;
    CMSampleTimingInfo timing = { length, mediaEnd, kCMTimeInvalid };
    CMSampleBufferRef timed = NULL;
    CMSampleBufferCreateCopyWithNewTiming(NULL, sample, 1, &timing, &timed);
    CFRelease(sample);
    CMTime decodeTime, presentationTime;
    BOOL appended = timed && [_imageTrack appendSampleBuffer:timed decodeTime:&decodeTime presentationTime:&presentationTime error:NULL];
    if (appended) {
        CMTime end = [_asset duration];
        if (CMTIME_IS_INVALID(end))
            end = kCMTimeZero;
        [_imageTrack insertMediaTimeRange:CMTimeRangeMake(presentationTime, length) intoTimeRange:CMTimeRangeMake(end, length)];
        [self movieChanged];
    }
    if (timed)
        CFRelease(timed);
}

// ---- writing

// Writes the movie self-contained (QuickTime's flattening) or exported.
- (BOOL)writeToFile:(NSString *)fileName withAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
    NSURL *url = [NSURL fileURLWithPath:fileName];
    NSURL *target = url;
    NSURL *replacementDirectory = nil;
    if ([[url URLByStandardizingPath] isEqual:[_url URLByStandardizingPath]]) {
        // written next to the movie first: replacing can't move a file across volumes
        replacementDirectory = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask
                                                             appropriateForURL:url create:YES error:NULL];
        target = replacementDirectory ? [replacementDirectory URLByAppendingPathComponent:[url lastPathComponent]] : temporaryURL([fileName pathExtension]);
    }
    BOOL ok;
    AVMutableMovie *source = [[_asset copy] autorelease];
    // copies of a mutable movie leave its metadata behind
    NSArray *metadata = [_asset metadata];
    if ([[attributes objectForKey:QTMovieExport] boolValue]) {
        NSString *preset = nil;
        AVFileType type = fileTypeForExportType((OSType)[[attributes objectForKey:QTMovieExportType] unsignedLongValue], &preset);
        if (!preset)
            ok = writePCM(source, target, type, errorPtr);
        else {
            [[NSFileManager defaultManager] removeItemAtURL:target error:NULL];
            AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:source presetName:preset];
            [session setOutputURL:target];
        [session setMetadata:metadata];
            [session setOutputFileType:type];
            ok = runExport(session, errorPtr);
        }
    }
    else {
        [[NSFileManager defaultManager] removeItemAtURL:target error:NULL];
        AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:source presetName:AVAssetExportPresetPassthrough];
        [session setOutputURL:target];
        [session setMetadata:metadata];
        [session setOutputFileType:AVFileTypeQuickTimeMovie];
        ok = runExport(session, errorPtr);
        if (!ok) {
            // samples AVFoundation can't pass through are recompressed
            [[NSFileManager defaultManager] removeItemAtURL:target error:NULL];
            session = [AVAssetExportSession exportSessionWithAsset:source presetName:AVAssetExportPresetHighestQuality];
            [session setOutputURL:target];
        [session setMetadata:metadata];
            [session setOutputFileType:AVFileTypeQuickTimeMovie];
            ok = runExport(session, errorPtr);
        }
    }
    if (ok && target != url) {
        ok = [[NSFileManager defaultManager] replaceItemAtURL:url withItemAtURL:target backupItemName:nil
                                                      options:0 resultingItemURL:NULL error:errorPtr];
        if (ok)
            [self loadURL:url error:NULL];
    }
    if (replacementDirectory)
        [[NSFileManager defaultManager] removeItemAtURL:replacementDirectory error:NULL];
    return ok;
}

- (BOOL)writeToFile:(NSString *)fileName withAttributes:(NSDictionary *)attributes
{
    return [self writeToFile:fileName withAttributes:attributes error:NULL];
}

- (BOOL)canUpdateMovieFile
{
    return [_url isFileURL] && [[NSFileManager defaultManager] isWritableFileAtPath:[_url path]];
}

- (BOOL)updateMovieFile
{
    if (![_url isFileURL])
        return NO;
    QTTime time = [self currentTime];
    BOOL ok = [self writeToFile:[_url path] withAttributes:[NSDictionary dictionaryWithObject:@YES forKey:QTMovieFlatten] error:NULL];
    if (ok) {
        [self movieChanged];
        [self setCurrentTime:time];
    }
    return ok;
}

- (NSData *)movieFormatRepresentation
{
    NSURL *url = temporaryURL(@"mov");
    NSData *data = nil;
    if ([self writeToFile:[url path] withAttributes:[NSDictionary dictionaryWithObject:@YES forKey:QTMovieFlatten] error:NULL])
        data = [NSData dataWithContentsOfURL:url];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    return data;
}

// ---- QuickTime and AVFoundation

- (void *)quickTimeMovie { return self; }
- (void *)quickTimeMovieController { return NULL; }
- (AVAsset *)AVAsset { return _asset; }
- (AVPlayer *)AVPlayer { return [self player]; }
- (AVPlayerItem *)AVPlayerItem { return [[self player] currentItem]; }

@end
