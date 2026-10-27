#import "HSQTKit.h"
#import <mach/mach_time.h>

#define QTSTRING(name) NSString * const name = @#name

QTSTRING(QTFormatDescriptionAudioStreamBasicDescriptionAttribute);
QTSTRING(QTFormatDescriptionAudioMagicCookieAttribute);
QTSTRING(QTFormatDescriptionAudioChannelLayoutAttribute);
QTSTRING(QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute);
QTSTRING(QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute);
QTSTRING(QTFormatDescriptionVideoEncodedPixelsSizeAttribute);

QTSTRING(QTSampleBufferSMPTETimeAttribute);
QTSTRING(QTSampleBufferDateRecordedAttribute);
QTSTRING(QTSampleBufferHostTimeAttribute);
QTSTRING(QTSampleBufferSceneChangeTypeAttribute);
QTSTRING(QTSampleBufferExplicitSceneChange);
QTSTRING(QTSampleBufferTimeStampDiscontinuitySceneChange);

// ---- QTCompressionOptions

// QTKit's compression options identifiers, as AVFoundation output settings.
static NSDictionary *compressionSettings(NSString *identifier, NSString **mediaTypePtr, NSString **namePtr)
{
    static NSDictionary *table;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSDictionary *(^video)(NSString *, int, int) = ^(NSString *codec, int width, int height) {
            NSMutableDictionary *s = [NSMutableDictionary dictionaryWithObject:codec forKey:AVVideoCodecKey];
            if (width) {
                [s setObject:@(width) forKey:AVVideoWidthKey];
                [s setObject:@(height) forKey:AVVideoHeightKey];
                [s setObject:AVVideoScalingModeResizeAspect forKey:AVVideoScalingModeKey];
            }
            return (NSDictionary *)s;
        };
        table = [@{
            @"QTCompressionOptions120SizeH264Video": @[QTMediaTypeVideo, @"H.264, 160 x 120", video(AVVideoCodecTypeH264, 160, 120)],
            @"QTCompressionOptions240SizeH264Video": @[QTMediaTypeVideo, @"H.264, 320 x 240", video(AVVideoCodecTypeH264, 320, 240)],
            @"QTCompressionOptionsSD480SizeH264Video": @[QTMediaTypeVideo, @"H.264, 640 x 480", video(AVVideoCodecTypeH264, 640, 480)],
            @"QTCompressionOptionsHD720SizeH264Video": @[QTMediaTypeVideo, @"H.264, 1280 x 720", video(AVVideoCodecTypeH264, 1280, 720)],
            @"QTCompressionOptions120SizeMPEG4Video": @[QTMediaTypeVideo, @"MPEG-4, 160 x 120", video(AVVideoCodecTypeH264, 160, 120)],
            @"QTCompressionOptions240SizeMPEG4Video": @[QTMediaTypeVideo, @"MPEG-4, 320 x 240", video(AVVideoCodecTypeH264, 320, 240)],
            @"QTCompressionOptionsSD480SizeMPEG4Video": @[QTMediaTypeVideo, @"MPEG-4, 640 x 480", video(AVVideoCodecTypeH264, 640, 480)],
            @"QTCompressionOptionsLosslessAnimationVideo": @[QTMediaTypeVideo, @"Lossless (ProRes 4444)", video(AVVideoCodecTypeAppleProRes4444, 0, 0)],
            @"QTCompressionOptionsLosslessAppleIntermediateVideo": @[QTMediaTypeVideo, @"Apple Intermediate (ProRes 422)", video(AVVideoCodecTypeAppleProRes422, 0, 0)],
            @"QTCompressionOptionsJPEGVideo": @[QTMediaTypeVideo, @"Photo JPEG", video(AVVideoCodecTypeJPEG, 0, 0)],
            @"QTCompressionOptionsHighQualityAACAudio": @[QTMediaTypeSound, @"AAC, high quality",
                @{ AVFormatIDKey: @(kAudioFormatMPEG4AAC), AVEncoderBitRateKey: @128000 }],
            @"QTCompressionOptionsVoiceQualityAACAudio": @[QTMediaTypeSound, @"AAC, voice quality",
                @{ AVFormatIDKey: @(kAudioFormatMPEG4AAC), AVEncoderBitRateKey: @32000, AVNumberOfChannelsKey: @1 }],
            @"QTCompressionOptionsLosslessALACAudio": @[QTMediaTypeSound, @"Apple Lossless",
                @{ AVFormatIDKey: @(kAudioFormatAppleLossless) }],
        } retain];
    });
    NSArray *entry = [table objectForKey:identifier];
    if (!entry)
        return nil;
    if (mediaTypePtr) *mediaTypePtr = [entry objectAtIndex:0];
    if (namePtr) *namePtr = [entry objectAtIndex:1];
    return [entry objectAtIndex:2];
}

@implementation QTCompressionOptions

+ (NSArray *)compressionOptionsIdentifiersForMediaType:(NSString *)mediaType
{
    NSArray *all = @[@"QTCompressionOptions120SizeH264Video", @"QTCompressionOptions240SizeH264Video",
                     @"QTCompressionOptionsSD480SizeH264Video", @"QTCompressionOptionsHD720SizeH264Video",
                     @"QTCompressionOptions120SizeMPEG4Video", @"QTCompressionOptions240SizeMPEG4Video",
                     @"QTCompressionOptionsSD480SizeMPEG4Video", @"QTCompressionOptionsLosslessAnimationVideo",
                     @"QTCompressionOptionsLosslessAppleIntermediateVideo", @"QTCompressionOptionsJPEGVideo",
                     @"QTCompressionOptionsHighQualityAACAudio", @"QTCompressionOptionsVoiceQualityAACAudio",
                     @"QTCompressionOptionsLosslessALACAudio"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *identifier in all) {
        NSString *type = nil;
        compressionSettings(identifier, &type, NULL);
        if (!mediaType || [type isEqualToString:mediaType])
            [result addObject:identifier];
    }
    return result;
}

+ (id)compressionOptionsWithIdentifier:(NSString *)identifier
{
    NSString *type = nil;
    NSDictionary *settings = compressionSettings(identifier, &type, NULL);
    if (!settings)
        return nil;
    QTCompressionOptions *options = [[[self alloc] init] autorelease];
    options->_identifier = [identifier copy];
    options->_mediaType = [type retain];
    options->_settings = [settings retain];
    return options;
}

- (void)dealloc
{
    [_identifier release];
    [_mediaType release];
    [_settings release];
    [super dealloc];
}

- (NSString *)identifier { return _identifier; }
- (NSString *)mediaType { return _mediaType; }
- (NSDictionary *)AVOutputSettings { return _settings; }

- (NSString *)localizedDisplayName
{
    NSString *name = nil;
    compressionSettings(_identifier, NULL, &name);
    return name;
}

- (NSString *)localizedCompressionOptionsSummary { return [self localizedDisplayName]; }

- (BOOL)isEqualToCompressionOptions:(QTCompressionOptions *)compressionOptions
{
    return [_identifier isEqualToString:[compressionOptions identifier]];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[QTCompressionOptions class]] && [self isEqualToCompressionOptions:object];
}

- (NSUInteger)hash { return [_identifier hash]; }

@end

// ---- QTFormatDescription

@implementation QTFormatDescription

- (id)initWithCMFormatDescription:(CMFormatDescriptionRef)description
{
    if (!description) {
        [self release];
        return nil;
    }
    if ((self = [super init]))
        _description = (CMFormatDescriptionRef)CFRetain(description);
    return self;
}

- (void)dealloc
{
    if (_description)
        CFRelease(_description);
    [super dealloc];
}

- (CMFormatDescriptionRef)CMFormatDescription { return _description; }

- (NSString *)mediaType
{
    switch (CMFormatDescriptionGetMediaType(_description)) {
    case kCMMediaType_Video: return QTMediaTypeVideo;
    case kCMMediaType_Audio: return QTMediaTypeSound;
    case kCMMediaType_Muxed: return QTMediaTypeMuxed;
    case kCMMediaType_Text: return QTMediaTypeText;
    case kCMMediaType_TimeCode: return QTMediaTypeTimeCode;
    default: return QTMediaTypeBase;
    }
}

- (UInt32)formatType { return CMFormatDescriptionGetMediaSubType(_description); }

- (NSString *)localizedFormatSummary
{
    FourCharCode type = CMFormatDescriptionGetMediaSubType(_description);
    NSString *codec = (NSString *)CMFormatDescriptionGetExtension(_description, kCMFormatDescriptionExtension_FormatName);
    if (!codec) {
        char c[5] = { (char)(type >> 24), (char)(type >> 16), (char)(type >> 8), (char)type, 0 };
        codec = [NSString stringWithFormat:@"'%s'", c];
    }
    if (CMFormatDescriptionGetMediaType(_description) == kCMMediaType_Video) {
        CMVideoDimensions d = CMVideoFormatDescriptionGetDimensions(_description);
        return [NSString stringWithFormat:@"%@, %d x %d", codec, d.width, d.height];
    }
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(_description);
    if (asbd) {
        if (type == kAudioFormatLinearPCM)
            codec = @"Linear PCM";
        else if (type == kAudioFormatMPEG4AAC)
            codec = @"AAC";
        return [NSString stringWithFormat:@"%@, %@, %g kHz", codec,
                asbd->mChannelsPerFrame == 1 ? @"Mono" : asbd->mChannelsPerFrame == 2 ? @"Stereo"
                    : [NSString stringWithFormat:@"%u channels", (unsigned)asbd->mChannelsPerFrame],
                asbd->mSampleRate / 1000.0];
    }
    return codec;
}

- (NSData *)quickTimeSampleDescription { return nil; }

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTFormatDescriptionVideoEncodedPixelsSizeAttribute]) {
        CMVideoDimensions d = CMVideoFormatDescriptionGetDimensions(_description);
        return [NSValue valueWithSize:NSMakeSize(d.width, d.height)];
    }
    if ([key isEqualToString:QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute])
        return [NSValue valueWithSize:NSSizeFromCGSize(CMVideoFormatDescriptionGetPresentationDimensions(_description, YES, YES))];
    if ([key isEqualToString:QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute])
        return [NSValue valueWithSize:NSSizeFromCGSize(CMVideoFormatDescriptionGetPresentationDimensions(_description, YES, NO))];
    if ([key isEqualToString:QTFormatDescriptionAudioStreamBasicDescriptionAttribute]) {
        const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(_description);
        return asbd ? [NSValue valueWithBytes:asbd objCType:@encode(AudioStreamBasicDescription)] : nil;
    }
    if ([key isEqualToString:QTFormatDescriptionAudioChannelLayoutAttribute]) {
        size_t size = 0;
        const AudioChannelLayout *layout = CMAudioFormatDescriptionGetChannelLayout(_description, &size);
        return layout ? [NSData dataWithBytes:layout length:size] : nil;
    }
    if ([key isEqualToString:QTFormatDescriptionAudioMagicCookieAttribute]) {
        size_t size = 0;
        const void *cookie = CMAudioFormatDescriptionGetMagicCookie(_description, &size);
        return cookie ? [NSData dataWithBytes:cookie length:size] : nil;
    }
    return nil;
}

- (NSDictionary *)formatDescriptionAttributes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *keys = CMFormatDescriptionGetMediaType(_description) == kCMMediaType_Video
        ? @[QTFormatDescriptionVideoEncodedPixelsSizeAttribute, QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute,
            QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute]
        : @[QTFormatDescriptionAudioStreamBasicDescriptionAttribute, QTFormatDescriptionAudioChannelLayoutAttribute,
            QTFormatDescriptionAudioMagicCookieAttribute];
    for (NSString *key in keys) {
        id value = [self attributeForKey:key];
        if (value)
            [result setObject:value forKey:key];
    }
    return result;
}

- (BOOL)isEqualToFormatDescription:(QTFormatDescription *)formatDescription
{
    return CMFormatDescriptionEqual(_description, [formatDescription CMFormatDescription]);
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[QTFormatDescription class]] && [self isEqualToFormatDescription:object];
}

- (NSUInteger)hash { return CFHash(_description); }

@end

// ---- QTSampleBuffer

@implementation QTSampleBuffer

- (id)initWithCMSampleBuffer:(CMSampleBufferRef)buffer connection:(AVCaptureConnection *)connection
{
    if (!buffer) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _buffer = (CMSampleBufferRef)CFRetain(buffer);
        _connection = [connection retain];
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_buffer);
    [_connection release];
    [_contiguous release];
    [_formatDescription release];
    [super dealloc];
}

- (CMSampleBufferRef)CMSampleBuffer { return _buffer; }

// The samples' bytes, copied together if the block buffer is scattered;
// a video frame's are its pixel buffer's.
- (void *)bytesForAllSamples
{
    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(_buffer);
    if (block) {
        size_t length = CMBlockBufferGetDataLength(block);
        char *pointer = NULL;
        size_t contiguous = 0;
        if (CMBlockBufferGetDataPointer(block, 0, &contiguous, NULL, &pointer) == kCMBlockBufferNoErr && contiguous == length)
            return pointer;
        if (!_contiguous) {
            NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
            CMBlockBufferCopyDataBytes(block, 0, length, [data mutableBytes]);
            _contiguous = data;
        }
        return (void *)[_contiguous bytes];
    }
    CVImageBufferRef image = CMSampleBufferGetImageBuffer(_buffer);
    if (image && CFGetTypeID(image) == CVPixelBufferGetTypeID()) {
        // stays locked for the life of the sample buffer, as QTKit's did
        if (!_contiguous) {
            CVPixelBufferLockBaseAddress(image, kCVPixelBufferLock_ReadOnly);
            _contiguous = [[NSData alloc] initWithBytesNoCopy:CVPixelBufferGetBaseAddress(image)
                                                       length:CVPixelBufferGetDataSize(image)
                                                  deallocator:^(void *bytes, NSUInteger length) {
                CVPixelBufferUnlockBaseAddress(image, kCVPixelBufferLock_ReadOnly);
            }];
        }
        return (void *)[_contiguous bytes];
    }
    return NULL;
}

- (NSUInteger)lengthForAllSamples
{
    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(_buffer);
    if (block)
        return CMBlockBufferGetDataLength(block);
    CVImageBufferRef image = CMSampleBufferGetImageBuffer(_buffer);
    if (image && CFGetTypeID(image) == CVPixelBufferGetTypeID())
        return CVPixelBufferGetDataSize(image);
    return 0;
}

- (QTFormatDescription *)formatDescription
{
    if (!_formatDescription)
        _formatDescription = [[QTFormatDescription alloc] initWithCMFormatDescription:CMSampleBufferGetFormatDescription(_buffer)];
    return _formatDescription;
}

- (QTTime)duration { return HSQTTimeFromCMTime(CMSampleBufferGetDuration(_buffer)); }
- (QTTime)decodeTime { return HSQTTimeFromCMTime(CMSampleBufferGetDecodeTimeStamp(_buffer)); }
- (QTTime)presentationTime { return HSQTTimeFromCMTime(CMSampleBufferGetPresentationTimeStamp(_buffer)); }
- (NSInteger)numberOfSamples { return CMSampleBufferGetNumSamples(_buffer); }

// The host time (mach_absolute_time units) its first sample was captured at.
- (UInt64)hostTime
{
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(_buffer);
    CMClockRef host = CMClockGetHostTimeClock();
    CMClockRef clock = NULL;
    if ([[_connection inputPorts] count])
        clock = [[[_connection inputPorts] objectAtIndex:0] clock];
    CMTime hostTime = clock ? CMSyncConvertTime(pts, clock, host) : pts;
    if (!CMTIME_IS_NUMERIC(hostTime))
        return mach_absolute_time();
    return CMClockConvertHostTimeToSystemUnits(hostTime);
}

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTSampleBufferHostTimeAttribute])
        return [NSNumber numberWithUnsignedLongLong:[self hostTime]];
    if ([key isEqualToString:QTSampleBufferSceneChangeTypeAttribute]) {
        CFBooleanRef discontinuity = CMGetAttachment(_buffer, kCMSampleBufferAttachmentKey_DrainAfterDecoding, NULL);
        return discontinuity == kCFBooleanTrue ? QTSampleBufferTimeStampDiscontinuitySceneChange : nil;
    }
    if ([key isEqualToString:QTSampleBufferDateRecordedAttribute])
        return nil;
    return nil;
}

- (NSDictionary *)sampleBufferAttributes
{
    return [NSDictionary dictionaryWithObject:[self attributeForKey:QTSampleBufferHostTimeAttribute] forKey:QTSampleBufferHostTimeAttribute];
}

// The use count is the wrapper's retain count: the CMSampleBuffer lives as
// long as the wrapper does.
- (void)incrementSampleUseCount { [self retain]; }
- (void)decrementSampleUseCount { [self release]; }

- (AudioBufferList *)audioBufferListWithOptions:(NSUInteger)options
{
    size_t size = 0;
    if (CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(_buffer, &size, NULL, 0, NULL, NULL, 0, NULL) != noErr || !size)
        return NULL;
    NSMutableData *list = [NSMutableData dataWithLength:size];
    CMBlockBufferRef retained = NULL;
    UInt32 flags = options & QTSampleBufferAudioBufferListOptionAssure16ByteAlignment
        ? kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment : 0;
    if (CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(_buffer, NULL, [list mutableBytes], size, NULL, NULL, flags, &retained) != noErr)
        return NULL;
    // the block buffer must outlive the list, which lives as long as this autorelease pool
    if (retained)
        CFAutorelease(retained);
    return [list mutableBytes];
}

- (OSStatus)getAudioStreamPacketDescriptions:(void *)audioStreamPacketDescriptions inRange:(NSRange)range
{
    const AudioStreamPacketDescription *all = NULL;
    size_t size = 0;
    OSStatus status = CMSampleBufferGetAudioStreamPacketDescriptionsPtr(_buffer, &all, &size);
    if (status != noErr)
        return status;
    if (!all || NSMaxRange(range) * sizeof(AudioStreamPacketDescription) > size)
        return kCMSampleBufferError_ArrayTooSmall;
    memcpy(audioStreamPacketDescriptions, all + range.location, range.length * sizeof(AudioStreamPacketDescription));
    return noErr;
}

- (OSStatus)getAudioStreamPacketDescriptionsPtr:(void **)outAudioStreamPacketDescriptionsPtr
{
    return CMSampleBufferGetAudioStreamPacketDescriptionsPtr(_buffer, (const AudioStreamPacketDescription **)outAudioStreamPacketDescriptionsPtr, NULL);
}

@end
