// The part of QTKit HyperStudio uses, implemented on AVFoundation and
// CoreMedia (QTKit and QuickTime are gone). The names and behaviour follow
// QTKit's, so the translated code keeps the original calls.
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVKit/AVKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

// ---- QTTime

enum { kQTTimeIsIndefinite = 1 << 0 };

typedef struct {
    long long timeValue;
    long timeScale;
    long flags;
} QTTime;

typedef struct {
    QTTime time;
    QTTime duration;
} QTTimeRange;

extern const QTTime QTZeroTime;
extern const QTTime QTIndefiniteTime;
extern const QTTimeRange QTZeroTimeRange;

QTTime QTMakeTime(long long timeValue, long timeScale);
QTTime QTMakeTimeWithTimeInterval(NSTimeInterval timeInterval);
QTTime QTMakeTimeWithTimeRecord(void *timeRecord);
QTTime QTMakeTimeScaled(QTTime time, long timeScale);
BOOL QTGetTimeInterval(QTTime time, NSTimeInterval *timeInterval);
NSComparisonResult QTTimeCompare(QTTime time, QTTime otherTime);
QTTime QTTimeIncrement(QTTime time, QTTime increment);
QTTime QTTimeDecrement(QTTime time, QTTime decrement);
NSString *QTStringFromTime(QTTime time);
QTTime QTTimeFromString(NSString *string);
BOOL QTTimeIsIndefinite(QTTime time);
QTTimeRange QTMakeTimeRange(QTTime time, QTTime duration);
BOOL QTTimeInTimeRange(QTTime time, QTTimeRange range);
BOOL QTEqualTimeRanges(QTTimeRange range, QTTimeRange range2);
QTTime QTTimeRangeEnd(QTTimeRange range);
QTTimeRange QTUnionTimeRange(QTTimeRange range1, QTTimeRange range2);
QTTimeRange QTIntersectionTimeRange(QTTimeRange range1, QTTimeRange range2);
NSString *QTStringFromTimeRange(QTTimeRange range);

// Conversions to and from CoreMedia time.
CMTime HSCMTimeFromQTTime(QTTime time);
QTTime HSQTTimeFromCMTime(CMTime time);
CMTimeRange HSCMTimeRangeFromQTTimeRange(QTTimeRange range);
QTTimeRange HSQTTimeRangeFromCMTimeRange(CMTimeRange range);

@interface NSValue (NSValueQTTimeExtensions)
+ (NSValue *)valueWithQTTime:(QTTime)time;
+ (NSValue *)valueWithQTTimeRange:(QTTimeRange)range;
- (QTTime)QTTimeValue;
- (QTTimeRange)QTTimeRangeValue;
@end

@interface NSCoder (NSCoderQTTimeExtensions)
- (void)encodeQTTime:(QTTime)time forKey:(NSString *)key;
- (QTTime)decodeQTTimeForKey:(NSString *)key;
@end

// ---- errors and media types

extern NSString * const QTKitErrorDomain;
extern NSString * const QTErrorCaptureInputKey;
extern NSString * const QTErrorCaptureOutputKey;
extern NSString * const QTErrorDeviceKey;
extern NSString * const QTErrorExcludingDeviceKey;
extern NSString * const QTErrorTimeKey;
extern NSString * const QTErrorFileSizeKey;
extern NSString * const QTErrorRecordingSuccesfullyFinishedKey;

enum {
    QTErrorUnknown = -1,
    QTErrorIncompatibleInput = 1002,
    QTErrorIncompatibleOutput = 1003,
    QTErrorInvalidInputsOrOutputs = 1100,
    QTErrorDeviceAlreadyUsedbyAnotherSession = 1101,
    QTErrorNoDataCaptured = 1200,
    QTErrorSessionConfigurationChanged = 1201,
    QTErrorDiskFull = 1202,
    QTErrorDeviceWasDisconnected = 1203,
    QTErrorMediaChanged = 1204,
    QTErrorMaximumDurationReached = 1205,
    QTErrorMaximumFileSizeReached = 1206,
    QTErrorMediaDiscontinuity = 1207,
    QTErrorMaximumNumberOfSamplesForFileFormatReached = 1208,
    QTErrorDeviceNotConnected = 1300,
    QTErrorDeviceInUseByAnotherApplication = 1301,
    QTErrorDeviceExcludedByAnotherDevice = 1302
};

extern NSString * const QTMediaTypeVideo;
extern NSString * const QTMediaTypeSound;
extern NSString * const QTMediaTypeText;
extern NSString * const QTMediaTypeBase;
extern NSString * const QTMediaTypeMPEG;
extern NSString * const QTMediaTypeMusic;
extern NSString * const QTMediaTypeTimeCode;
extern NSString * const QTMediaTypeSprite;
extern NSString * const QTMediaTypeFlash;
extern NSString * const QTMediaTypeMovie;
extern NSString * const QTMediaTypeTween;
extern NSString * const QTMediaType3D;
extern NSString * const QTMediaTypeSkin;
extern NSString * const QTMediaTypeQTVR;
extern NSString * const QTMediaTypeHint;
extern NSString * const QTMediaTypeStream;
extern NSString * const QTMediaTypeMuxed;
extern NSString * const QTMediaTypeQuartzComposer;

// AVFoundation's media type for a QTKit one and back.
NSString *HSAVMediaTypeFromQTMediaType(NSString *type);
NSString *HSQTMediaTypeFromAVMediaType(NSString *type);

// ---- QTDataReference

extern NSString * const QTDataReferenceTypeFile;
extern NSString * const QTDataReferenceTypeHandle;
extern NSString * const QTDataReferenceTypePointer;
extern NSString * const QTDataReferenceTypeResource;
extern NSString * const QTDataReferenceTypeURL;

@interface QTDataReference : NSObject <NSCoding>
{
    NSString *_type;
    NSURL *_url;
    NSData *_data;
    NSString *_name;
    NSString *_mimeType;
}
+ (id)dataReferenceWithReferenceToFile:(NSString *)fileName;
+ (id)dataReferenceWithReferenceToURL:(NSURL *)url;
+ (id)dataReferenceWithReferenceToData:(NSData *)data;
+ (id)dataReferenceWithReferenceToData:(NSData *)data name:(NSString *)name MIMEType:(NSString *)MIMEType;
- (id)initWithReferenceToFile:(NSString *)fileName;
- (id)initWithReferenceToURL:(NSURL *)url;
- (id)initWithReferenceToData:(NSData *)data;
- (id)initWithReferenceToData:(NSData *)data name:(NSString *)name MIMEType:(NSString *)MIMEType;
- (NSString *)dataRefType;
- (NSString *)referenceFile;
- (NSURL *)referenceURL;
- (NSData *)referenceData;
- (NSString *)name;
- (NSString *)MIMEType;
- (void)setName:(NSString *)name;
- (void)setMIMEType:(NSString *)MIMEType;
@end

// ---- QTMovie

extern NSString * const QTMoviePasteboardType;
extern NSString * const QTMovieEditabilityDidChangeNotification;
extern NSString * const QTMovieEditedNotification;
extern NSString * const QTMovieLoadStateDidChangeNotification;
extern NSString * const QTMovieRateDidChangeNotification;
extern NSString * const QTMovieSelectionDidChangeNotification;
extern NSString * const QTMovieSizeDidChangeNotification;
extern NSString * const QTMovieStatusStringPostedNotification;
extern NSString * const QTMovieTimeDidChangeNotification;
extern NSString * const QTMovieVolumeDidChangeNotification;
extern NSString * const QTMovieDidEndNotification;
extern NSString * const QTMovieRateDidChangeNotificationParameter;

// initialization attributes
extern NSString * const QTMovieDataReferenceAttribute;
extern NSString * const QTMoviePasteboardAttribute;
extern NSString * const QTMovieDataAttribute;
extern NSString * const QTMovieFileOffsetAttribute;
extern NSString * const QTMovieResolveDataRefsAttribute;
extern NSString * const QTMovieAskUnresolvedDataRefsAttribute;
extern NSString * const QTMovieOpenAsyncOKAttribute;
extern NSString * const QTMovieOpenAsyncRequiredAttribute;
extern NSString * const QTMovieOpenForPlaybackAttribute;
extern NSString * const QTMovieDontInteractWithUserAttribute;
extern NSString * const QTMovieIsActiveAttribute;
// movie attributes
extern NSString * const QTMovieActiveSegmentAttribute;
extern NSString * const QTMovieAutoAlternatesAttribute;
extern NSString * const QTMovieCopyrightAttribute;
extern NSString * const QTMovieCreationTimeAttribute;
extern NSString * const QTMovieCurrentSizeAttribute;
extern NSString * const QTMovieCurrentTimeAttribute;
extern NSString * const QTMovieDataSizeAttribute;
extern NSString * const QTMovieDelegateAttribute;
extern NSString * const QTMovieDisplayNameAttribute;
extern NSString * const QTMovieDontInteractWithUserAttribute;
extern NSString * const QTMovieDurationAttribute;
extern NSString * const QTMovieEditableAttribute;
extern NSString * const QTMovieFileNameAttribute;
extern NSString * const QTMovieHasApertureModeDimensionsAttribute;
extern NSString * const QTMovieHasAudioAttribute;
extern NSString * const QTMovieHasDurationAttribute;
extern NSString * const QTMovieHasVideoAttribute;
extern NSString * const QTMovieIsInteractiveAttribute;
extern NSString * const QTMovieIsLinearAttribute;
extern NSString * const QTMovieIsSteppableAttribute;
extern NSString * const QTMovieLoadStateAttribute;
extern NSString * const QTMovieLoopsAttribute;
extern NSString * const QTMovieLoopsBackAndForthAttribute;
extern NSString * const QTMovieModificationTimeAttribute;
extern NSString * const QTMovieMutedAttribute;
extern NSString * const QTMovieNaturalSizeAttribute;
extern NSString * const QTMoviePlaysAllFramesAttribute;
extern NSString * const QTMoviePlaysSelectionOnlyAttribute;
extern NSString * const QTMoviePosterTimeAttribute;
extern NSString * const QTMoviePreferredMutedAttribute;
extern NSString * const QTMoviePreferredRateAttribute;
extern NSString * const QTMoviePreferredVolumeAttribute;
extern NSString * const QTMoviePreviewModeAttribute;
extern NSString * const QTMoviePreviewRangeAttribute;
extern NSString * const QTMovieRateAttribute;
extern NSString * const QTMovieSelectionAttribute;
extern NSString * const QTMovieTimeScaleAttribute;
extern NSString * const QTMovieURLAttribute;
extern NSString * const QTMovieVolumeAttribute;
extern NSString * const QTMovieRateChangesPreservePitchAttribute;
// writeToFile:withAttributes:
extern NSString * const QTMovieExport;
extern NSString * const QTMovieExportType;
extern NSString * const QTMovieExportManufacturer;
extern NSString * const QTMovieExportSettings;
extern NSString * const QTMovieFlatten;
extern NSString * const QTMovieExportSettings;
// addImage:forDuration:withAttributes:
extern NSString * const QTAddImageCodecType;
extern NSString * const QTAddImageCodecQuality;
// frameImageAtTime:withAttributes:error:
extern NSString * const QTMovieFrameImageSize;
extern NSString * const QTMovieFrameImageType;
extern NSString * const QTMovieFrameImageTypeNSImage;
extern NSString * const QTMovieFrameImageTypeCGImageRef;
extern NSString * const QTMovieFrameImageTypeCIImage;
extern NSString * const QTMovieFrameImageTypeCVPixelBufferRef;
extern NSString * const QTMovieFrameImageTypeCVOpenGLTextureRef;
extern NSString * const QTMovieFrameImageOpenGLContext;
extern NSString * const QTMovieFrameImagePixelFormat;
extern NSString * const QTMovieFrameImageRepresentationsType;
extern NSString * const QTMovieFrameImageDeinterlaceFields;
extern NSString * const QTMovieFrameImageHighQuality;
extern NSString * const QTMovieFrameImageSingleField;
extern NSString * const QTMovieFrameImageSessionMode;

// codec qualities for QTAddImageCodecQuality (QuickTime's)
enum {
    codecMinQuality = 0x000,
    codecLowQuality = 0x100,
    codecNormalQuality = 0x200,
    codecHighQuality = 0x300,
    codecMaxQuality = 0x3FF,
    codecLosslessQuality = 0x400
};

typedef NSUInteger QTMovieFileTypeOptions;
enum {
    QTIncludeStillImageTypes = 1 << 0,
    QTIncludeTranslatableTypes = 1 << 1,
    QTIncludeAggressiveTypes = 1 << 2,
    QTIncludeCommonTypes = 0,
    QTIncludeAllTypes = 0xffff
};

typedef NSInteger QTMovieLoadState;
enum {
    QTMovieLoadStateError = -1L,
    QTMovieLoadStateLoading = 1000,
    QTMovieLoadStateLoaded = 2000,
    QTMovieLoadStatePlayable = 10000,
    QTMovieLoadStatePlaythroughOK = 20000,
    QTMovieLoadStateComplete = 100000L
};

@class QTTrack;

@interface QTMovie : NSObject <NSCoding, NSCopying>
{
    AVMutableMovie *_asset;
    AVPlayer *_player;
    AVPlayerItem *_item;                // nil when the movie changed since it was made
    AVAssetImageGenerator *_imageGenerator;
    NSURL *_url;                        // the file the movie was read from or is saved to
    NSMutableDictionary *_attributes;   // attributes with no AVFoundation counterpart
    NSMutableArray *_tempURLs;          // files this movie made and deletes
    AVMutableMovieTrack *_imageTrack;   // the track addImage:: appends to
    void *_imageSession;                // its VTCompressionSessionRef
    CGSize _imageSize;
    OSType _imageCodec;
    QTTimeRange _selection;
    CMTime _seekTarget;                 // currentTime while a seek is pending
    int _seeks;
    float _preferredRate;
    float _volume;
    BOOL _muted;
    BOOL _editable;
    BOOL _loops;
    BOOL _observingRate;
    id _delegate;
}
+ (BOOL)canInitWithPasteboard:(NSPasteboard *)pasteboard;
+ (BOOL)canInitWithFile:(NSString *)fileName;
+ (BOOL)canInitWithURL:(NSURL *)url;
+ (BOOL)canInitWithDataReference:(QTDataReference *)dataReference;
+ (NSArray *)movieFileTypes:(QTMovieFileTypeOptions)types;
+ (NSArray *)movieUnfilteredFileTypes;
+ (NSArray *)movieUnfilteredPasteboardTypes;
+ (NSArray *)movieTypesWithOptions:(QTMovieFileTypeOptions)types;
+ (id)movie;
+ (id)movieWithFile:(NSString *)fileName error:(NSError **)errorPtr;
+ (id)movieWithURL:(NSURL *)url error:(NSError **)errorPtr;
+ (id)movieWithDataReference:(QTDataReference *)dataReference error:(NSError **)errorPtr;
+ (id)movieWithPasteboard:(NSPasteboard *)pasteboard error:(NSError **)errorPtr;
+ (id)movieWithData:(NSData *)data error:(NSError **)errorPtr;
+ (id)movieWithAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
+ (id)movieWithQuickTimeMovie:(void *)movie disposeWhenDone:(BOOL)dispose error:(NSError **)errorPtr;
+ (id)movieNamed:(NSString *)name error:(NSError **)errorPtr;
+ (void)enterQTKitOnThread;
+ (void)enterQTKitOnThreadDisablingThreadSafetyProtection;
+ (void)exitQTKitOnThread;
- (id)initWithFile:(NSString *)fileName error:(NSError **)errorPtr;
- (id)initWithURL:(NSURL *)url error:(NSError **)errorPtr;
- (id)initWithDataReference:(QTDataReference *)dataReference error:(NSError **)errorPtr;
- (id)initWithPasteboard:(NSPasteboard *)pasteboard error:(NSError **)errorPtr;
- (id)initWithData:(NSData *)data error:(NSError **)errorPtr;
- (id)initWithAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
- (id)initWithQuickTimeMovie:(void *)movie disposeWhenDone:(BOOL)dispose error:(NSError **)errorPtr;
- (id)initWithMovie:(QTMovie *)movie timeRange:(QTTimeRange)range error:(NSError **)errorPtr;
- (id)initToWritableFile:(NSString *)filename error:(NSError **)errorPtr;
- (id)initToWritableData:(NSMutableData *)data error:(NSError **)errorPtr;
- (id)movieWithTimeRange:(QTTimeRange)range error:(NSError **)errorPtr;
- (BOOL)attachToCurrentThread;
- (BOOL)detachFromCurrentThread;
- (void)setIdling:(BOOL)state;
- (BOOL)isIdling;
// time
- (QTTime)currentTime;
- (void)setCurrentTime:(QTTime)time;
- (QTTime)duration;
- (void)gotoBeginning;
- (void)gotoEnd;
- (void)gotoNextSelectionPoint;
- (void)gotoPreviousSelectionPoint;
- (void)gotoPosterTime;
- (void)stepForward;
- (void)stepBackward;
// playback
- (void)play;
- (void)stop;
- (float)rate;
- (void)setRate:(float)rate;
- (float)volume;
- (void)setVolume:(float)volume;
- (BOOL)muted;
- (void)setMuted:(BOOL)mute;
// selection
- (void)setSelection:(QTTimeRange)selection;
- (QTTime)selectionStart;
- (QTTime)selectionEnd;
- (QTTime)selectionDuration;
// attributes
- (NSDictionary *)movieAttributes;
- (void)setMovieAttributes:(NSDictionary *)attributes;
- (id)attributeForKey:(NSString *)attributeKey;
- (void)setAttribute:(id)value forKey:(NSString *)attributeKey;
// tracks
- (NSArray *)tracks;
- (NSArray *)tracksOfMediaType:(NSString *)type;
// images
- (NSImage *)posterImage;
- (NSImage *)currentFrameImage;
- (NSImage *)frameImageAtTime:(QTTime)time;
- (void *)frameImageAtTime:(QTTime)time withAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
// formats and writing
- (NSData *)movieFormatRepresentation;
- (BOOL)writeToFile:(NSString *)fileName withAttributes:(NSDictionary *)attributes;
- (BOOL)writeToFile:(NSString *)fileName withAttributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
- (BOOL)canUpdateMovieFile;
- (BOOL)updateMovieFile;
// editing
- (void)replaceSelectionWithSelectionFromMovie:(id)movie;
- (void)appendSelectionFromMovie:(id)movie;
- (void)insertSegmentOfMovie:(QTMovie *)movie timeRange:(QTTimeRange)range atTime:(QTTime)time;
- (void)insertSegmentOfMovie:(QTMovie *)movie fromRange:(QTTimeRange)srcRange scaledToRange:(QTTimeRange)dstRange;
- (void)insertEmptySegmentAt:(QTTimeRange)range;
- (void)deleteSegment:(QTTimeRange)segment;
- (void)scaleSegment:(QTTimeRange)segment newDuration:(QTTime)newDuration;
- (void)addImage:(NSImage *)image forDuration:(QTTime)duration withAttributes:(NSDictionary *)attributes;
- (QTTrack *)insertSegmentOfTrack:(QTTrack *)track timeRange:(QTTimeRange)range atTime:(QTTime)time;
- (void)removeTrack:(QTTrack *)track;
// delegate
- (id)delegate;
- (void)setDelegate:(id)delegate;
// no QuickTime any more: these return NULL
- (void *)quickTimeMovie;
- (void *)quickTimeMovieController;
// AVFoundation access
- (AVAsset *)AVAsset;
- (AVPlayer *)AVPlayer;
- (AVPlayerItem *)AVPlayerItem;
@end

// ---- QTTrack and QTMedia

extern NSString * const QTTrackBoundsAttribute;
extern NSString * const QTTrackCreationTimeAttribute;
extern NSString * const QTTrackDimensionsAttribute;
extern NSString * const QTTrackDisplayNameAttribute;
extern NSString * const QTTrackEnabledAttribute;
extern NSString * const QTTrackFormatSummaryAttribute;
extern NSString * const QTTrackIsChapterTrackAttribute;
extern NSString * const QTTrackHasApertureModeDimensionsAttribute;
extern NSString * const QTTrackIDAttribute;
extern NSString * const QTTrackLayerAttribute;
extern NSString * const QTTrackMediaTypeAttribute;
extern NSString * const QTTrackModificationTimeAttribute;
extern NSString * const QTTrackRangeAttribute;
extern NSString * const QTTrackTimeScaleAttribute;
extern NSString * const QTTrackUsageInMovieAttribute;
extern NSString * const QTTrackUsageInPosterAttribute;
extern NSString * const QTTrackUsageInPreviewAttribute;
extern NSString * const QTTrackVolumeAttribute;

extern NSString * const QTMediaCharacteristicVisual;
extern NSString * const QTMediaCharacteristicAudio;
extern NSString * const QTMediaCharacteristicCanSendVideo;
extern NSString * const QTMediaCharacteristicProvidesActions;
extern NSString * const QTMediaCharacteristicNonLinear;
extern NSString * const QTMediaCharacteristicCanStep;
extern NSString * const QTMediaCharacteristicHasNoDuration;
extern NSString * const QTMediaCharacteristicHasSkinData;
extern NSString * const QTMediaCharacteristicProvidesKeyFocus;
extern NSString * const QTMediaCharacteristicHasVideoFrameRate;

extern NSString * const QTMediaDurationAttribute;
extern NSString * const QTMediaSampleCountAttribute;
extern NSString * const QTMediaTimeScaleAttribute;
extern NSString * const QTMediaTypeAttribute;

@class QTMedia;

@interface QTTrack : NSObject
{
    QTMovie *_movie;            // not retained: the movie owns its tracks
    AVAssetTrack *_track;
    BOOL _enabled;
    float _volume;
}
+ (id)trackWithQuickTimeTrack:(void *)track error:(NSError **)errorPtr;
- (id)initWithQuickTimeTrack:(void *)track error:(NSError **)errorPtr;
- (id)initWithMovie:(QTMovie *)movie assetTrack:(AVAssetTrack *)track;
- (QTMovie *)movie;
- (QTMedia *)media;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (float)volume;
- (void)setVolume:(float)volume;
- (NSDictionary *)trackAttributes;
- (void)setTrackAttributes:(NSDictionary *)attributes;
- (id)attributeForKey:(NSString *)attributeKey;
- (void)setAttribute:(id)value forKey:(NSString *)attributeKey;
- (void *)quickTimeTrack;
- (void)insertSegmentOfTrack:(QTTrack *)track timeRange:(QTTimeRange)range atTime:(QTTime)time;
- (void)insertEmptySegmentAt:(QTTimeRange)range;
- (void)deleteSegment:(QTTimeRange)segment;
- (void)scaleSegment:(QTTimeRange)segment newDuration:(QTTime)newDuration;
- (void)addImage:(NSImage *)image forDuration:(QTTime)duration withAttributes:(NSDictionary *)attributes;
- (AVAssetTrack *)AVAssetTrack;
@end

@interface QTMedia : NSObject
{
    QTTrack *_track;
}
+ (id)mediaWithQuickTimeMedia:(void *)media error:(NSError **)errorPtr;
- (id)initWithTrack:(QTTrack *)track;
- (QTTrack *)track;
- (id)attributeForKey:(NSString *)attributeKey;
- (NSDictionary *)mediaAttributes;
- (BOOL)hasCharacteristic:(NSString *)characteristic;
- (void *)quickTimeMedia;
@end

// ---- QTMovieView

@interface QTMovieView : NSView
{
    QTMovie *_movie;
    NSView *_playerView;        // an AVPlayerView
    NSColor *_fillColor;
    id _delegate;
    BOOL _controllerVisible;
    BOOL _preservesAspectRatio;
    BOOL _editable;
    BOOL _showsResizeIndicator;
    BOOL _backButtonVisible;
    BOOL _customButtonVisible;
    BOOL _hotSpotButtonVisible;
    BOOL _stepButtonsVisible;
    BOOL _translateButtonVisible;
    BOOL _volumeButtonVisible;
    BOOL _zoomButtonsVisible;
}
- (QTMovie *)movie;
- (void)setMovie:(QTMovie *)movie;
- (NSRect)movieBounds;
- (NSRect)movieControllerBounds;
- (NSColor *)fillColor;
- (void)setFillColor:(NSColor *)fillColor;
- (BOOL)isControllerVisible;
- (void)setControllerVisible:(BOOL)controllerVisible;
- (BOOL)preservesAspectRatio;
- (void)setPreservesAspectRatio:(BOOL)preservesAspectRatio;
- (BOOL)isEditable;
- (void)setEditable:(BOOL)editable;
- (void)setShowsResizeIndicator:(BOOL)show;
- (BOOL)isBackButtonVisible;
- (void)setBackButtonVisible:(BOOL)state;
- (BOOL)isCustomButtonVisible;
- (void)setCustomButtonVisible:(BOOL)state;
- (BOOL)isHotSpotButtonVisible;
- (void)setHotSpotButtonVisible:(BOOL)state;
- (BOOL)areStepButtonsVisible;
- (void)setStepButtonsVisible:(BOOL)state;
- (BOOL)isTranslateButtonVisible;
- (void)setTranslateButtonVisible:(BOOL)state;
- (BOOL)isVolumeButtonVisible;
- (void)setVolumeButtonVisible:(BOOL)state;
- (BOOL)areZoomButtonsVisible;
- (void)setZoomButtonsVisible:(BOOL)state;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)gotoBeginning:(id)sender;
- (IBAction)gotoEnd:(id)sender;
- (IBAction)gotoNextSelectionPoint:(id)sender;
- (IBAction)gotoPreviousSelectionPoint:(id)sender;
- (IBAction)gotoPosterFrame:(id)sender;
- (IBAction)stepForward:(id)sender;
- (IBAction)stepBackward:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)selectNone:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)addScaled:(id)sender;
- (IBAction)replace:(id)sender;
- (IBAction)trim:(id)sender;
@end

// ---- QTCompressionOptions

@interface QTCompressionOptions : NSObject
{
    NSString *_identifier;
    NSString *_mediaType;
    NSDictionary *_settings;    // AVFoundation output settings
}
+ (NSArray *)compressionOptionsIdentifiersForMediaType:(NSString *)mediaType;
+ (id)compressionOptionsWithIdentifier:(NSString *)identifier;
- (NSString *)mediaType;
- (NSString *)localizedDisplayName;
- (NSString *)localizedCompressionOptionsSummary;
- (BOOL)isEqualToCompressionOptions:(QTCompressionOptions *)compressionOptions;
- (NSString *)identifier;
// the AVAssetWriterInput / AVCaptureMovieFileOutput output settings
- (NSDictionary *)AVOutputSettings;
@end

// ---- QTFormatDescription

extern NSString * const QTFormatDescriptionAudioStreamBasicDescriptionAttribute;
extern NSString * const QTFormatDescriptionAudioMagicCookieAttribute;
extern NSString * const QTFormatDescriptionAudioChannelLayoutAttribute;
extern NSString * const QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute;
extern NSString * const QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute;
extern NSString * const QTFormatDescriptionVideoEncodedPixelsSizeAttribute;

@interface QTFormatDescription : NSObject
{
    CMFormatDescriptionRef _description;
}
- (id)initWithCMFormatDescription:(CMFormatDescriptionRef)description;
- (NSString *)mediaType;
- (UInt32)formatType;
- (NSString *)localizedFormatSummary;
- (NSData *)quickTimeSampleDescription;
- (NSDictionary *)formatDescriptionAttributes;
- (id)attributeForKey:(NSString *)key;
- (BOOL)isEqualToFormatDescription:(QTFormatDescription *)formatDescription;
- (CMFormatDescriptionRef)CMFormatDescription;
@end

// ---- QTSampleBuffer

extern NSString * const QTSampleBufferSMPTETimeAttribute;
extern NSString * const QTSampleBufferDateRecordedAttribute;
extern NSString * const QTSampleBufferHostTimeAttribute;
extern NSString * const QTSampleBufferSceneChangeTypeAttribute;
extern NSString * const QTSampleBufferExplicitSceneChange;
extern NSString * const QTSampleBufferTimeStampDiscontinuitySceneChange;

enum { QTSampleBufferAudioBufferListOptionAssure16ByteAlignment = 1 << 0 };

@interface QTSampleBuffer : NSObject
{
    CMSampleBufferRef _buffer;
    AVCaptureConnection *_connection;   // for the host time of its samples
    NSData *_contiguous;                // bytesForAllSamples of a scattered buffer
    QTFormatDescription *_formatDescription;
}
- (id)initWithCMSampleBuffer:(CMSampleBufferRef)buffer connection:(AVCaptureConnection *)connection;
- (void *)bytesForAllSamples;
- (NSUInteger)lengthForAllSamples;
- (QTFormatDescription *)formatDescription;
- (QTTime)duration;
- (QTTime)decodeTime;
- (QTTime)presentationTime;
- (NSInteger)numberOfSamples;
- (NSDictionary *)sampleBufferAttributes;
- (id)attributeForKey:(NSString *)key;
- (void)incrementSampleUseCount;
- (void)decrementSampleUseCount;
- (AudioBufferList *)audioBufferListWithOptions:(NSUInteger)options;
- (OSStatus)getAudioStreamPacketDescriptions:(void *)audioStreamPacketDescriptions inRange:(NSRange)range;
- (OSStatus)getAudioStreamPacketDescriptionsPtr:(void **)outAudioStreamPacketDescriptionsPtr;
- (CMSampleBufferRef)CMSampleBuffer;
@end

// ---- capture

extern NSString * const QTCaptureDeviceWasConnectedNotification;
extern NSString * const QTCaptureDeviceWasDisconnectedNotification;
extern NSString * const QTCaptureDeviceFormatDescriptionsWillChangeNotification;
extern NSString * const QTCaptureDeviceFormatDescriptionsDidChangeNotification;
extern NSString * const QTCaptureDeviceAttributeWillChangeNotification;
extern NSString * const QTCaptureDeviceAttributeDidChangeNotification;
extern NSString * const QTCaptureDeviceChangedAttributeKey;
extern NSString * const QTCaptureDeviceLinkedDevicesAttribute;
extern NSString * const QTCaptureDeviceAvailableInputSourcesAttribute;
extern NSString * const QTCaptureDeviceInputSourceIdentifierAttribute;
extern NSString * const QTCaptureDeviceInputSourceIdentifierKey;
extern NSString * const QTCaptureDeviceInputSourceLocalizedDisplayNameKey;
extern NSString * const QTCaptureDeviceLegacySequenceGrabberAttribute;
extern NSString * const QTCaptureDeviceAVCTransportControlsAttribute;
extern NSString * const QTCaptureDeviceAVCTransportControlsPlaybackModeKey;
extern NSString * const QTCaptureDeviceAVCTransportControlsSpeedKey;
extern NSString * const QTCaptureDeviceSuspendedAttribute;

extern NSString * const QTCaptureSessionRuntimeErrorNotification;
extern NSString * const QTCaptureSessionErrorKey;

extern NSString * const QTCaptureConnectionFormatDescriptionWillChangeNotification;
extern NSString * const QTCaptureConnectionFormatDescriptionDidChangeNotification;
extern NSString * const QTCaptureConnectionAttributeWillChangeNotification;
extern NSString * const QTCaptureConnectionAttributeDidChangeNotification;
extern NSString * const QTCaptureConnectionChangedAttributeKey;
extern NSString * const QTCaptureConnectionAudioAveragePowerLevelsAttribute;
extern NSString * const QTCaptureConnectionAudioPeakHoldLevelsAttribute;
extern NSString * const QTCaptureConnectionAudioMasterVolumeAttribute;
extern NSString * const QTCaptureConnectionAudioVolumesAttribute;
extern NSString * const QTCaptureConnectionEnabledAudioChannelsAttribute;

@class QTCaptureSession, QTCaptureConnection;

@interface QTCaptureDevice : NSObject <NSCoding>
{
    AVCaptureDevice *_device;
    NSInteger _openCount;
}
+ (NSArray *)inputDevices;
+ (NSArray *)inputDevicesWithMediaType:(NSString *)mediaType;
+ (QTCaptureDevice *)defaultInputDeviceWithMediaType:(NSString *)mediaType;
+ (QTCaptureDevice *)deviceWithUniqueID:(NSString *)deviceUniqueID;
// the one QTCaptureDevice for an AVCaptureDevice
+ (QTCaptureDevice *)deviceWithAVCaptureDevice:(AVCaptureDevice *)device;
- (NSString *)uniqueID;
- (NSString *)modelUniqueID;
- (NSString *)localizedDisplayName;
- (NSArray *)formatDescriptions;
- (BOOL)hasMediaType:(NSString *)mediaType;
- (NSDictionary *)deviceAttributes;
- (void)setDeviceAttributes:(NSDictionary *)deviceAttributes;
- (BOOL)attributeIsReadOnly:(NSString *)attributeKey;
- (id)attributeForKey:(NSString *)attributeKey;
- (void)setAttribute:(id)attribute forKey:(NSString *)attributeKey;
- (BOOL)isConnected;
// key-value observable, as QTKit's were
- (BOOL)isInUseByAnotherApplication;
- (BOOL)isSuspended;
- (BOOL)isOpen;
- (BOOL)open:(NSError **)errorPtr;
- (void)close;
- (AVCaptureDevice *)AVCaptureDevice;
@end

@interface QTCaptureConnection : NSObject
{
    id _owner;                          // not retained
    AVCaptureInputPort *_port;          // for an input's connection
    AVCaptureConnection *_connection;   // for an output's connection
    NSMutableDictionary *_attributes;
}
- (id)initWithOwner:(id)owner inputPort:(AVCaptureInputPort *)port;
- (id)initWithOwner:(id)owner connection:(AVCaptureConnection *)connection;
- (id)owner;
- (NSString *)mediaType;
- (QTFormatDescription *)formatDescription;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (NSDictionary *)connectionAttributes;
- (void)setConnectionAttributes:(NSDictionary *)connectionAttributes;
- (BOOL)attributeIsReadOnly:(NSString *)attributeKey;
- (id)attributeForKey:(NSString *)attributeKey;
- (void)setAttribute:(id)attribute forKey:(NSString *)attributeKey;
- (AVCaptureInputPort *)AVCaptureInputPort;
- (AVCaptureConnection *)AVCaptureConnection;
@end

@interface QTCaptureInput : NSObject
{
@public
    QTCaptureSession *_session;     // not retained
}
- (NSArray *)connections;
@end

@interface QTCaptureDeviceInput : QTCaptureInput
{
    QTCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    NSMutableArray *_connections;
}
+ (id)deviceInputWithDevice:(QTCaptureDevice *)device;
- (id)initWithDevice:(QTCaptureDevice *)device;
- (QTCaptureDevice *)device;
- (AVCaptureDeviceInput *)AVCaptureInput;
@end

@interface QTCaptureOutput : NSObject
{
    QTCaptureSession *_session;     // not retained
    AVCaptureOutput *_output;
    id _bridge;                     // AVFoundation's delegate
    NSMutableArray *_connections;   // QTCaptureConnections of _output's
    id _delegate;
}
- (NSArray *)connections;
- (AVCaptureOutput *)AVCaptureOutput;
// the QTCaptureConnection for one of the output's AVCaptureConnections
- (QTCaptureConnection *)connectionForAVCaptureConnection:(AVCaptureConnection *)connection;
@end

typedef NSUInteger QTCaptureFileOutputBufferDestination;
enum {
    QTCaptureFileOutputBufferDestinationNewFile = 1,
    QTCaptureFileOutputBufferDestinationOldFile = 2
};

@interface QTCaptureFileOutput : QTCaptureOutput
{
    NSURL *_outputFileURL;
    NSMutableDictionary *_compressionOptions;  // connection -> options
    QTTime _maximumRecordedDuration;
    UInt64 _maximumRecordedFileSize;
    BOOL _paused;
}
- (NSURL *)outputFileURL;
- (void)recordToOutputFileURL:(NSURL *)url;
- (void)recordToOutputFileURL:(NSURL *)url bufferDestination:(QTCaptureFileOutputBufferDestination)bufferDestination;
- (BOOL)isRecordingPaused;
- (void)pauseRecording;
- (void)resumeRecording;
- (QTCompressionOptions *)compressionOptionsForConnection:(QTCaptureConnection *)connection;
- (void)setCompressionOptions:(QTCompressionOptions *)compressionOptions forConnection:(QTCaptureConnection *)connection;
- (QTTime)maximumRecordedDuration;
- (void)setMaximumRecordedDuration:(QTTime)maximumRecordedDuration;
- (UInt64)maximumRecordedFileSize;
- (void)setMaximumRecordedFileSize:(UInt64)maximumRecordedFileSize;
- (QTTime)recordedDuration;
- (UInt64)recordedFileSize;
- (id)delegate;
- (void)setDelegate:(id)delegate;
@end

@interface QTCaptureMovieFileOutput : QTCaptureFileOutput
- (id)init;
@end

@interface NSObject (QTCaptureFileOutputDelegate)
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
- (BOOL)captureOutput:(QTCaptureFileOutput *)captureOutput shouldChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput mustChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections;
@end

@interface QTCaptureDecompressedVideoOutput : QTCaptureOutput
{
    NSDictionary *_pixelBufferAttributes;
    NSTimeInterval _minimumVideoFrameInterval;
    NSTimeInterval _lastFrameTime;
    dispatch_queue_t _queue;
}
- (NSDictionary *)pixelBufferAttributes;
- (void)setPixelBufferAttributes:(NSDictionary *)pixelBufferAttributes;
- (NSTimeInterval)minimumVideoFrameInterval;
- (void)setMinimumVideoFrameInterval:(NSTimeInterval)minimumVideoFrameInterval;
- (BOOL)automaticallyDropsLateVideoFrames;
- (void)setAutomaticallyDropsLateVideoFrames:(BOOL)automaticallyDropsLateVideoFrames;
- (void)outputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
- (id)delegate;
- (void)setDelegate:(id)delegate;
@end

@interface NSObject (QTCaptureDecompressedVideoOutputDelegate)
- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
- (void)captureOutput:(QTCaptureOutput *)captureOutput didDropVideoFrameWithSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
@end

@interface QTCaptureVideoPreviewOutput : QTCaptureDecompressedVideoOutput
@end

@interface QTCaptureDecompressedAudioOutput : QTCaptureOutput
{
    dispatch_queue_t _queue;
}
- (void)outputAudioSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
- (id)delegate;
- (void)setDelegate:(id)delegate;
@end

@interface NSObject (QTCaptureDecompressedAudioOutputDelegate)
- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputAudioSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;
@end

@interface QTCaptureAudioPreviewOutput : QTCaptureOutput
- (NSString *)outputDeviceUniqueID;
- (void)setOutputDeviceUniqueID:(NSString *)uniqueID;
- (float)volume;
- (void)setVolume:(float)volume;
@end

@interface QTCaptureSession : NSObject
{
    AVCaptureSession *_session;
    NSMutableArray *_inputs;
    NSMutableArray *_outputs;
    id _errorObserver;
}
- (NSArray *)inputs;
- (BOOL)addInput:(QTCaptureInput *)input error:(NSError **)errorPtr;
- (void)removeInput:(QTCaptureInput *)input;
- (NSArray *)outputs;
- (BOOL)addOutput:(QTCaptureOutput *)output error:(NSError **)errorPtr;
- (void)removeOutput:(QTCaptureOutput *)output;
- (void)startRunning;
- (void)stopRunning;
- (BOOL)isRunning;
- (AVCaptureSession *)AVCaptureSession;
@end

@interface QTCaptureView : NSView
{
    QTCaptureSession *_captureSession;
    QTCaptureConnection *_videoPreviewConnection;
    AVCaptureVideoPreviewLayer *_previewLayer;
    NSColor *_fillColor;
    BOOL _preservesAspectRatio;
    id _delegate;
}
- (QTCaptureSession *)captureSession;
- (void)setCaptureSession:(QTCaptureSession *)captureSession;
- (NSArray *)availableVideoPreviewConnections;
- (QTCaptureConnection *)videoPreviewConnection;
- (void)setVideoPreviewConnection:(QTCaptureConnection *)videoPreviewConnection;
- (NSColor *)fillColor;
- (void)setFillColor:(NSColor *)fillColor;
- (BOOL)preservesAspectRatio;
- (void)setPreservesAspectRatio:(BOOL)preservesAspectRatio;
- (NSRect)previewBounds;
- (id)delegate;
- (void)setDelegate:(id)delegate;
@end

// ---- QuickTime visual contexts (QTVisualContext.m)

typedef struct OpaqueQTVisualContext *QTVisualContextRef;
typedef void (*QTVisualContextImageAvailableCallback)(QTVisualContextRef visualContext, const CVTimeStamp *timeStamp, void *refCon);

extern NSString * const kQTVisualContextPixelBufferAttributesKey;
extern NSString * const kQTVisualContextOutputColorSpaceKey;

OSStatus QTPixelBufferContextCreate(CFAllocatorRef allocator, CFDictionaryRef attributes, QTVisualContextRef *newPixelBufferContext);
OSStatus QTOpenGLTextureContextCreate(CFAllocatorRef allocator, CGLContextObj cglContext, CGLPixelFormatObj cglPixelFormat, CFDictionaryRef attributes, QTVisualContextRef *newTextureContext);
QTVisualContextRef QTVisualContextRetain(QTVisualContextRef visualContext);
void QTVisualContextRelease(QTVisualContextRef visualContext);
OSStatus QTVisualContextSetImageAvailableCallback(QTVisualContextRef visualContext, QTVisualContextImageAvailableCallback imageAvailableCallback, void *refCon);
Boolean QTVisualContextIsNewImageAvailable(QTVisualContextRef visualContext, const CVTimeStamp *timeStamp);
OSStatus QTVisualContextCopyImageForTime(QTVisualContextRef visualContext, CFAllocatorRef allocator, const CVTimeStamp *timeStamp, CVImageBufferRef *newImage);
void QTVisualContextTask(QTVisualContextRef visualContext);
OSStatus SetMovieVisualContext(void *theMovie, QTVisualContextRef visualContext);
