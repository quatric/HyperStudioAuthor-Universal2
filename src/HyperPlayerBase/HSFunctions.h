// HyperPlayerBase's exported C functions, as they're translated from
// HyperPlayerBaseFunctions.m.
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif

// A span of (movie or animation) time, in seconds.
struct HSTimeRange {
    double location;
    double length;
};

// A range with a negative length gets length 0.
struct HSTimeRange HSMakeTimeRange(double aLocation, double aLength);
double HSMaxTimeRange(struct HSTimeRange aRange);
// location <= aLocation < location + length
BOOL HSLocationInTimeRange(double aLocation, struct HSTimeRange aRange);
// Within 0.0005 of the larger magnitude (compared as floats).
BOOL HSEqualTimeRanges(struct HSTimeRange aRange, struct HSTimeRange aRange2);
BOOL HSTimeRangeInsideRange(struct HSTimeRange aRange, struct HSTimeRange aRange2);
// The smallest range covering both; empty ranges don't count.
struct HSTimeRange HSMergeTimeRanges(struct HSTimeRange aRange, struct HSTimeRange aRange2);

// Animation paths: points per second of path time, and the shortest gap
// between key frames.
extern const double kAnimationPathDefaultPointsPerSecondCount;
extern const double kAnimationMinTimeIntervalBetweenKeyFrames;

// duration of the object assistant's animations (scrolling to a card
// object, ...), in seconds
float HSObjectAssistantAnimationDuration(void);

// attribute change masks (HSAttributeNotificationCenter's ofChanges:)
extern const NSUInteger HSTemporaryWillAttributeChanges;
extern const NSUInteger HSTemporaryDidAttributeChanges;
extern const NSUInteger HSActualWillAttributeChanges;
extern const NSUInteger HSActualDidAttributeChanges;
extern const NSUInteger HSActualAttributeChanges;
extern const NSUInteger HSAllAttributeChanges;

// Snap user space geometry to whole device pixels: a point or size is rounded
// in device space; a rect gets its origin rounded and its size rounded up,
// unless the CTM rotates or skews (then it's returned unchanged).
CGPoint HSPixelAlignment_pointAlignPixel(CGContextRef aContext, CGPoint aPoint);
CGRect HSPixelAlignment_rectAlignPixel(CGContextRef aContext, CGRect aRect);
CGSize HSPixelAlignment_sizeAlignPixel(CGContextRef aContext, CGSize aSize);

// CFDictionary callbacks: keys compared and kept by pointer (NULL allowed),
// values CFRetained and compared with CFEqual (NULL allowed).
extern const CFDictionaryKeyCallBacks HSNonOwnedCFTypePointerOrNullCFDictionaryKeyCallBacks;
extern const CFDictionaryValueCallBacks HSCFTypeOrNullCFDictionaryValueCallBacks;

// Protocols that are the same one, or equal ones (the same name and
// conformances, as when two images each have a copy).
BOOL HSProtocolsAreEqual(Protocol *aProtocol, Protocol *aProtocol2);

// CFDictionary key callbacks for protocols (NULL allowed), compared with
// HSProtocolsAreEqual and hashed by name.
extern const CFDictionaryKeyCallBacks HSProtocolOrNullCFDictionaryKeyCallBacks;
extern const CFDictionaryKeyCallBacks HSProtocolCFDictionaryKeyCallBacks;

// NSMapTable keys and NSHashTable items that are protocols, compared with
// HSProtocolsAreEqual and not retained.
extern const NSMapTableKeyCallBacks HSProtocolMapKeyCallBacks;
extern const NSMapTableKeyCallBacks HSProtocolOrNullMapKeyCallBacks;
extern const NSHashTableCallBacks HSProtocolHashTableCallBacks;

// NSMapTable keys that are selectors (compared and hashed as pointers), and
// values that are retained objects or NULL.
extern const NSMapTableKeyCallBacks HSSelectorMapKeyCallBacks;
extern const NSMapTableValueCallBacks HSObjectOrNullMapValueCallBacks;

// Hit tests within a tolerance (half-widths along x and y); coordinates are
// compared with a relative tolerance of 1/2000.
BOOL HSHitTestPoint(NSPoint aPoint, NSPoint aTestPoint, NSSize aTolerance);
BOOL HSHitTestLine(NSPoint aPoint, NSPoint aPoint2, NSPoint aTestPoint, NSSize aTolerance);
BOOL HSHitTestLineSegment(NSPoint aPoint, NSPoint aPoint2, NSPoint aTestPoint, NSSize aTolerance);
BOOL HSHitTestRectangle(NSRect aRect, NSPoint aTestPoint, NSSize aTolerance);
BOOL HSHitTestParallelogram(NSSize aSize, NSAffineTransform *aTransform, NSPoint aTestPoint, NSSize aTolerance);

@class HSView;
@protocol HSGridInterface;

// Draws the grid's marks over the rectangle (in user space) of the view.
void HSRenderGrid(id <HSGridInterface> aGrid, HSView *aView, NSRect aRect);

// Script source ranges (lines and columns as the parser reports them; the text
// is carried along, never compared).
struct HSScriptBisonRange HSScriptMakeZeroBisonRange(void);
void HSScriptExtendBisonRange(struct HSScriptBisonRange *aRange, int aFirstLine, int aLastLine, int aFirstColumn, int aLastColumn);
struct HSScriptBisonRange HSScriptUnionBisonRange(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
BOOL HSScriptBisonRangesAreEqual(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
BOOL HSScriptBisonRangesAreOverlapped(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
int HSScriptBisonRangesCompareStarts(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
int HSScriptBisonRangesCompareEnds(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
// Whether the second range lies within the first.
BOOL HSScriptBisonRangeIsContained(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);
// From the end of the first range to the start of the second.
struct HSScriptBisonRange HSScriptBetweenBisonRange(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2);

// Wall-clock stamps keyed by an object: start returns NO while the key is
// already running; finish returns the seconds since its start, or -1.
BOOL ProfileStartStamp(id aKey);
double ProfileFinishStamp(id aKey);
double ProfileStampAccuracy(void);

// ~/Documents (localized); else the home folder, else /Documents, else /.
NSString *EXDocumentsDirectory(void);
// A readable file (not a folder) at the path.
BOOL IsFileExistsAtPath(NSString *aPath);
// A one-shot 60 s timer sending releaseItemsOnTimer: to the target, also run
// while tracking and in modal panels.
NSTimer *RestartReleasingTimer(id aTarget, id aUserInfo);
// Sorts longer strings first, equal lengths by compare:.
NSInteger compareTitleLengths(NSString *aString, NSString *aString2, void *aContext);

// Adds the attribute protocols a hyper interface adopts, through the hyper
// interfaces it adopts, to the set.
void HSCollectHyperInterfaceAttributes(Protocol *aInterface, NSEMutableProtocolSet *aSet);

// A path from its binary stored form: 28-byte records, a type byte ('M', 'L',
// 'C', 'Z') then six big-endian floats (point, then a curve's two control
// points). Returns +1 (never NULL).
CGPathRef CGHyperPathCreateFromBinaryStoredData(CFDataRef aData);
CGPathRef CGHyperPathCreateFromContentsOfBinaryURL(CFURLRef aURL);

// Transparent colour removal (HSBitmapColorRemoval.m). The copies write a
// premultiplied bitmap, clearing pixels within the hue/chroma/lightness
// tolerances (0...1) of the colour; the in-place ones clear pixels within one
// colour distance tolerance.
#define HS_COPY_REMOVING_COLOR(name) void name(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
HS_COPY_REMOVING_COLOR(HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888);
HS_COPY_REMOVING_COLOR(HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888);
HS_COPY_REMOVING_COLOR(HSBitmapARGB8888PremultipliedCopyRemovingColorFromBGRA8888);
HS_COPY_REMOVING_COLOR(HSBitmapARGB8888PremultipliedCopyRemovingColorFromARGB8888);
HS_COPY_REMOVING_COLOR(HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888Premultiplied);
HS_COPY_REMOVING_COLOR(HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888Premultiplied);
HS_COPY_REMOVING_COLOR(HSBitmapARGB8888PremultipliedCopyRemovingColorFromBGRA8888Premultiplied);
HS_COPY_REMOVING_COLOR(HSBitmapARGB8888PremultipliedCopyRemovingColorFromARGB8888Premultiplied);
#undef HS_COPY_REMOVING_COLOR
void HSBitmapARGB8888PremultipliedRemoveColor(void *aPixels, size_t aWidth, size_t aHeight, size_t aRowBytes, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aTolerance);
void HSBitmapBGRA8888PremultipliedRemoveColor(void *aPixels, size_t aWidth, size_t aHeight, size_t aRowBytes, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aTolerance);

// Pascal string -> C string (may be done in place); control characters
// (< 0x20) become spaces.
void p2cstrcpyMy(unsigned char *aDestination, const unsigned char *aSource);

// The shared "replace colors" effect that makes a colour transparent (target
// colour clear, colours not exchanged, alpha ignored).
id HSTransparentColorEffect(void);


// ZIP records (HSZipWrapper). The readers take the packed little-endian record
// (46 bytes central, 30 bytes local); the writers write it field by field and
// return the number of bytes written (0 without a stream).
struct SZIPFileDataDescriptor {
    unsigned int CRC32;
    unsigned int CompressedSize;
    unsigned int UncompressedSize;
};

struct SFileHeader {
    unsigned int Signature;
    unsigned short VersionPacked;
    unsigned short VersionToExtract;
    unsigned short GeneralBitFlag;
    unsigned short CompressionMethod;
    unsigned short LastModFileTime;
    unsigned short LastModFileDate;
    struct SZIPFileDataDescriptor DataDescriptor;
    unsigned short FilenameLength;
    unsigned short ExtraFieldLength;
    unsigned short CommentLength;
    unsigned short DiskNumberStart;
    unsigned short InternalFileAttr;
    unsigned int ExternalFileAttr;
    unsigned int LocalHeaderOffset;
};
struct SLocalFileHeader {
    unsigned int Signature;
    unsigned short VersionToExtract;
    unsigned short GeneralBitFlag;
    unsigned short CompressionMethod;
    unsigned short LastModFileTime;
    unsigned short LastModFileDate;
    struct SZIPFileDataDescriptor DataDescriptor;
    unsigned short FilenameLength;
    unsigned short ExtraFieldLength;
};
struct SZipDirectory {
    unsigned int Signature;
    unsigned short NumberOfThisDisk;
    unsigned short NumberOfTheDiskWithCentralDirectory;
    unsigned short EntriesInCentralDirectoryOnThisDisk;
    unsigned short EntriesInCentralDirectory;
    unsigned int CentralDirectorySize;
    unsigned int CentralDirectoryOffset;
    unsigned short CommentLength;
};
void HSReadSFileHeader(struct SFileHeader *aHeader, const void *aBytes);
void HSReadSLocalFileHeader(struct SLocalFileHeader *aHeader, const void *aBytes);
int HSWriteSFileHeader(struct SFileHeader aHeader, NSOutputStream *aStream);
int HSWriteSLocalFileHeader(struct SLocalFileHeader aHeader, NSOutputStream *aStream);
int HSWriteSDirectory(struct SZipDirectory aDirectory, NSOutputStream *aStream);
// A QuickTime movie progress procedure for movie exports: asks the sender
// (an export context) to cancel (-128, userCanceledErr) on the open and
// progress messages once it should terminate.
short kHSCancelExportMovieProgressProc(void *aMovie, short aMessage, short aOperation, int aPercentDone, id aSender);
// Byte scrambling keyed by two strings; without keys (or with a key shorter
// than 2) the byte is returned unchanged.
int SHIFER_streamConvert(unsigned char aByte, unsigned int aIndex, NSString *aKey, NSString *aSecondKey);

#ifdef __cplusplus
}
#endif
