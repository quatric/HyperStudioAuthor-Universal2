#import "HSFunctions.h"
#import "NSEMutableProtocolSet.h"
#import "HSReplaceColorsEffect.h"
#import "HSiPadExportContext.h"

const NSUInteger HSTemporaryWillAttributeChanges = 0x14;
const NSUInteger HSTemporaryDidAttributeChanges = 0x28;
const NSUInteger HSActualWillAttributeChanges = 0x15;
const NSUInteger HSActualDidAttributeChanges = 0x2a;
const NSUInteger HSActualAttributeChanges = 0x3f;
const NSUInteger HSAllAttributeChanges = 0xff;

const double kAnimationPathDefaultPointsPerSecondCount = 60;
const double kAnimationMinTimeIntervalBetweenKeyFrames = 0.01;

struct HSTimeRange HSMakeTimeRange(double aLocation, double aLength)
{
    struct HSTimeRange range = { aLocation, aLength <= 0 ? 0 : aLength };
    return range;
}

double HSMaxTimeRange(struct HSTimeRange aRange)
{
    return aRange.location + aRange.length;
}

BOOL HSLocationInTimeRange(double aLocation, struct HSTimeRange aRange)
{
    return !(aRange.length <= aLocation - aRange.location || aLocation < aRange.location);
}

static BOOL HSTimeRangeValuesEqual(float aValue, float aValue2)
{
    float magnitude = aValue != 0 ? fabsf(aValue) : 1.0f;
    float magnitude2 = aValue2 != 0 ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue - aValue2) <= MAX(magnitude, magnitude2) * 0.0005f;
}

BOOL HSEqualTimeRanges(struct HSTimeRange aRange, struct HSTimeRange aRange2)
{
    return HSTimeRangeValuesEqual(aRange.location, aRange2.location) && HSTimeRangeValuesEqual(aRange.length, aRange2.length);
}

BOOL HSTimeRangeInsideRange(struct HSTimeRange aRange, struct HSTimeRange aRange2)
{
    return aRange2.location <= aRange.location && aRange.location + aRange.length <= aRange2.location + aRange2.length;
}

struct HSTimeRange HSMergeTimeRanges(struct HSTimeRange aRange, struct HSTimeRange aRange2)
{
    if (aRange.length == 0 && aRange2.length == 0)
        return HSMakeTimeRange(0, 0);
    if (aRange.length == 0)
        return aRange2;
    if (!(aRange2.length > 0))
        return aRange;
    double start = MIN(aRange.location, aRange2.location);
    double end = MAX(aRange.location + aRange.length, aRange2.location + aRange2.length);
    struct HSTimeRange range = { start, end - start };
    return range;
}

float HSObjectAssistantAnimationDuration(void)
{
    return 0.25f;
}

CGPoint HSPixelAlignment_pointAlignPixel(CGContextRef aContext, CGPoint aPoint)
{
    CGPoint device = CGContextConvertPointToDeviceSpace(aContext, aPoint);
    return CGContextConvertPointToUserSpace(aContext, CGPointMake(lroundf(device.x), lroundf(device.y)));
}

CGRect HSPixelAlignment_rectAlignPixel(CGContextRef aContext, CGRect aRect)
{
    CGRect device = CGContextConvertRectToDeviceSpace(aContext, aRect);
    CGAffineTransform ctm = CGContextGetCTM(aContext);
    if (fabs(ctm.b) > 1e-6 || fabs(ctm.c) > 1e-6)
        return aRect;
    device.origin.x = nearbyintf(device.origin.x);
    device.origin.y = nearbyintf(device.origin.y);
    device.size.width = ceilf(device.size.width);
    device.size.height = ceilf(device.size.height);
    return CGContextConvertRectToUserSpace(aContext, device);
}

CGSize HSPixelAlignment_sizeAlignPixel(CGContextRef aContext, CGSize aSize)
{
    CGSize device = CGContextConvertSizeToDeviceSpace(aContext, aSize);
    return CGContextConvertSizeToUserSpace(aContext, CGSizeMake(lroundf(device.width), lroundf(device.height)));
}

static const void *HSCFTypeOrNullRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    return aValue != NULL ? CFRetain(aValue) : NULL;
}

static void HSCFTypeOrNullRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    if (aValue != NULL)
        CFRelease(aValue);
}

static CFStringRef HSCFTypeOrNullCopyDescription(const void *aValue)
{
    if (aValue == NULL)
        return CFRetain(CFSTR("(null)"));
    return CFCopyDescription(aValue);
}

static Boolean HSCFTypeOrNullEqual(const void *aValue, const void *aValue2)
{
    if (aValue == NULL)
        return aValue2 == NULL;
    if (aValue2 == NULL)
        return false;
    return CFEqual(aValue, aValue2);
}

// "<class or CF type: 0x…>" without touching the object otherwise.
static CFStringRef HSNonOwnedCFTypePointerCopyDescription(const void *aValue)
{
    if (aValue == NULL)
        return CFRetain(CFSTR("(null)"));
    CFTypeID type = CFGetTypeID(aValue);
    // Type ID 1 was the bridged Objective-C object type on i386.
    BOOL object = type == 1;
    CFStringRef typeName = object ? (CFStringRef)NSStringFromClass([(id)aValue class])
                                  : CFCopyTypeIDDescription(type);
    CFStringRef description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<%@: %p>"), typeName, aValue);
    if (typeName != NULL && !object)
        CFRelease(typeName);
    return description;
}

const CFDictionaryKeyCallBacks HSNonOwnedCFTypePointerOrNullCFDictionaryKeyCallBacks = {
    0, NULL, NULL, HSNonOwnedCFTypePointerCopyDescription, NULL, NULL
};

const CFDictionaryValueCallBacks HSCFTypeOrNullCFDictionaryValueCallBacks = {
    0, HSCFTypeOrNullRetain, HSCFTypeOrNullRelease, HSCFTypeOrNullCopyDescription, HSCFTypeOrNullEqual
};

BOOL HSProtocolsAreEqual(Protocol *aProtocol, Protocol *aProtocol2)
{
    if (aProtocol == aProtocol2)
        return YES;
    if (aProtocol == nil || aProtocol2 == nil)
        return NO;
    return strcmp(protocol_getName(aProtocol), protocol_getName(aProtocol2)) == 0 && protocol_isEqual(aProtocol, aProtocol2);
}

// From the name's length and its first, middle and last characters.
static CFHashCode HSProtocolOrNullHash(const void *aValue)
{
    if (aValue == NULL)
        return 0;
    const char *name = protocol_getName((Protocol *)aValue);
    size_t length = name ? strlen(name) : 0;
    if (length == 0)
        return 0;
    return (CFHashCode)(unsigned char)name[length - 1] << 24 | (CFHashCode)(unsigned char)name[length / 2] << 16
        | (CFHashCode)(unsigned char)name[0] << 8 | length;
}

static CFStringRef HSProtocolOrNullCopyDescription(const void *aValue)
{
    if (aValue == NULL)
        return CFRetain(CFSTR("(null)"));
    return (CFStringRef)[[NSString alloc] initWithUTF8String:protocol_getName((Protocol *)aValue)];
}

static Boolean HSProtocolOrNullEqual(const void *aValue, const void *aValue2)
{
    return HSProtocolsAreEqual((Protocol *)aValue, (Protocol *)aValue2);
}

const CFDictionaryKeyCallBacks HSProtocolOrNullCFDictionaryKeyCallBacks = {
    0, NULL, NULL, HSProtocolOrNullCopyDescription, HSProtocolOrNullEqual, HSProtocolOrNullHash
};

const CFDictionaryKeyCallBacks HSProtocolCFDictionaryKeyCallBacks = {
    0, NULL, NULL, HSProtocolOrNullCopyDescription, HSProtocolOrNullEqual, HSProtocolOrNullHash
};

static NSUInteger HSProtocolMapHash(NSMapTable *aTable, const void *aKey)
{
    return HSProtocolOrNullHash(aKey);
}

static BOOL HSProtocolMapIsEqual(NSMapTable *aTable, const void *aKey, const void *aKey2)
{
    return HSProtocolsAreEqual((Protocol *)aKey, (Protocol *)aKey2);
}

static NSString *HSProtocolMapDescribe(NSMapTable *aTable, const void *aKey)
{
    return aKey ? NSStringFromProtocol((Protocol *)aKey) : @"(null)";
}

const NSMapTableKeyCallBacks HSProtocolMapKeyCallBacks = {
    HSProtocolMapHash, HSProtocolMapIsEqual, NULL, NULL, HSProtocolMapDescribe, NSNotAPointerMapKey
};

const NSMapTableKeyCallBacks HSProtocolOrNullMapKeyCallBacks = {
    HSProtocolMapHash, HSProtocolMapIsEqual, NULL, NULL, HSProtocolMapDescribe, NSNotAPointerMapKey
};

static NSUInteger HSProtocolHashTableHash(NSHashTable *aTable, const void *aItem)
{
    return HSProtocolOrNullHash(aItem);
}

static BOOL HSProtocolHashTableIsEqual(NSHashTable *aTable, const void *aItem, const void *aItem2)
{
    return HSProtocolsAreEqual((Protocol *)aItem, (Protocol *)aItem2);
}

static NSString *HSProtocolHashTableDescribe(NSHashTable *aTable, const void *aItem)
{
    return aItem ? NSStringFromProtocol((Protocol *)aItem) : @"(null)";
}

const NSHashTableCallBacks HSProtocolHashTableCallBacks = {
    HSProtocolHashTableHash, HSProtocolHashTableIsEqual, NULL, NULL, HSProtocolHashTableDescribe
};

static NSString *HSSelectorMapDescribe(NSMapTable *aTable, const void *aKey)
{
    return NSStringFromSelector((SEL)aKey);
}

const NSMapTableKeyCallBacks HSSelectorMapKeyCallBacks = {
    NULL, NULL, NULL, NULL, HSSelectorMapDescribe, NSNotAPointerMapKey
};

static void HSObjectOrNullMapRetain(NSMapTable *aTable, const void *aValue)
{
    [(id)aValue retain];
}

static void HSObjectOrNullMapRelease(NSMapTable *aTable, void *aValue)
{
    [(id)aValue release];
}

static NSString *HSObjectOrNullMapDescribe(NSMapTable *aTable, const void *aValue)
{
    return [NSString stringWithFormat:@"%@", (id)aValue];
}

const NSMapTableValueCallBacks HSObjectOrNullMapValueCallBacks = {
    HSObjectOrNullMapRetain, HSObjectOrNullMapRelease, HSObjectOrNullMapDescribe
};

// The tolerance for comparing two coordinates: 1/2000 of the larger magnitude,
// a zero counting as 1.
static CGFloat HSHitTestTolerance(CGFloat aValue, CGFloat aValue2)
{
    CGFloat magnitude = aValue != 0 ? fabs(aValue) : 1;
    CGFloat magnitude2 = aValue2 != 0 ? fabs(aValue2) : 1;
    return MAX(magnitude, magnitude2) * 0.0005;
}

static BOOL HSHitTestEqual(CGFloat aValue, CGFloat aValue2)
{
    return fabs(aValue - aValue2) <= HSHitTestTolerance(aValue, aValue2);
}

static BOOL HSHitTestLessOrEqual(CGFloat aValue, CGFloat aValue2)
{
    return aValue <= aValue2 + HSHitTestTolerance(aValue, aValue2);
}

// Fix: where a tolerance is zero the original compared the first point's
// coordinate with itself, so any point hit; the coordinates are compared now.
BOOL HSHitTestPoint(NSPoint aPoint, NSPoint aTestPoint, NSSize aTolerance)
{
    if (!HSHitTestEqual(aTolerance.width, 0)) {
        if (!HSHitTestEqual(aTolerance.height, 0)) {
            CGFloat dx = aTestPoint.x - aPoint.x;
            CGFloat dy = aTestPoint.y - aPoint.y;
            CGFloat distance = dx * dx / (aTolerance.width * aTolerance.width) + dy * dy / (aTolerance.height * aTolerance.height);
            return HSHitTestLessOrEqual(distance, 1);
        }
        if (!HSHitTestEqual(aPoint.y, aTestPoint.y))
            return NO;
        return HSHitTestLessOrEqual(fabs(aPoint.x - aTestPoint.x), aTolerance.width);
    }
    if (!HSHitTestEqual(aPoint.x, aTestPoint.x))
        return NO;
    if (!HSHitTestEqual(aTolerance.height, 0))
        return HSHitTestLessOrEqual(fabs(aPoint.y - aTestPoint.y), aTolerance.height);
    return HSHitTestEqual(aPoint.y, aTestPoint.y);
}

// Within the tolerance ellipse swept along the line through both points.
static BOOL HSHitTestSlopedLine(CGFloat aSlope, NSPoint aPoint, NSPoint aTestPoint, NSSize aTolerance)
{
    CGFloat offset = (aTestPoint.x - aPoint.x) * aSlope - (aTestPoint.y - aPoint.y);
    CGFloat reach = aTolerance.height * aTolerance.height + aSlope * aSlope * aTolerance.width * aTolerance.width;
    return HSHitTestLessOrEqual(offset * offset, reach);
}

BOOL HSHitTestLine(NSPoint aPoint, NSPoint aPoint2, NSPoint aTestPoint, NSSize aTolerance)
{
    if (!HSHitTestEqual(aPoint.x, aPoint2.x)) {
        if (!HSHitTestEqual(aPoint.y, aPoint2.y))
            return HSHitTestSlopedLine((aPoint.y - aPoint2.y) / (aPoint.x - aPoint2.x), aPoint, aTestPoint, aTolerance);
        return HSHitTestLessOrEqual(fabs(aTestPoint.y - aPoint.y), aTolerance.height);
    }
    if (HSHitTestEqual(aPoint.y, aPoint2.y))
        return HSHitTestPoint(aPoint, aTestPoint, aTolerance);
    return HSHitTestLessOrEqual(fabs(aTestPoint.x - aPoint.x), aTolerance.width);
}

// Between the ends the segment is tested as a line; beyond them, against the
// nearer end point.
BOOL HSHitTestLineSegment(NSPoint aPoint, NSPoint aPoint2, NSPoint aTestPoint, NSSize aTolerance)
{
    NSPoint end;
    if (!HSHitTestEqual(aPoint.x, aPoint2.x)) {
        NSPoint left = aPoint2.x < aPoint.x ? aPoint2 : aPoint;
        NSPoint right = aPoint2.x < aPoint.x ? aPoint : aPoint2;
        end = left;
        if (HSHitTestEqual(left.y, right.y)) {
            if (HSHitTestLessOrEqual(left.x, aTestPoint.x)) {
                end = right;
                if (HSHitTestLessOrEqual(aTestPoint.x, right.x))
                    return HSHitTestLessOrEqual(fabs(aTestPoint.y - left.y), aTolerance.height);
            }
        } else {
            CGFloat slope = (left.y - right.y) / (left.x - right.x);
            if (HSHitTestLessOrEqual(0, slope * (aTestPoint.y - left.y) + (aTestPoint.x - left.x))) {
                end = right;
                if (HSHitTestLessOrEqual((aTestPoint.y - right.y) * slope + (aTestPoint.x - right.x), 0))
                    return HSHitTestSlopedLine(slope, left, aTestPoint, aTolerance);
            }
        }
    } else {
        end = aPoint;
        if (!HSHitTestEqual(aPoint.y, aPoint2.y)) {
            CGFloat bottom = MIN(aPoint.y, aPoint2.y);
            CGFloat top = aPoint.y <= aPoint2.y ? aPoint2.y : aPoint.y;
            end = NSMakePoint(aPoint.x, bottom);
            if (HSHitTestLessOrEqual(bottom, aTestPoint.y)) {
                end = NSMakePoint(aPoint2.x, top);
                if (HSHitTestLessOrEqual(aTestPoint.y, top))
                    return HSHitTestLessOrEqual(fabs(aTestPoint.x - aPoint.x), aTolerance.width);
            }
        }
    }
    return HSHitTestPoint(end, aTestPoint, aTolerance);
}

// Inside the rectangle, within the tolerance of a side, or near a corner.
BOOL HSHitTestRectangle(NSRect aRect, NSPoint aTestPoint, NSSize aTolerance)
{
    NSPoint corner = aRect.origin;
    if (HSHitTestLessOrEqual(aRect.origin.x, aTestPoint.x)) {
        corner.x = NSMaxX(aRect);
        if (HSHitTestLessOrEqual(aTestPoint.x, corner.x)) {
            if (!HSHitTestLessOrEqual(aRect.origin.y, aTestPoint.y))
                return HSHitTestLessOrEqual(aRect.origin.y - aTestPoint.y, aTolerance.height);
            CGFloat top = NSMaxY(aRect);
            if (HSHitTestLessOrEqual(aTestPoint.y, top))
                return YES;
            return HSHitTestLessOrEqual(aTestPoint.y - top, aTolerance.height);
        }
        if (HSHitTestLessOrEqual(aRect.origin.y, aTestPoint.y)) {
            corner.y = NSMaxY(aRect);
            if (HSHitTestLessOrEqual(aTestPoint.y, corner.y))
                return HSHitTestLessOrEqual(aTestPoint.x - corner.x, aTolerance.width);
        }
    } else if (HSHitTestLessOrEqual(aRect.origin.y, aTestPoint.y)) {
        corner.y = NSMaxY(aRect);
        if (HSHitTestLessOrEqual(aTestPoint.y, corner.y))
            return HSHitTestLessOrEqual(aRect.origin.x - aTestPoint.x, aTolerance.width);
    }
    return HSHitTestPoint(corner, aTestPoint, aTolerance);
}

// The rectangle of the size at the origin, mapped through the transform: inside
// it, or within the tolerance of a side. The original split this into cases
// (an axis-aligned rectangle went to HSHitTestRectangle, vertical and
// horizontal sides were tested apart, and outside a side only the nearer side
// was tested); the cases are folded into one test here.
BOOL HSHitTestParallelogram(NSSize aSize, NSAffineTransform *aTransform, NSPoint aTestPoint, NSSize aTolerance)
{
    NSPoint corners[4] = {
        [aTransform transformPoint:NSZeroPoint],
        [aTransform transformPoint:NSMakePoint(aSize.width, 0)],
        [aTransform transformPoint:NSMakePoint(aSize.width, aSize.height)],
        [aTransform transformPoint:NSMakePoint(0, aSize.height)]
    };
    CGFloat area = (corners[1].x - corners[0].x) * (corners[3].y - corners[0].y)
        - (corners[1].y - corners[0].y) * (corners[3].x - corners[0].x);
    // A parallelogram with no area is only its sides.
    if (!HSHitTestEqual(area, 0)) {
        BOOL inside = YES;
        for (int i = 0; i < 4 && inside; i++) {
            NSPoint from = corners[i], to = corners[(i + 1) % 4];
            CGFloat side = (to.x - from.x) * (aTestPoint.y - from.y) - (to.y - from.y) * (aTestPoint.x - from.x);
            inside = HSHitTestLessOrEqual(0, area > 0 ? side : -side);
        }
        if (inside)
            return YES;
    }
    for (int i = 0; i < 4; i++)
        if (HSHitTestLineSegment(corners[i], corners[(i + 1) % 4], aTestPoint, aTolerance))
            return YES;
    return NO;
}

// The first grid position at or after aStart: the grid runs through aOffset
// every aSpacing.
static CGFloat HSGridFirstPosition(CGFloat aStart, CGFloat aOffset, CGFloat aSpacing)
{
    CGFloat phase = aOffset - floorf(aOffset / aSpacing) * aSpacing;
    if (!HSHitTestLessOrEqual(0, phase))
        phase += aSpacing;
    return ceilf((aStart - phase) / aSpacing) * aSpacing + phase;
}

static NSPoint HSGridViewPoint(HSView *aView, CGFloat aX, CGFloat aY)
{
    NSPoint point = NSMakePoint(aX, aY);
    return aView ? [aView convertPointFromUserSpaceToViewSpace:point] : point;
}

// Draws the grid's marks over the rectangle (in user space) of the view, or of
// the current context when the view is nil: dots (1), crosses clipped to the
// rectangle (2) or lines (3), one pixel wide.
// Fix: the original put the rows of dots and crosses at the rectangle's bottom
// and then every spacing, so they moved with the rectangle redrawn; they are on
// the grid's rows now, as the lines are.
void HSRenderGrid(id <HSGridInterface> aGrid, HSView *aView, NSRect aRect)
{
    HSLayoutGrid *layoutGrid = [aGrid layoutGrid];
    NSInteger markStyle = [aGrid markStyle];
    [NSGraphicsContext saveGraphicsState];
    [[aView viewSpaceToUserSpaceTransform] concat];
    NSSize offset = [aGrid gridOffset];
    NSSize spacing = [layoutGrid gridSpacing];
    [(NSColor *)[aGrid gridColor] set];
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);

    NSPoint bottomLeft = HSGridViewPoint(aView, NSMinX(aRect), NSMinY(aRect));
    NSPoint topRight = HSGridViewPoint(aView, NSMaxX(aRect), NSMaxY(aRect));
    CGFloat firstY = HSGridFirstPosition(NSMinY(aRect), offset.height, spacing.height);
    for (CGFloat x = HSGridFirstPosition(NSMinX(aRect), offset.width, spacing.width);
         HSHitTestLessOrEqual(x, NSMaxX(aRect)); x += spacing.width) {
        if (markStyle == 3) {
            NSPoint from = HSGridViewPoint(aView, x, NSMinY(aRect));
            NSPoint to = HSGridViewPoint(aView, x, NSMaxY(aRect));
            CGContextMoveToPoint(context, floorf(from.x) + 0.5, from.y);
            CGContextAddLineToPoint(context, floorf(to.x) + 0.5, to.y);
            continue;
        }
        for (CGFloat y = firstY; HSHitTestLessOrEqual(y, NSMaxY(aRect)); y += spacing.height) {
            NSPoint mark = HSGridViewPoint(aView, x, y);
            CGFloat markX = floorf(mark.x), markY = floorf(mark.y);
            if (markStyle == 1) {
                CGContextAddEllipseInRect(context, CGRectMake(markX - 1, markY - 1, 2, 2));
            } else if (markStyle == 2) {
                CGFloat left = HSHitTestLessOrEqual(markX - 4, bottomLeft.x) ? bottomLeft.x : markX - 4;
                CGFloat right = HSHitTestLessOrEqual(topRight.x, markX + 4) ? topRight.x : markX + 4;
                CGFloat bottom = HSHitTestLessOrEqual(markY - 4, bottomLeft.y) ? bottomLeft.y : markY - 4;
                CGFloat top = HSHitTestLessOrEqual(topRight.y, markY + 4) ? topRight.y : markY + 4;
                CGContextMoveToPoint(context, left, markY);
                CGContextAddLineToPoint(context, right, markY);
                CGContextMoveToPoint(context, markX, bottom);
                CGContextAddLineToPoint(context, markX, top);
            }
        }
    }
    if (markStyle == 3) {
        for (CGFloat y = firstY; HSHitTestLessOrEqual(y, NSMaxY(aRect)); y += spacing.height) {
            NSPoint from = HSGridViewPoint(aView, NSMinX(aRect), y);
            NSPoint to = HSGridViewPoint(aView, NSMaxX(aRect), y);
            CGContextMoveToPoint(context, from.x, floorf(from.y) + 0.5);
            CGContextAddLineToPoint(context, to.x, floorf(to.y) + 0.5);
        }
    }
    CGContextClosePath(context);
    CGContextStrokePath(context);
    [NSGraphicsContext restoreGraphicsState];
}

struct HSScriptBisonRange HSScriptMakeZeroBisonRange(void)
{
    struct HSScriptBisonRange range = { 0, 0, 0, 0, NULL };
    return range;
}

void HSScriptExtendBisonRange(struct HSScriptBisonRange *aRange, int aFirstLine, int aLastLine, int aFirstColumn, int aLastColumn)
{
    if (!aRange)
        return;
    if (aFirstLine < aRange->first_line) {
        aRange->first_line = aFirstLine;
        aRange->first_column = aFirstColumn;
    } else if (aFirstLine == aRange->first_line && aFirstColumn < aRange->first_column) {
        aRange->first_column = aFirstColumn;
    }
    if (aRange->last_line < aLastLine) {
        aRange->last_line = aLastLine;
        aRange->last_column = aLastColumn;
    } else if (aRange->last_line == aLastLine && aRange->last_column < aLastColumn) {
        aRange->last_column = aLastColumn;
    }
}

struct HSScriptBisonRange HSScriptUnionBisonRange(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    HSScriptExtendBisonRange(&aRange, aRange2.first_line, aRange2.last_line, aRange2.first_column, aRange2.last_column);
    return aRange;
}

BOOL HSScriptBisonRangesAreEqual(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    return aRange.first_column == aRange2.first_column && aRange.last_column == aRange2.last_column
        && aRange.first_line == aRange2.first_line && aRange.last_line == aRange2.last_line;
}

BOOL HSScriptBisonRangesAreOverlapped(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    if (aRange.last_line < aRange2.first_line
        || (aRange.last_line == aRange2.first_line && aRange.last_column <= aRange2.first_column)
        || aRange2.last_line < aRange.first_line)
        return NO;
    if (aRange2.last_line == aRange.first_line)
        return aRange.first_column < aRange2.last_column;
    return YES;
}

static int HSScriptCompareLineColumn(int aLine, int aColumn, int aLine2, int aColumn2)
{
    if (aLine != aLine2)
        return aLine < aLine2 ? -1 : 1;
    if (aColumn != aColumn2)
        return aColumn < aColumn2 ? -1 : 1;
    return 0;
}

int HSScriptBisonRangesCompareStarts(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    return HSScriptCompareLineColumn(aRange.first_line, aRange.first_column, aRange2.first_line, aRange2.first_column);
}

int HSScriptBisonRangesCompareEnds(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    return HSScriptCompareLineColumn(aRange.last_line, aRange.last_column, aRange2.last_line, aRange2.last_column);
}

BOOL HSScriptBisonRangeIsContained(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    return HSScriptBisonRangesCompareStarts(aRange, aRange2) <= 0 && HSScriptBisonRangesCompareEnds(aRange, aRange2) >= 0;
}

struct HSScriptBisonRange HSScriptBetweenBisonRange(struct HSScriptBisonRange aRange, struct HSScriptBisonRange aRange2)
{
    struct HSScriptBisonRange range = { aRange.last_line, aRange2.first_line, aRange.last_column, aRange2.first_column, aRange.text };
    return range;
}

static NSRecursiveLock *HSProfileLock;
static NSMapTable *HSProfileStamps;

static NSRecursiveLock *HSProfileStampsLock(void)
{
    if (!HSProfileLock)
        HSProfileLock = [[NSRecursiveLock alloc] init];
    return HSProfileLock;
}

static NSMapTable *HSProfileStampsTable(void)
{
    if (!HSProfileStamps)
        HSProfileStamps = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 64);
    return HSProfileStamps;
}

BOOL ProfileStartStamp(id aKey)
{
    [HSProfileStampsLock() lock];
    if (NSMapMember(HSProfileStampsTable(), aKey, NULL, NULL)) {
        [HSProfileStampsLock() unlock];
        return NO;
    }
    struct timeval *start = calloc(sizeof(struct timeval), 1);
    NSMapInsert(HSProfileStampsTable(), aKey, start);
    [HSProfileStampsLock() unlock];
    gettimeofday(start, NULL);
    return YES;
}

double ProfileFinishStamp(id aKey)
{
    struct timeval now;
    gettimeofday(&now, NULL);
    [HSProfileStampsLock() lock];
    struct timeval *start = NSMapGet(HSProfileStampsTable(), aKey);
    double seconds = -1;
    if (start) {
        seconds = (double)(now.tv_usec - start->tv_usec) * 1e-6 + (double)(now.tv_sec - start->tv_sec);
        NSMapRemove(HSProfileStampsTable(), aKey);
        free(start);
    }
    [HSProfileStampsLock() unlock];
    return seconds;
}

double ProfileStampAccuracy(void)
{
    ProfileStartStamp(@"Calculating accuracy...");
    usleep(10000);
    return ProfileFinishStamp(@"Calculating accuracy...") - 0.01;
}

NSString *EXDocumentsDirectory(void)
{
    NSString *name = [[NSBundle mainBundle] localizedStringForKey:@"Documents" value:@"" table:nil];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:name];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path])
        return path;
    path = NSHomeDirectory();
    if (![manager fileExistsAtPath:path])
        path = [@"/" stringByAppendingPathComponent:name];
    return [manager fileExistsAtPath:path] ? path : @"/";
}

BOOL IsFileExistsAtPath(NSString *aPath)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![manager fileExistsAtPath:aPath isDirectory:&isDirectory] || isDirectory)
        return NO;
    return [manager isReadableFileAtPath:aPath];
}

NSTimer *RestartReleasingTimer(id aTarget, id aUserInfo)
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:aTarget selector:@selector(releaseItemsOnTimer:) userInfo:aUserInfo repeats:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
    return timer;
}

NSInteger compareTitleLengths(NSString *aString, NSString *aString2, void *aContext)
{
    NSUInteger length = [aString length], length2 = [aString2 length];
    if (length > length2)
        return NSOrderedAscending;
    if (length < length2)
        return NSOrderedDescending;
    return [aString compare:aString2];
}

// Descends through hyper interfaces, collecting the attributes met.
static Boolean HSCollectHyperInterfaceAttribute(void *aContext, Protocol *aProtocol)
{
    if (protocol_conformsToProtocol(aProtocol, @protocol(HyperInterface)))
        return true;
    if (protocol_conformsToProtocol(aProtocol, @protocol(HSAttribute)))
        [(NSEMutableProtocolSet *)aContext addProtocol:aProtocol];
    return false;
}

void HSCollectHyperInterfaceAttributes(Protocol *aInterface, NSEMutableProtocolSet *aSet)
{
    NSETraverseAdoptedProtocols(aInterface, HSCollectHyperInterfaceAttribute, aSet);
}

static CGFloat HSBigEndianFloat(const UInt8 *aBytes)
{
    CFSwappedFloat32 value;
    memcpy(&value, aBytes, sizeof(value));
    return CFConvertFloat32SwappedToHost(value);
}

CGPathRef CGHyperPathCreateFromBinaryStoredData(CFDataRef aData)
{
    CGMutablePathRef path = CGPathCreateMutable();
    const UInt8 *bytes = CFDataGetBytePtr(aData);
    CFIndex length = CFDataGetLength(aData);
    if (length >= 28) {
        for (CFIndex i = 0; i < length / 28; i++) {
            const UInt8 *record = bytes + i * 28;
            CGFloat x = HSBigEndianFloat(record + 4), y = HSBigEndianFloat(record + 8);
            switch (record[0]) {
            case 'M':
                CGPathMoveToPoint(path, NULL, x, y);
                break;
            case 'L':
                CGPathAddLineToPoint(path, NULL, x, y);
                break;
            case 'C':
                CGPathAddCurveToPoint(path, NULL, HSBigEndianFloat(record + 12), HSBigEndianFloat(record + 16),
                                      HSBigEndianFloat(record + 20), HSBigEndianFloat(record + 24), x, y);
                break;
            case 'Z':
                CGPathCloseSubpath(path);
                break;
            }
        }
    }
    CGPathRef copy = CGPathCreateCopy(path);
    CGPathRelease(path);
    return copy;
}

// The original passed CFURLCreateData's result (the URL's own string bytes,
// not the file's contents) to the decoder; fixed to read the file.
CGPathRef CGHyperPathCreateFromContentsOfBinaryURL(CFURLRef aURL)
{
    NSData *data = [NSData dataWithContentsOfURL:(NSURL *)aURL];
    return CGHyperPathCreateFromBinaryStoredData((CFDataRef)(data != nil ? data : [NSData data]));
}

id HSTransparentColorEffect(void)
{
    static HSReplaceColorsEffect *sEffect;
    if (sEffect == nil) {
        sEffect = [[HSReplaceColorsEffect alloc] initWithName:@"ReplaceColors"];
        [sEffect setTargetColor:[NSColor clearColor]];
        [sEffect setValue:(id)kCFBooleanFalse forKey:HSReplaceColorsExchangeColorsKey];
        [sEffect setValue:(id)kCFBooleanTrue forKey:HSReplaceColorsIgnoreAlphaKey];
    }
    return sEffect;
}

void p2cstrcpyMy(unsigned char *aDestination, const unsigned char *aSource)
{
    unsigned int length = aSource[0];
    unsigned int i;
    for (i = 0; i < length; i++) {
        unsigned char c = aSource[i + 1];
        aDestination[i] = c < 0x20 ? 0x20 : c;
    }
    aDestination[length] = 0;
}

static unsigned short HSZipReadShort(const unsigned char *aBytes, size_t anOffset)
{
    return (unsigned short)(aBytes[anOffset] | aBytes[anOffset + 1] << 8);
}

static unsigned int HSZipReadInt(const unsigned char *aBytes, size_t anOffset)
{
    return (unsigned int)aBytes[anOffset] | (unsigned int)aBytes[anOffset + 1] << 8 |
           (unsigned int)aBytes[anOffset + 2] << 16 | (unsigned int)aBytes[anOffset + 3] << 24;
}

void HSReadSFileHeader(struct SFileHeader *aHeader, const void *aBytes)
{
    const unsigned char *b = aBytes;
    aHeader->Signature = HSZipReadInt(b, 0);
    aHeader->VersionPacked = HSZipReadShort(b, 4);
    aHeader->VersionToExtract = HSZipReadShort(b, 6);
    aHeader->GeneralBitFlag = HSZipReadShort(b, 8);
    aHeader->CompressionMethod = HSZipReadShort(b, 10);
    aHeader->LastModFileTime = HSZipReadShort(b, 12);
    aHeader->LastModFileDate = HSZipReadShort(b, 14);
    aHeader->DataDescriptor.CRC32 = HSZipReadInt(b, 16);
    aHeader->DataDescriptor.CompressedSize = HSZipReadInt(b, 20);
    aHeader->DataDescriptor.UncompressedSize = HSZipReadInt(b, 24);
    aHeader->FilenameLength = HSZipReadShort(b, 28);
    aHeader->ExtraFieldLength = HSZipReadShort(b, 30);
    aHeader->CommentLength = HSZipReadShort(b, 32);
    aHeader->DiskNumberStart = HSZipReadShort(b, 34);
    aHeader->InternalFileAttr = HSZipReadShort(b, 36);
    aHeader->ExternalFileAttr = HSZipReadInt(b, 38);
    aHeader->LocalHeaderOffset = HSZipReadInt(b, 42);
}

void HSReadSLocalFileHeader(struct SLocalFileHeader *aHeader, const void *aBytes)
{
    const unsigned char *b = aBytes;
    aHeader->Signature = HSZipReadInt(b, 0);
    aHeader->VersionToExtract = HSZipReadShort(b, 4);
    aHeader->GeneralBitFlag = HSZipReadShort(b, 6);
    aHeader->CompressionMethod = HSZipReadShort(b, 8);
    aHeader->LastModFileTime = HSZipReadShort(b, 10);
    aHeader->LastModFileDate = HSZipReadShort(b, 12);
    aHeader->DataDescriptor.CRC32 = HSZipReadInt(b, 14);
    aHeader->DataDescriptor.CompressedSize = HSZipReadInt(b, 18);
    aHeader->DataDescriptor.UncompressedSize = HSZipReadInt(b, 22);
    aHeader->FilenameLength = HSZipReadShort(b, 26);
    aHeader->ExtraFieldLength = HSZipReadShort(b, 28);
}

static int HSZipWriteShort(NSOutputStream *aStream, unsigned short aValue)
{
    uint8_t b[2] = { aValue & 0xff, aValue >> 8 };
    return (int)[aStream write:b maxLength:2];
}

static int HSZipWriteInt(NSOutputStream *aStream, unsigned int aValue)
{
    uint8_t b[4] = { aValue & 0xff, (aValue >> 8) & 0xff, (aValue >> 16) & 0xff, aValue >> 24 };
    return (int)[aStream write:b maxLength:4];
}

int HSWriteSFileHeader(struct SFileHeader aHeader, NSOutputStream *aStream)
{
    if (aStream == nil)
        return 0;
    return HSZipWriteInt(aStream, aHeader.Signature) +
           HSZipWriteShort(aStream, aHeader.VersionPacked) +
           HSZipWriteShort(aStream, aHeader.VersionToExtract) +
           HSZipWriteShort(aStream, aHeader.GeneralBitFlag) +
           HSZipWriteShort(aStream, aHeader.CompressionMethod) +
           HSZipWriteShort(aStream, aHeader.LastModFileTime) +
           HSZipWriteShort(aStream, aHeader.LastModFileDate) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.CRC32) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.CompressedSize) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.UncompressedSize) +
           HSZipWriteShort(aStream, aHeader.FilenameLength) +
           HSZipWriteShort(aStream, aHeader.ExtraFieldLength) +
           HSZipWriteShort(aStream, aHeader.CommentLength) +
           HSZipWriteShort(aStream, aHeader.DiskNumberStart) +
           HSZipWriteShort(aStream, aHeader.InternalFileAttr) +
           HSZipWriteInt(aStream, aHeader.ExternalFileAttr) +
           HSZipWriteInt(aStream, aHeader.LocalHeaderOffset);
}

int HSWriteSLocalFileHeader(struct SLocalFileHeader aHeader, NSOutputStream *aStream)
{
    if (aStream == nil)
        return 0;
    return HSZipWriteInt(aStream, aHeader.Signature) +
           HSZipWriteShort(aStream, aHeader.VersionToExtract) +
           HSZipWriteShort(aStream, aHeader.GeneralBitFlag) +
           HSZipWriteShort(aStream, aHeader.CompressionMethod) +
           HSZipWriteShort(aStream, aHeader.LastModFileTime) +
           HSZipWriteShort(aStream, aHeader.LastModFileDate) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.CRC32) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.CompressedSize) +
           HSZipWriteInt(aStream, aHeader.DataDescriptor.UncompressedSize) +
           HSZipWriteShort(aStream, aHeader.FilenameLength) +
           HSZipWriteShort(aStream, aHeader.ExtraFieldLength);
}

int HSWriteSDirectory(struct SZipDirectory aDirectory, NSOutputStream *aStream)
{
    if (aStream == nil)
        return 0;
    // The two disk numbers went out as one 4-byte write.
    return HSZipWriteInt(aStream, aDirectory.Signature) +
           HSZipWriteShort(aStream, aDirectory.NumberOfThisDisk) +
           HSZipWriteShort(aStream, aDirectory.NumberOfTheDiskWithCentralDirectory) +
           HSZipWriteShort(aStream, aDirectory.EntriesInCentralDirectoryOnThisDisk) +
           HSZipWriteShort(aStream, aDirectory.EntriesInCentralDirectory) +
           HSZipWriteInt(aStream, aDirectory.CentralDirectorySize) +
           HSZipWriteInt(aStream, aDirectory.CentralDirectoryOffset) +
           HSZipWriteShort(aStream, aDirectory.CommentLength);
}

int SHIFER_streamConvert(unsigned char aByte, unsigned int aIndex, NSString *aKey, NSString *aSecondKey)
{
    if (aKey != nil && aSecondKey != nil && [aKey length] > 1) {
        unsigned int index = aIndex % (unsigned int)([aKey length] >> 1);
        const unsigned char *key = (const unsigned char *)[aKey UTF8String];
        const unsigned char *secondKey = (const unsigned char *)[aSecondKey UTF8String];
        unsigned char mask = (unsigned char)((key[index * 2 + 1] * 2) & 0xaa) | (key[index * 2] & 0x55);
        aByte = aByte ^ secondKey[index % [aSecondKey length]] ^ mask;
    }
    return (int)(signed char)aByte;
}

short kHSCancelExportMovieProgressProc(void *aMovie, short aMessage, short aOperation, int aPercentDone, id aSender)
{
    if ((unsigned short)aMessage < 2)
        return [aSender shouldTerminateExport] ? -128 : 0;
    return 0;
}
