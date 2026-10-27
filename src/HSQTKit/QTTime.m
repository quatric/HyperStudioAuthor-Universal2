#import "HSQTKit.h"

// String constants hold their own names, as QTKit's did.
#define QTSTRING(name) NSString * const name = @#name

const QTTime QTZeroTime = { 0, 1, 0 };
const QTTime QTIndefiniteTime = { 0, 1, kQTTimeIsIndefinite };
const QTTimeRange QTZeroTimeRange = { { 0, 1, 0 }, { 0, 1, 0 } };

QTSTRING(QTKitErrorDomain);
QTSTRING(QTErrorCaptureInputKey);
QTSTRING(QTErrorCaptureOutputKey);
QTSTRING(QTErrorDeviceKey);
QTSTRING(QTErrorExcludingDeviceKey);
QTSTRING(QTErrorTimeKey);
QTSTRING(QTErrorFileSizeKey);
QTSTRING(QTErrorRecordingSuccesfullyFinishedKey);

NSString * const QTMediaTypeVideo = @"vide";
NSString * const QTMediaTypeSound = @"soun";
NSString * const QTMediaTypeText = @"text";
NSString * const QTMediaTypeBase = @"gnrc";
NSString * const QTMediaTypeMPEG = @"MPEG";
NSString * const QTMediaTypeMusic = @"musi";
NSString * const QTMediaTypeTimeCode = @"tmcd";
NSString * const QTMediaTypeSprite = @"sprt";
NSString * const QTMediaTypeFlash = @"flsh";
NSString * const QTMediaTypeMovie = @"moov";
NSString * const QTMediaTypeTween = @"twen";
NSString * const QTMediaType3D = @"qd3d";
NSString * const QTMediaTypeSkin = @"skin";
NSString * const QTMediaTypeQTVR = @"qtvr";
NSString * const QTMediaTypeHint = @"hint";
NSString * const QTMediaTypeStream = @"strm";
NSString * const QTMediaTypeMuxed = @"muxx";
NSString * const QTMediaTypeQuartzComposer = @"qtz";

NSString *HSAVMediaTypeFromQTMediaType(NSString *type)
{
    if ([type isEqualToString:QTMediaTypeVideo]) return AVMediaTypeVideo;
    if ([type isEqualToString:QTMediaTypeSound]) return AVMediaTypeAudio;
    if ([type isEqualToString:QTMediaTypeMuxed]) return AVMediaTypeMuxed;
    if ([type isEqualToString:QTMediaTypeText]) return AVMediaTypeText;
    if ([type isEqualToString:QTMediaTypeTimeCode]) return AVMediaTypeTimecode;
    if ([type isEqualToString:QTMediaTypeMPEG]) return AVMediaTypeMuxed;
    return type;
}

NSString *HSQTMediaTypeFromAVMediaType(NSString *type)
{
    if ([type isEqualToString:AVMediaTypeVideo]) return QTMediaTypeVideo;
    if ([type isEqualToString:AVMediaTypeAudio]) return QTMediaTypeSound;
    if ([type isEqualToString:AVMediaTypeMuxed]) return QTMediaTypeMuxed;
    if ([type isEqualToString:AVMediaTypeText]) return QTMediaTypeText;
    if ([type isEqualToString:AVMediaTypeTimecode]) return QTMediaTypeTimeCode;
    return type;
}

QTTime QTMakeTime(long long timeValue, long timeScale)
{
    QTTime t = { timeValue, timeScale, 0 };
    return t;
}

QTTime QTMakeTimeWithTimeInterval(NSTimeInterval timeInterval)
{
    return QTMakeTime((long long)llround(timeInterval * 600.0), 600);
}

QTTime QTMakeTimeWithTimeRecord(void *timeRecord)
{
    // QuickTime's TimeRecord: { wide value (hi, lo); TimeScale scale; TimeBase base }
    struct { SInt32 hi; UInt32 lo; SInt32 scale; void *base; } *r = timeRecord;
    return QTMakeTime(((long long)r->hi << 32) | r->lo, r->scale);
}

QTTime QTMakeTimeScaled(QTTime time, long timeScale)
{
    if (time.flags & kQTTimeIsIndefinite || time.timeScale == timeScale || !time.timeScale)
        return (QTTime){ time.timeValue, time.timeScale ? timeScale : time.timeScale, time.flags };
    // round half away from zero, without overflowing for long movies
    __int128 v = (__int128)time.timeValue * timeScale;
    __int128 half = time.timeScale / 2;
    v = v >= 0 ? (v + half) / time.timeScale : (v - half) / time.timeScale;
    return (QTTime){ (long long)v, timeScale, time.flags };
}

BOOL QTGetTimeInterval(QTTime time, NSTimeInterval *timeInterval)
{
    if (time.flags & kQTTimeIsIndefinite || !time.timeScale)
        return NO;
    *timeInterval = (double)time.timeValue / time.timeScale;
    return YES;
}

NSComparisonResult QTTimeCompare(QTTime time, QTTime otherTime)
{
    BOOL a = (time.flags & kQTTimeIsIndefinite) != 0, b = (otherTime.flags & kQTTimeIsIndefinite) != 0;
    if (a || b)
        return a == b ? NSOrderedSame : a ? NSOrderedDescending : NSOrderedAscending;
    __int128 x = (__int128)time.timeValue * otherTime.timeScale;
    __int128 y = (__int128)otherTime.timeValue * time.timeScale;
    return x < y ? NSOrderedAscending : x > y ? NSOrderedDescending : NSOrderedSame;
}

QTTime QTTimeIncrement(QTTime time, QTTime increment)
{
    if ((time.flags | increment.flags) & kQTTimeIsIndefinite)
        return QTIndefiniteTime;
    long scale = time.timeScale >= increment.timeScale ? time.timeScale : increment.timeScale;
    time = QTMakeTimeScaled(time, scale);
    increment = QTMakeTimeScaled(increment, scale);
    return QTMakeTime(time.timeValue + increment.timeValue, scale);
}

QTTime QTTimeDecrement(QTTime time, QTTime decrement)
{
    decrement.timeValue = -decrement.timeValue;
    return QTTimeIncrement(time, decrement);
}

BOOL QTTimeIsIndefinite(QTTime time)
{
    return (time.flags & kQTTimeIsIndefinite) != 0;
}

// "D:HH:MM:SS.ff/scale", as QTKit wrote it.
NSString *QTStringFromTime(QTTime time)
{
    if (time.flags & kQTTimeIsIndefinite)
        return @"INDEFINITE";
    long long v = time.timeValue;
    long scale = time.timeScale ? time.timeScale : 1;
    NSString *sign = v < 0 ? @"-" : @"";
    if (v < 0) v = -v;
    long long secs = v / scale, frac = v % scale;
    return [NSString stringWithFormat:@"%@%lld:%02lld:%02lld:%02lld.%0*lld/%ld", sign,
            secs / 86400, secs / 3600 % 24, secs / 60 % 60, secs % 60,
            (int)[[NSString stringWithFormat:@"%ld", scale] length], frac, scale];
}

QTTime QTTimeFromString(NSString *string)
{
    if ([string isEqualToString:@"INDEFINITE"])
        return QTIndefiniteTime;
    long long d = 0, h = 0, m = 0, s = 0, f = 0;
    long scale = 1;
    BOOL negative = [string hasPrefix:@"-"];
    const char *c = [string UTF8String] + (negative ? 1 : 0);
    if (sscanf(c, "%lld:%lld:%lld:%lld.%lld/%ld", &d, &h, &m, &s, &f, &scale) != 6 || scale <= 0)
        return QTZeroTime;
    long long v = (((d * 24 + h) * 60 + m) * 60 + s) * scale + f;
    return QTMakeTime(negative ? -v : v, scale);
}

QTTimeRange QTMakeTimeRange(QTTime time, QTTime duration)
{
    QTTimeRange r = { time, duration };
    return r;
}

QTTime QTTimeRangeEnd(QTTimeRange range)
{
    return QTTimeIncrement(range.time, range.duration);
}

BOOL QTTimeInTimeRange(QTTime time, QTTimeRange range)
{
    return QTTimeCompare(time, range.time) != NSOrderedAscending
        && QTTimeCompare(time, QTTimeRangeEnd(range)) == NSOrderedAscending;
}

BOOL QTEqualTimeRanges(QTTimeRange range, QTTimeRange range2)
{
    return QTTimeCompare(range.time, range2.time) == NSOrderedSame
        && QTTimeCompare(range.duration, range2.duration) == NSOrderedSame;
}

QTTimeRange QTUnionTimeRange(QTTimeRange range1, QTTimeRange range2)
{
    QTTime start = QTTimeCompare(range1.time, range2.time) == NSOrderedAscending ? range1.time : range2.time;
    QTTime end1 = QTTimeRangeEnd(range1), end2 = QTTimeRangeEnd(range2);
    QTTime end = QTTimeCompare(end1, end2) == NSOrderedDescending ? end1 : end2;
    return QTMakeTimeRange(start, QTTimeDecrement(end, start));
}

QTTimeRange QTIntersectionTimeRange(QTTimeRange range1, QTTimeRange range2)
{
    QTTime start = QTTimeCompare(range1.time, range2.time) == NSOrderedDescending ? range1.time : range2.time;
    QTTime end1 = QTTimeRangeEnd(range1), end2 = QTTimeRangeEnd(range2);
    QTTime end = QTTimeCompare(end1, end2) == NSOrderedAscending ? end1 : end2;
    if (QTTimeCompare(end, start) != NSOrderedDescending)
        return QTMakeTimeRange(start, QTMakeTime(0, start.timeScale));
    return QTMakeTimeRange(start, QTTimeDecrement(end, start));
}

NSString *QTStringFromTimeRange(QTTimeRange range)
{
    return [NSString stringWithFormat:@"%@~%@", QTStringFromTime(range.time), QTStringFromTime(range.duration)];
}

CMTime HSCMTimeFromQTTime(QTTime time)
{
    if (time.flags & kQTTimeIsIndefinite)
        return kCMTimeIndefinite;
    return CMTimeMake(time.timeValue, (int32_t)(time.timeScale ? time.timeScale : 600));
}

QTTime HSQTTimeFromCMTime(CMTime time)
{
    if (!CMTIME_IS_NUMERIC(time))
        return QTIndefiniteTime;
    return QTMakeTime(time.value, time.timescale);
}

CMTimeRange HSCMTimeRangeFromQTTimeRange(QTTimeRange range)
{
    return CMTimeRangeMake(HSCMTimeFromQTTime(range.time), HSCMTimeFromQTTime(range.duration));
}

QTTimeRange HSQTTimeRangeFromCMTimeRange(CMTimeRange range)
{
    return QTMakeTimeRange(HSQTTimeFromCMTime(range.start), HSQTTimeFromCMTime(range.duration));
}

@implementation NSValue (NSValueQTTimeExtensions)

+ (NSValue *)valueWithQTTime:(QTTime)time
{
    return [NSValue valueWithBytes:&time objCType:@encode(QTTime)];
}

+ (NSValue *)valueWithQTTimeRange:(QTTimeRange)range
{
    return [NSValue valueWithBytes:&range objCType:@encode(QTTimeRange)];
}

- (QTTime)QTTimeValue
{
    QTTime t = QTZeroTime;
    if (!strcmp([self objCType], @encode(QTTime)))
        [self getValue:&t];
    return t;
}

- (QTTimeRange)QTTimeRangeValue
{
    QTTimeRange r = QTZeroTimeRange;
    if (!strcmp([self objCType], @encode(QTTimeRange)))
        [self getValue:&r];
    return r;
}

@end

@implementation NSCoder (NSCoderQTTimeExtensions)

- (void)encodeQTTime:(QTTime)time forKey:(NSString *)key
{
    [self encodeObject:QTStringFromTime(time) forKey:key];
}

- (QTTime)decodeQTTimeForKey:(NSString *)key
{
    return QTTimeFromString([self decodeObjectForKey:key]);
}

@end

// ---- QTDataReference

QTSTRING(QTDataReferenceTypeFile);
QTSTRING(QTDataReferenceTypeHandle);
QTSTRING(QTDataReferenceTypePointer);
QTSTRING(QTDataReferenceTypeResource);
QTSTRING(QTDataReferenceTypeURL);

@implementation QTDataReference

+ (id)dataReferenceWithReferenceToFile:(NSString *)fileName
{
    return [[[self alloc] initWithReferenceToFile:fileName] autorelease];
}

+ (id)dataReferenceWithReferenceToURL:(NSURL *)url
{
    return [[[self alloc] initWithReferenceToURL:url] autorelease];
}

+ (id)dataReferenceWithReferenceToData:(NSData *)data
{
    return [[[self alloc] initWithReferenceToData:data] autorelease];
}

+ (id)dataReferenceWithReferenceToData:(NSData *)data name:(NSString *)name MIMEType:(NSString *)MIMEType
{
    return [[[self alloc] initWithReferenceToData:data name:name MIMEType:MIMEType] autorelease];
}

- (id)initWithReferenceToFile:(NSString *)fileName
{
    if (!fileName) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _type = [QTDataReferenceTypeFile retain];
        _url = [[NSURL fileURLWithPath:fileName] retain];
    }
    return self;
}

- (id)initWithReferenceToURL:(NSURL *)url
{
    if (!url) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _type = [([url isFileURL] ? QTDataReferenceTypeFile : QTDataReferenceTypeURL) retain];
        _url = [url retain];
    }
    return self;
}

- (id)initWithReferenceToData:(NSData *)data
{
    return [self initWithReferenceToData:data name:nil MIMEType:nil];
}

- (id)initWithReferenceToData:(NSData *)data name:(NSString *)name MIMEType:(NSString *)MIMEType
{
    if (!data) {
        [self release];
        return nil;
    }
    if ((self = [super init])) {
        _type = [QTDataReferenceTypeHandle retain];
        _data = [data retain];
        _name = [name copy];
        _mimeType = [MIMEType copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        _type = [[coder decodeObjectForKey:@"type"] retain];
        _url = [[coder decodeObjectForKey:@"url"] retain];
        _data = [[coder decodeObjectForKey:@"data"] retain];
        _name = [[coder decodeObjectForKey:@"name"] retain];
        _mimeType = [[coder decodeObjectForKey:@"MIMEType"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_url forKey:@"url"];
    [coder encodeObject:_data forKey:@"data"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_mimeType forKey:@"MIMEType"];
}

- (void)dealloc
{
    [_type release];
    [_url release];
    [_data release];
    [_name release];
    [_mimeType release];
    [super dealloc];
}

- (NSString *)dataRefType { return _type; }
- (NSString *)referenceFile { return [_url isFileURL] ? [_url path] : nil; }
- (NSURL *)referenceURL { return _url; }
- (NSData *)referenceData { return _data; }
- (NSString *)name { return _name; }
- (NSString *)MIMEType { return _mimeType; }

- (void)setName:(NSString *)name
{
    [_name autorelease];
    _name = [name copy];
}

- (void)setMIMEType:(NSString *)MIMEType
{
    [_mimeType autorelease];
    _mimeType = [MIMEType copy];
}

@end
