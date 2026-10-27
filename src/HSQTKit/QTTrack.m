#import "HSQTKit.h"

#define QTSTRING(name) NSString * const name = @#name

QTSTRING(QTTrackBoundsAttribute);
QTSTRING(QTTrackCreationTimeAttribute);
QTSTRING(QTTrackDimensionsAttribute);
QTSTRING(QTTrackDisplayNameAttribute);
QTSTRING(QTTrackEnabledAttribute);
QTSTRING(QTTrackFormatSummaryAttribute);
QTSTRING(QTTrackIsChapterTrackAttribute);
QTSTRING(QTTrackHasApertureModeDimensionsAttribute);
QTSTRING(QTTrackIDAttribute);
QTSTRING(QTTrackLayerAttribute);
QTSTRING(QTTrackMediaTypeAttribute);
QTSTRING(QTTrackModificationTimeAttribute);
QTSTRING(QTTrackRangeAttribute);
QTSTRING(QTTrackTimeScaleAttribute);
QTSTRING(QTTrackUsageInMovieAttribute);
QTSTRING(QTTrackUsageInPosterAttribute);
QTSTRING(QTTrackUsageInPreviewAttribute);
QTSTRING(QTTrackVolumeAttribute);

NSString * const QTMediaCharacteristicVisual = @"eyes";
NSString * const QTMediaCharacteristicAudio = @"ears";
NSString * const QTMediaCharacteristicCanSendVideo = @"vsnd";
NSString * const QTMediaCharacteristicProvidesActions = @"actn";
NSString * const QTMediaCharacteristicNonLinear = @"nonl";
NSString * const QTMediaCharacteristicCanStep = @"step";
NSString * const QTMediaCharacteristicHasNoDuration = @"noti";
NSString * const QTMediaCharacteristicHasSkinData = @"skin";
NSString * const QTMediaCharacteristicProvidesKeyFocus = @"keyf";
NSString * const QTMediaCharacteristicHasVideoFrameRate = @"vfrr";

QTSTRING(QTMediaDurationAttribute);
QTSTRING(QTMediaSampleCountAttribute);
QTSTRING(QTMediaTimeScaleAttribute);
QTSTRING(QTMediaTypeAttribute);

@interface QTMovie (HSQTKitPrivate)
- (void)movieChanged;
- (long)timeScale;
@end

@implementation QTTrack

+ (id)trackWithQuickTimeTrack:(void *)track error:(NSError **)errorPtr
{
    return [[[self alloc] initWithQuickTimeTrack:track error:errorPtr] autorelease];
}

- (id)initWithQuickTimeTrack:(void *)track error:(NSError **)errorPtr
{
    if (errorPtr)
        *errorPtr = [NSError errorWithDomain:QTKitErrorDomain code:-2010 userInfo:nil];
    [self release];
    return nil;
}

- (id)initWithMovie:(QTMovie *)movie assetTrack:(AVAssetTrack *)track
{
    if ((self = [super init])) {
        _movie = movie;
        _track = [track retain];
        _enabled = [track isEnabled];
        _volume = [track preferredVolume];
    }
    return self;
}

- (void)dealloc
{
    [_track release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[QTTrack class]] && [((QTTrack *)object)->_track isEqual:_track];
}

- (NSUInteger)hash { return [_track hash]; }
- (QTMovie *)movie { return _movie; }
- (QTMedia *)media { return [[[QTMedia alloc] initWithTrack:self] autorelease]; }
- (AVAssetTrack *)AVAssetTrack { return _track; }
- (void *)quickTimeTrack { return NULL; }
- (BOOL)isEnabled { return [_track isEnabled]; }

- (void)setEnabled:(BOOL)enabled
{
    if ([_track isKindOfClass:[AVMutableMovieTrack class]]) {
        [(AVMutableMovieTrack *)_track setEnabled:enabled];
        [_movie movieChanged];
    }
}

- (float)volume { return [_track preferredVolume]; }

- (void)setVolume:(float)volume
{
    if ([_track isKindOfClass:[AVMutableMovieTrack class]]) {
        [(AVMutableMovieTrack *)_track setPreferredVolume:volume];
        [_movie movieChanged];
    }
}

- (NSDictionary *)trackAttributes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in [NSArray arrayWithObjects:QTTrackBoundsAttribute, QTTrackDimensionsAttribute, QTTrackDisplayNameAttribute,
                           QTTrackEnabledAttribute, QTTrackFormatSummaryAttribute, QTTrackIDAttribute, QTTrackLayerAttribute,
                           QTTrackMediaTypeAttribute, QTTrackRangeAttribute, QTTrackTimeScaleAttribute, QTTrackVolumeAttribute, nil]) {
        id value = [self attributeForKey:key];
        if (value)
            [result setObject:value forKey:key];
    }
    return result;
}

- (void)setTrackAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes)
        [self setAttribute:[attributes objectForKey:key] forKey:key];
}

- (id)attributeForKey:(NSString *)key
{
    if ([key isEqualToString:QTTrackMediaTypeAttribute])
        return HSQTMediaTypeFromAVMediaType([_track mediaType]);
    if ([key isEqualToString:QTTrackEnabledAttribute])
        return [NSNumber numberWithBool:[_track isEnabled]];
    if ([key isEqualToString:QTTrackIDAttribute])
        return [NSNumber numberWithInt:[_track trackID]];
    if ([key isEqualToString:QTTrackTimeScaleAttribute])
        return [NSNumber numberWithLong:[_track naturalTimeScale]];
    if ([key isEqualToString:QTTrackRangeAttribute])
        return [NSValue valueWithQTTimeRange:HSQTTimeRangeFromCMTimeRange([_track timeRange])];
    if ([key isEqualToString:QTTrackVolumeAttribute])
        return [NSNumber numberWithFloat:[_track preferredVolume]];
    if ([key isEqualToString:QTTrackLayerAttribute])
        return [NSNumber numberWithShort:(short)[(AVMovieTrack *)_track layer]];
    if ([key isEqualToString:QTTrackDimensionsAttribute])
        return [NSValue valueWithSize:NSSizeFromCGSize([_track naturalSize])];
    if ([key isEqualToString:QTTrackBoundsAttribute]) {
        CGRect r = CGRectApplyAffineTransform(CGRectMake(0, 0, [_track naturalSize].width, [_track naturalSize].height),
                                              [_track preferredTransform]);
        return [NSValue valueWithRect:NSRectFromCGRect(CGRectStandardize(r))];
    }
    if ([key isEqualToString:QTTrackDisplayNameAttribute]) {
        for (AVMetadataItem *item in [AVMetadataItem metadataItemsFromArray:[_track commonMetadata] withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon])
            if ([item stringValue])
                return [item stringValue];
        NSString *type = [_track mediaType];
        if ([type isEqualToString:AVMediaTypeVideo]) return @"Video Track";
        if ([type isEqualToString:AVMediaTypeAudio]) return @"Sound Track";
        if ([type isEqualToString:AVMediaTypeText]) return @"Text Track";
        if ([type isEqualToString:AVMediaTypeTimecode]) return @"Timecode Track";
        return @"Track";
    }
    if ([key isEqualToString:QTTrackFormatSummaryAttribute]) {
        CMFormatDescriptionRef format = (CMFormatDescriptionRef)[[_track formatDescriptions] firstObject];
        return format ? [[[[QTFormatDescription alloc] initWithCMFormatDescription:format] autorelease] localizedFormatSummary] : @"";
    }
    if ([key isEqualToString:QTTrackIsChapterTrackAttribute] || [key isEqualToString:QTTrackHasApertureModeDimensionsAttribute])
        return [NSNumber numberWithBool:NO];
    if ([key isEqualToString:QTTrackUsageInMovieAttribute] || [key isEqualToString:QTTrackUsageInPosterAttribute]
        || [key isEqualToString:QTTrackUsageInPreviewAttribute])
        return [NSNumber numberWithBool:YES];
    return nil;
}

- (void)setAttribute:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:QTTrackEnabledAttribute])
        [self setEnabled:[value boolValue]];
    else if ([key isEqualToString:QTTrackVolumeAttribute])
        [self setVolume:[value floatValue]];
    else if (![_track isKindOfClass:[AVMutableMovieTrack class]])
        return;
    else if ([key isEqualToString:QTTrackLayerAttribute])
        [(AVMutableMovieTrack *)_track setLayer:[value integerValue]];
    else if ([key isEqualToString:QTTrackDimensionsAttribute])
        [(AVMutableMovieTrack *)_track setNaturalSize:NSSizeToCGSize([value sizeValue])];
    else if ([key isEqualToString:QTTrackBoundsAttribute]) {
        NSRect bounds = [value rectValue];
        CGSize size = [_track naturalSize];
        CGAffineTransform t = CGAffineTransformMakeTranslation(bounds.origin.x, bounds.origin.y);
        if (size.width > 0 && size.height > 0)
            t = CGAffineTransformScale(t, bounds.size.width / size.width, bounds.size.height / size.height);
        [(AVMutableMovieTrack *)_track setPreferredTransform:t];
    }
    else
        return;
    [_movie movieChanged];
}

- (void)insertSegmentOfTrack:(QTTrack *)track timeRange:(QTTimeRange)range atTime:(QTTime)time
{
    if (![_track isKindOfClass:[AVMutableMovieTrack class]])
        return;
    if ([(AVMutableMovieTrack *)_track insertTimeRange:HSCMTimeRangeFromQTTimeRange(range) ofTrack:[track AVAssetTrack]
                                                atTime:HSCMTimeFromQTTime(time) copySampleData:NO error:NULL])
        [_movie movieChanged];
}

- (void)insertEmptySegmentAt:(QTTimeRange)range
{
    if (![_track isKindOfClass:[AVMutableMovieTrack class]])
        return;
    [(AVMutableMovieTrack *)_track insertEmptyTimeRange:HSCMTimeRangeFromQTTimeRange(range)];
    [_movie movieChanged];
}

- (void)deleteSegment:(QTTimeRange)segment
{
    if (![_track isKindOfClass:[AVMutableMovieTrack class]])
        return;
    [(AVMutableMovieTrack *)_track removeTimeRange:HSCMTimeRangeFromQTTimeRange(segment)];
    [_movie movieChanged];
}

- (void)scaleSegment:(QTTimeRange)segment newDuration:(QTTime)newDuration
{
    if (![_track isKindOfClass:[AVMutableMovieTrack class]])
        return;
    [(AVMutableMovieTrack *)_track scaleTimeRange:HSCMTimeRangeFromQTTimeRange(segment) toDuration:HSCMTimeFromQTTime(newDuration)];
    [_movie movieChanged];
}

// Images go into the movie's image track: a movie has one.
- (void)addImage:(NSImage *)image forDuration:(QTTime)duration withAttributes:(NSDictionary *)attributes
{
    [_movie addImage:image forDuration:duration withAttributes:attributes];
}

@end

@implementation QTMedia

+ (id)mediaWithQuickTimeMedia:(void *)media error:(NSError **)errorPtr
{
    if (errorPtr)
        *errorPtr = [NSError errorWithDomain:QTKitErrorDomain code:-2010 userInfo:nil];
    return nil;
}

- (id)initWithTrack:(QTTrack *)track
{
    if ((self = [super init]))
        _track = [track retain];
    return self;
}

- (void)dealloc
{
    [_track release];
    [super dealloc];
}

- (QTTrack *)track { return _track; }
- (void *)quickTimeMedia { return NULL; }

- (id)attributeForKey:(NSString *)key
{
    AVAssetTrack *track = [_track AVAssetTrack];
    if ([key isEqualToString:QTMediaTypeAttribute])
        return HSQTMediaTypeFromAVMediaType([track mediaType]);
    if ([key isEqualToString:QTMediaTimeScaleAttribute])
        return [NSNumber numberWithLong:[track naturalTimeScale]];
    if ([key isEqualToString:QTMediaDurationAttribute]) {
        CMTimeRange range = [track isKindOfClass:[AVMovieTrack class]] ? [(AVMovieTrack *)track mediaPresentationTimeRange] : [track timeRange];
        return [NSValue valueWithQTTime:HSQTTimeFromCMTime(range.duration)];
    }
    if ([key isEqualToString:QTMediaSampleCountAttribute]) {
        if ([track canProvideSampleCursors]) {
            AVSampleCursor *cursor = [track makeSampleCursorAtFirstSampleInDecodeOrder];
            long count = cursor ? 1 : 0;
            while (cursor && [cursor stepInDecodeOrderByCount:1] == 1)
                count++;
            return [NSNumber numberWithLong:count];
        }
        return [NSNumber numberWithLong:(long)lround(CMTimeGetSeconds([track timeRange].duration) * [track nominalFrameRate])];
    }
    return nil;
}

- (NSDictionary *)mediaAttributes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in [NSArray arrayWithObjects:QTMediaTypeAttribute, QTMediaTimeScaleAttribute, QTMediaDurationAttribute,
                           QTMediaSampleCountAttribute, nil]) {
        id value = [self attributeForKey:key];
        if (value)
            [result setObject:value forKey:key];
    }
    return result;
}

- (BOOL)hasCharacteristic:(NSString *)characteristic
{
    AVAssetTrack *track = [_track AVAssetTrack];
    if ([characteristic isEqualToString:QTMediaCharacteristicVisual])
        return [track hasMediaCharacteristic:AVMediaCharacteristicVisual];
    if ([characteristic isEqualToString:QTMediaCharacteristicAudio])
        return [track hasMediaCharacteristic:AVMediaCharacteristicAudible];
    if ([characteristic isEqualToString:QTMediaCharacteristicCanStep] || [characteristic isEqualToString:QTMediaCharacteristicHasVideoFrameRate])
        return [[track mediaType] isEqualToString:AVMediaTypeVideo];
    return NO;
}

@end
