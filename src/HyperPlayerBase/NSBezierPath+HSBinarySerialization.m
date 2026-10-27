#import "NSBezierPath+HSBinarySerialization.h"
#import "CGEPath.h"
#import "EXCodingContext.h"
#import "HSFunctions.h"

// Element points in "hyper" order put the element's end point first: a curve
// is (end point, control point 1, control point 2) rather than NSBezierPath's
// (control point 1, control point 2, end point).

// Within 0.0005 of the larger magnitude (zero counting as 1).
static BOOL HSBezierFloatsAreEqual(float aValue, float aValue2)
{
    float magnitude = aValue != 0.0f ? fabsf(aValue) : 1.0f;
    float magnitude2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue - aValue2) <= MAX(magnitude, magnitude2) * 0.0005f;
}

// The binary stored form: 28-byte records, a type byte ('M', 'L', 'C', 'Z'),
// three unused bytes, then three points as six big-endian floats (hyper order).
enum {
    HSBezierBinaryRecordSize = 0x1c
};

static float HSBezierReadBigEndianFloat(const UInt8 *aBytes)
{
    UInt32 bits;
    memcpy(&bits, aBytes, sizeof(bits));
    bits = CFSwapInt32BigToHost(bits);
    float value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static void HSBezierWriteBigEndianFloat(UInt8 *aBytes, float aValue)
{
    UInt32 bits;
    memcpy(&bits, &aValue, sizeof(bits));
    bits = CFSwapInt32HostToBig(bits);
    memcpy(aBytes, &bits, sizeof(bits));
}

@implementation NSBezierPath (HSBinarySerialization)

// The CGPaths (as objects); nil for none.
+ (id)hyperCGPathsFromBinaryStoredDataArray:(id)aArray
{
    NSUInteger count = [aArray count];
    if (count == 0)
        return nil;
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:count];
    for (NSData *data in aArray) {
        CGPathRef path = CGHyperPathCreateFromBinaryStoredData((CFDataRef)data);
        [paths addObject:(id)path];
        CGPathRelease(path);
    }
    return paths;
}

+ (id)hyperBinaryDataArrayForStoringFromCGPaths:(id)aPaths
{
    NSUInteger count = [aPaths count];
    if (count == 0)
        return nil;
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:count];
    for (id path in aPaths)
        [dataArray addObject:[[NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)path] hyperDataForBinaryStoring]];
    return dataArray;
}

+ (id)hyperBezierPathWithContentsOfBinaryFile:(id)aFile
{
    return [self hyperBezierPathWithBinaryStoredData:[NSData dataWithContentsOfFile:aFile]];
}

+ (id)hyperBezierPathWithBinaryStoredData:(id)aData
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    const UInt8 *bytes = [aData bytes];
    NSUInteger length = [aData length];
    if (length >= HSBezierBinaryRecordSize) {
        NSUInteger count = length / HSBezierBinaryRecordSize;
        for (NSUInteger i = 0; i < count; i++) {
            const UInt8 *record = bytes + i * HSBezierBinaryRecordSize;
            NSBezierPathElement element;
            switch (record[0]) {
            case 'C':
                element = NSCurveToBezierPathElement;
                break;
            case 'L':
                element = NSLineToBezierPathElement;
                break;
            case 'Z':
                element = NSClosePathBezierPathElement;
                break;
            default:
                element = NSMoveToBezierPathElement;
                break;
            }
            NSPoint points[3];
            for (int j = 0; j < 3; j++) {
                points[j].x = HSBezierReadBigEndianFloat(record + 4 + j * 8);
                points[j].y = HSBezierReadBigEndianFloat(record + 8 + j * 8);
            }
            [path hyperAppendElement:element associatedPoints:points];
        }
    }
    return path;
}

// The original left the three pad bytes, and a close's points, as whatever
// was on the stack; they are zeroed here.
- (id)hyperDataForBinaryStoring
{
    NSMutableData *data = [NSMutableData data];
    NSInteger count = [self elementCount];
    for (NSInteger i = 0; i < count; i++) {
        NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
        NSBezierPathElement element = [self hyperElementAtIndex:i associatedPoints:points];
        UInt8 record[HSBezierBinaryRecordSize] = { 0 };
        for (int j = 0; j < 3; j++) {
            HSBezierWriteBigEndianFloat(record + 4 + j * 8, points[j].x);
            HSBezierWriteBigEndianFloat(record + 8 + j * 8, points[j].y);
        }
        switch (element) {
        case NSMoveToBezierPathElement:
            record[0] = 'M';
            break;
        case NSLineToBezierPathElement:
            record[0] = 'L';
            break;
        case NSCurveToBezierPathElement:
            record[0] = 'C';
            break;
        case NSClosePathBezierPathElement:
            record[0] = 'Z';
            break;
        default:
            break;
        }
        [data appendBytes:record length:HSBezierBinaryRecordSize];
    }
    return data;
}

@end

@implementation NSBezierPath (HSHitTesting)

// Only straight segments count: the index of the nearest one the point is
// within tolerance of (measured perpendicular to the segment), and how far
// along it the foot of the perpendicular is (0...1). After a curve the next
// segment starts at the curve's first control point, as in the original.
- (BOOL)hyperPathContainsPoint:(NSPoint)aPoint tolerance:(CGFloat)aTolerance index:(int *)aIndex relativeDistance:(float *)aDistance
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [self elementAtIndex:0 associatedPoints:points];
    NSPoint previous = points[0];
    NSInteger count = [self elementCount];
    BOOL found = NO;
    int foundIndex = -1;
    float foundDistance = 0.0f;
    float foundU = -1.0f;
    for (NSInteger i = 0; i + 1 < count; i++) {
        points[0] = NSZeroPoint;
        NSBezierPathElement element = [self elementAtIndex:i + 1 associatedPoints:points];
        if (element == NSLineToBezierPathElement) {
            float distance = 0.0f;
            float u = -1.0f;
            [self hyperDistanceToA:previous B:points[0] fromC:aPoint distance:&distance u:&u];
            if (u >= 0.0f && u < 1.0f && (!found || distance < foundDistance)) {
                found = YES;
                foundDistance = distance;
                foundU = u;
                foundIndex = (int)i;
            }
        }
        previous = points[0];
    }
    if (!found || !(foundDistance < aTolerance))
        return NO;
    if (aIndex != NULL)
        *aIndex = foundIndex;
    if (aDistance != NULL)
        *aDistance = foundU;
    return YES;
}

// Distance from C to the line through A and B, and where the foot of the
// perpendicular falls (u: 0 at A, 1 at B). A degenerate segment gives the
// distance to A and u -1.
- (void)hyperDistanceToA:(NSPoint)aA B:(NSPoint)aB fromC:(NSPoint)aC distance:(float *)aDistance u:(float *)aU
{
    float lengthSquared = [self hyperDistanceSquared:aA :aB];
    if (lengthSquared <= 0.0f) {
        *aDistance = sqrtf((float)[self hyperDistanceSquared:aA :aC]);
        *aU = -1.0f;
        return;
    }
    float u = (float)(((aC.x - aA.x) * (aB.x - aA.x) + (aC.y - aA.y) * (aB.y - aA.y)) / lengthSquared);
    NSPoint foot = NSMakePoint((aB.x - aA.x) * u + aA.x, (aB.y - aA.y) * u + aA.y);
    *aDistance = sqrtf((float)[self hyperDistanceSquared:aC :foot]);
    *aU = u;
}

- (CGFloat)hyperDistanceSquared:(NSPoint)aSquared :(NSPoint)aArg
{
    return (float)((aArg.x - aSquared.x) * (aArg.x - aSquared.x) + (aArg.y - aSquared.y) * (aArg.y - aSquared.y));
}

@end

struct HSBezierPathFromCGPathInfo {
    CGAffineTransform transform;
    NSBezierPath *path;
};

// Quadratic curves are dropped, as in the original. The original also wrote
// the transformed points back into the CGPath's element.
static void HSBezierPathAddCGPathElement(void *aInfo, const CGPathElement *aElement)
{
    struct HSBezierPathFromCGPathInfo *info = aInfo;
    if (info == NULL || aElement == NULL)
        return;
    switch (aElement->type) {
    case kCGPathElementMoveToPoint:
        [info->path moveToPoint:CGPointApplyAffineTransform(aElement->points[0], info->transform)];
        break;
    case kCGPathElementAddLineToPoint:
        [info->path lineToPoint:CGPointApplyAffineTransform(aElement->points[0], info->transform)];
        break;
    case kCGPathElementAddCurveToPoint:
        [info->path curveToPoint:CGPointApplyAffineTransform(aElement->points[2], info->transform)
                   controlPoint1:CGPointApplyAffineTransform(aElement->points[0], info->transform)
                   controlPoint2:CGPointApplyAffineTransform(aElement->points[1], info->transform)];
        break;
    case kCGPathElementCloseSubpath:
        [info->path closePath];
        break;
    default:
        break;
    }
}

@implementation NSBezierPath (HSCreationFromCGPath)

+ (id)hyperBezierPathWithCGPath:(struct CGPath *)aPath
{
    return [self hyperBezierPathWithCGPath:aPath affineTransform:CGAffineTransformIdentity];
}

+ (id)hyperBezierPathWithCGPath:(struct CGPath *)aPath affineTransform:(CGAffineTransform)aTransform
{
    struct HSBezierPathFromCGPathInfo info;
    info.transform = aTransform;
    info.path = [NSBezierPath bezierPath];
    CGPathApply(aPath, &info, HSBezierPathAddCGPathElement);
    return info.path;
}

// NULL when empty. The original returned the copy +1 although its callers
// treat it as not owned; it is autoreleased here.
- (struct CGPath *)hyperCGPath
{
    NSInteger count = [self elementCount];
    if (count < 1)
        return NULL;
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    for (NSInteger i = 0; i < count; i++) {
        NSPoint points[3];
        switch ([self elementAtIndex:i associatedPoints:points]) {
        case NSMoveToBezierPathElement:
            CGPathMoveToPoint(mutablePath, NULL, points[0].x, points[0].y);
            break;
        case NSLineToBezierPathElement:
            CGPathAddLineToPoint(mutablePath, NULL, points[0].x, points[0].y);
            break;
        case NSCurveToBezierPathElement:
            CGPathAddCurveToPoint(mutablePath, NULL, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
            break;
        case NSClosePathBezierPathElement:
            CGPathCloseSubpath(mutablePath);
            break;
        default:
            break;
        }
    }
    CGPathRef path = CGPathCreateCopy(mutablePath);
    CGPathRelease(mutablePath);
    return (struct CGPath *)CFAutorelease(path);
}

@end

@implementation NSString (SVGParsing)

// The run found by the set, with a "-" just before it included.
static NSRange HSSVGSignedRangeOfSequence(NSString *aString, NSCharacterSet *aSet)
{
    NSRange range = [aString rangeOfCharacterSequenceFromSet:aSet];
    if (range.location != 0 && range.location != NSNotFound
        && [[aString substringWithRange:NSMakeRange(range.location - 1, 1)] isEqualToString:@"-"]) {
        range.location--;
        range.length++;
    }
    return range;
}

// Splits the string into the runs of characters from the level's set. Each
// run is a node: the run itself, or, when the text up to the next run splits
// at the next level, that level's nodes followed by the run. nil when the
// string is empty, there is no set for the level, or there are no runs.
- (id)nodeTreeWithCurrentRecurseLevel:(NSUInteger)aLevel characterSets:(id)aSets
{
    NSCharacterSet *set = aLevel < [aSets count] ? [aSets objectAtIndex:aLevel] : nil;
    if ([self length] == 0 || set == nil)
        return nil;
    NSString *rest = self;
    NSRange range = HSSVGSignedRangeOfSequence(rest, set);
    NSMutableArray *nodes = nil;
    while (range.location != NSNotFound) {
        NSString *run = [rest substringWithRange:range];
        if (run == nil)
            break;
        rest = [rest substringFromIndex:NSMaxRange(range)];
        range = HSSVGSignedRangeOfSequence(rest, set);
        NSArray *children = nil;
        if ([rest length] != 0) {
            NSString *text = range.location != NSNotFound ? [rest substringToIndex:range.location] : rest;
            children = [text nodeTreeWithCurrentRecurseLevel:aLevel + 1 characterSets:aSets];
        }
        if (nodes == nil)
            nodes = [NSMutableArray arrayWithCapacity:0];
        [nodes addObject:children != nil ? [children arrayByAddingObject:run] : (id)run];
    }
    return nodes;
}

// The first character from the set and the ones from it that follow.
- (NSRange)rangeOfCharacterSequenceFromSet:(id)aSet
{
    NSRange range = [self rangeOfCharacterFromSet:aSet];
    if (range.location != NSNotFound) {
        while (NSMaxRange(range) < [self length] && [aSet characterIsMember:[self characterAtIndex:NSMaxRange(range)]])
            range.length++;
    }
    return range;
}

@end

// The next value from an enumerator of number strings (0 when used up).
static CGFloat HSSVGNextValue(NSEnumerator *aEnumerator)
{
    id value = [aEnumerator nextObject];
    return value != nil ? [value floatValue] : 0.0;
}

static NSPoint HSSVGNextPoint(NSEnumerator *aEnumerator)
{
    CGFloat x = HSSVGNextValue(aEnumerator);
    CGFloat y = HSSVGNextValue(aEnumerator);
    return NSMakePoint(x, y);
}

@implementation NSBezierPath (EXKeyValueCoding)

// Traces the pixels of the given value; nil when nothing was traced.
+ (id)hyperBezierPathFromOneBitMask:(void *)aMask width:(NSInteger)aWidth height:(NSInteger)aHeight bytesPerRow:(NSInteger)aRow pathColor:(NSInteger)aColor
{
    CGMutablePathRef cgPath = CGPathCreateMutable();
    NSBezierPath *path = nil;
    if (CGEPathAddColoredPathsFromGrayscale1Bitmap(cgPath, NULL, aMask, aWidth, aHeight, aRow, (uint8_t)aColor, 0.0f, 0xffffffff, 0, NULL))
        path = [self hyperBezierPathWithCGPath:cgPath];
    CGPathRelease(cgPath);
    return path;
}

// The dash lengths separated by spaces (the phase is not kept).
+ (id)extraStringRepresentationOfLineDashStyleRepresentationOfPattern:(float *)aPattern count:(NSInteger)aCount phase:(CGFloat)aPhase
{
    NSMutableArray *lengths = [NSMutableArray arrayWithCapacity:aCount + 1];
    for (NSInteger i = 0; i < aCount; i++)
        [lengths addObject:[NSNumber numberWithFloat:aPattern[i]]];
    return [lengths componentsJoinedByString:@" "];
}

// Whether any shape of an SVG representation has a fill. aMixed is not set.
+ (BOOL)isExtraSVGRepFilled:(id)aFilled isMixed:(BOOL *)aMixed
{
    for (NSDictionary *shape in [aFilled objectForKey:@"extraSVGRep"]) {
        for (NSDictionary *attributes in [shape objectEnumerator]) {
            if ([attributes objectForKey:@"fill"] != nil)
                return YES;
        }
    }
    return NO;
}

- (void)setExtraLineDashString:(id)aString
{
    [self setExtraLineDashString:aString scaleFactor:1.0];
}

// Dash lengths in line widths.
- (void)setAndScaleExtraLineDashString:(id)aString
{
    [self setExtraLineDashString:aString scaleFactor:[self lineWidth]];
}

// Space separated dash lengths; an empty string clears the dash.
- (void)setExtraLineDashString:(id)aString scaleFactor:(CGFloat)aFactor
{
    NSArray *lengths = [aString componentsSeparatedByString:@" "];
    CGFloat *pattern = NULL;
    NSInteger count = 0;
    if (aString != nil && [aString length] != 0 && [lengths count] != 0) {
        count = [lengths count];
        pattern = malloc(count * sizeof(CGFloat));
        for (NSInteger i = 0; i < count; i++)
            pattern[i] = (float)([[lengths objectAtIndex:i] floatValue] * aFactor);
    }
    [self setLineDash:pattern count:count phase:0.0];
    if (pattern != NULL)
        free(pattern);
}

- (id)extraLineDashString
{
    NSInteger count = 0;
    CGFloat phase = 0.0;
    [self getLineDash:NULL count:&count phase:&phase];
    CGFloat *pattern = malloc(MAX(count, 1) * sizeof(CGFloat));
    float *floatPattern = malloc(MAX(count, 1) * sizeof(float));
    if (pattern == NULL || floatPattern == NULL) {
        free(pattern);
        free(floatPattern);
        return nil;
    }
    [self getLineDash:pattern count:&count phase:&phase];
    for (NSInteger i = 0; i < count; i++)
        floatPattern[i] = pattern[i];
    NSString *string = [[self class] extraStringRepresentationOfLineDashStyleRepresentationOfPattern:floatPattern count:count phase:phase];
    free(pattern);
    free(floatPattern);
    return string;
}

// An array of single-entry dictionaries, shape name to its SVG attributes.
// The shapes are added in turn, then the path is moved to the origin.
- (void)setExtraSVGRep:(id)aRep
{
    [self removeAllPoints];
    for (NSDictionary *shape in aRep) {
        id attributes;
        SEL adder = NULL;
        if ((attributes = [shape objectForKey:@"path"]) != nil)
            adder = @selector(addSVGPath:);
        else if ((attributes = [shape objectForKey:@"polygon"]) != nil)
            adder = @selector(addSVGPolygon:);
        else if ((attributes = [shape objectForKey:@"ellipse"]) != nil)
            adder = @selector(addSVGEllipse:);
        else if ((attributes = [shape objectForKey:@"circle"]) != nil)
            adder = @selector(addSVGCircle:);
        else if ((attributes = [shape objectForKey:@"rect"]) != nil)
            adder = @selector(addSVGRect:);
        else if ((attributes = [shape objectForKey:@"line"]) != nil)
            adder = @selector(addSVGLine:);
        else if ((attributes = [shape objectForKey:@"polyline"]) != nil)
            adder = @selector(addSVGPolyline:);
        if (adder != NULL)
            [self performSelector:adder withObject:attributes];
        [self setExtraSVGAttributes:attributes];
    }
    [self extraCanonizeWithScaling:NO appliedTransform:nil];
}

// Only ever loaded.
- (id)extraSVGRep
{
    return nil;
}

- (void)setExtraSVGAttributes:(id)aAttributes
{
    id dashArray = [aAttributes objectForKey:@"stroke-dasharray"];
    if (dashArray != nil)
        [self setExtraLineDashString:dashArray];
    id strokeWidth = [aAttributes objectForKey:@"stroke-width"];
    if (strokeWidth != nil)
        [self setLineWidth:[strokeWidth floatValue]];
}

- (void)addSVGLine:(id)aLine
{
    id x1 = [aLine objectForKey:@"x1"];
    if (x1 == nil)
        return;
    id y1 = [aLine objectForKey:@"y1"];
    if (y1 == nil)
        return;
    [self moveToPoint:NSMakePoint([x1 floatValue], [y1 floatValue])];
    id x2 = [aLine objectForKey:@"x2"];
    if (x2 == nil)
        return;
    id y2 = [aLine objectForKey:@"y2"];
    if (y2 != nil)
        [self lineToPoint:NSMakePoint([x2 floatValue], [y2 floatValue])];
}

- (void)addSVGCircle:(id)aCircle
{
    NSRect rect = NSZeroRect;
    id value;
    if ((value = [aCircle objectForKey:@"cx"]) != nil)
        rect.origin.x = [value floatValue];
    if ((value = [aCircle objectForKey:@"cy"]) != nil)
        rect.origin.y = [value floatValue];
    if ((value = [aCircle objectForKey:@"r"]) != nil) {
        float radius = [value floatValue];
        rect.size.width = radius + radius;
        rect.size.height = rect.size.width;
        rect = NSOffsetRect(rect, -radius, -radius);
    }
    if (!NSIsEmptyRect(rect)) {
        [self appendBezierPathWithOvalInRect:rect];
        [self hyperClosePath];
    }
}

// The rect's own transform (six numbers, as in "matrix(a b c d tx ty)")
// applies to it alone.
- (void)addSVGRect:(id)aRect
{
    NSRect rect = NSZeroRect;
    id value;
    if ((value = [aRect objectForKey:@"x"]) != nil)
        rect.origin.x = [value floatValue];
    if ((value = [aRect objectForKey:@"y"]) != nil)
        rect.origin.y = [value floatValue];
    if ((value = [aRect objectForKey:@"width"]) != nil)
        rect.size.width = [value floatValue];
    if ((value = [aRect objectForKey:@"height"]) != nil)
        rect.size.height = [value floatValue];
    if (NSIsEmptyRect(rect))
        return;
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:rect.origin];
    [path lineToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) + NSHeight(rect))];
    [path lineToPoint:NSMakePoint(NSMinX(rect) + NSWidth(rect), NSMinY(rect) + NSHeight(rect))];
    [path lineToPoint:NSMakePoint(NSMinX(rect) + NSWidth(rect), NSMinY(rect))];
    [path lineToPoint:rect.origin];
    [path hyperClosePath];
    id transformString = [aRect objectForKey:@"transform"];
    if (transformString != nil) {
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        NSArray *values = [transformString nodeTreeWithCurrentRecurseLevel:0 characterSets:[NSArray arrayWithObject:numbers]];
        if ([values count] != 0) {
            NSAffineTransform *transform = [NSAffineTransform transform];
            NSAffineTransformStruct matrix = [transform transformStruct];
            NSEnumerator *enumerator = [values objectEnumerator];
            matrix.m11 = (float)HSSVGNextValue(enumerator);
            matrix.m12 = (float)HSSVGNextValue(enumerator);
            matrix.m21 = (float)HSSVGNextValue(enumerator);
            matrix.m22 = (float)HSSVGNextValue(enumerator);
            matrix.tX = (float)HSSVGNextValue(enumerator);
            matrix.tY = (float)HSSVGNextValue(enumerator);
            [transform setTransformStruct:matrix];
            [path transformUsingAffineTransform:transform];
        }
    }
    [self appendBezierPath:path];
}

- (void)addSVGEllipse:(id)aEllipse
{
    NSRect rect = NSZeroRect;
    id value;
    if ((value = [aEllipse objectForKey:@"cx"]) != nil)
        rect.origin.x = [value floatValue];
    if ((value = [aEllipse objectForKey:@"cy"]) != nil)
        rect.origin.y = [value floatValue];
    if ((value = [aEllipse objectForKey:@"rx"]) != nil)
        rect.size.width = [value floatValue];
    if ((value = [aEllipse objectForKey:@"ry"]) != nil)
        rect.size.height = [value floatValue];
    if (NSIsEmptyRect(rect))
        return;
    rect = NSOffsetRect(rect, -NSWidth(rect), -NSHeight(rect));
    rect.size.width += rect.size.width;
    rect.size.height += rect.size.height;
    [self appendBezierPathWithOvalInRect:rect];
    [self hyperClosePath];
}

- (void)addSVGPolyline:(id)aPolyline
{
    [self addSVGPolyline:aPolyline closePath:NO];
}

- (void)addSVGPolygon:(id)aPolygon
{
    [self addSVGPolyline:aPolygon closePath:YES];
}

// "points": x y pairs.
- (void)addSVGPolyline:(id)aPolyline closePath:(BOOL)aPath
{
    id points = [aPolyline objectForKey:@"points"];
    if (points == nil)
        return;
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSArray *values = [points nodeTreeWithCurrentRecurseLevel:0 characterSets:[NSArray arrayWithObject:numbers]];
    NSEnumerator *enumerator = [values objectEnumerator];
    NSUInteger pairCount = [values count] / 2;
    NSPoint first = HSSVGNextPoint(enumerator);
    [self moveToPoint:first];
    for (NSUInteger i = 1; i < pairCount; i++)
        [self lineToPoint:HSSVGNextPoint(enumerator)];
    if (aPath) {
        [self lineToPoint:first];
        [self hyperClosePath];
    }
}

- (void)addSVGPath:(id)aPath
{
    id data = [aPath objectForKey:@"d"];
    if (data != nil)
        [self addSVGPathString:data];
}

// One set of arguments per command (repeated sets are not read); arcs and
// quadratic curves are not supported.
- (void)addSVGPathString:(id)aString
{
    NSCharacterSet *commands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlHhVvCcSsZz"];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSArray *nodes = [aString nodeTreeWithCurrentRecurseLevel:0 characterSets:[NSArray arrayWithObjects:commands, numbers, nil]];
    for (id node in nodes) {
        if (![node respondsToSelector:@selector(lastObject)]) {
            // a command without arguments
            if ([node length] != 0) {
                unichar command = [node characterAtIndex:0];
                if (command == 'Z' || command == 'z')
                    [self hyperClosePath];
            }
            continue;
        }
        NSString *commandString = [node lastObject];
        NSEnumerator *arguments = [node objectEnumerator];
        if ([commandString length] == 0)
            continue;
        switch ([commandString characterAtIndex:0]) {
        case 'M':
            [self moveToPoint:HSSVGNextPoint(arguments)];
            break;
        case 'm':
            [self relativeMoveToPoint:HSSVGNextPoint(arguments)];
            break;
        case 'L':
            [self lineToPoint:HSSVGNextPoint(arguments)];
            break;
        case 'l':
            [self relativeLineToPoint:HSSVGNextPoint(arguments)];
            break;
        case 'H': {
            NSPoint base = [self hyperBasePointOfElementAtIndex:[self elementCount] - 1];
            NSPoint point = HSSVGNextPoint(arguments);
            [self lineToPoint:NSMakePoint(point.x, base.y)];
            break;
        }
        case 'h':
            [self relativeLineToPoint:NSMakePoint(HSSVGNextPoint(arguments).x, 0.0)];
            break;
        case 'V': {
            NSPoint base = [self hyperBasePointOfElementAtIndex:[self elementCount] - 1];
            NSPoint point = HSSVGNextPoint(arguments);
            [self lineToPoint:NSMakePoint(base.x, point.x)];
            break;
        }
        case 'v':
            [self relativeLineToPoint:NSMakePoint(0.0, HSSVGNextPoint(arguments).x)];
            break;
        case 'C': {
            NSPoint controlPoint1 = HSSVGNextPoint(arguments);
            NSPoint controlPoint2 = HSSVGNextPoint(arguments);
            NSPoint point = HSSVGNextPoint(arguments);
            [self curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            break;
        }
        case 'c': {
            NSPoint controlPoint1 = HSSVGNextPoint(arguments);
            NSPoint controlPoint2 = HSSVGNextPoint(arguments);
            NSPoint point = HSSVGNextPoint(arguments);
            [self relativeCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            break;
        }
        case 'S': {
            // the first control point reflects the previous curve's second
            // one (or is the current point)
            NSPoint controlPoint2 = HSSVGNextPoint(arguments);
            NSPoint point = HSSVGNextPoint(arguments);
            NSPoint previous[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSPoint controlPoint1;
            if ([self hyperElementAtIndex:[self elementCount] - 1 associatedPoints:previous] == NSCurveToBezierPathElement)
                controlPoint1 = NSMakePoint(previous[0].x + previous[0].x - previous[2].x, previous[0].y + previous[0].y - previous[2].y);
            else
                controlPoint1 = previous[0];
            [self curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            break;
        }
        case 's': {
            NSPoint controlPoint2 = HSSVGNextPoint(arguments);
            NSPoint point = HSSVGNextPoint(arguments);
            NSPoint previous[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSPoint controlPoint1 = NSZeroPoint;
            if ([self hyperElementAtIndex:[self elementCount] - 1 associatedPoints:previous] == NSCurveToBezierPathElement)
                controlPoint1 = NSMakePoint(previous[0].x + previous[0].x - previous[2].x - previous[0].x,
                                            previous[0].y + previous[0].y - previous[2].y - previous[0].y);
            [self relativeCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            break;
        }
        default:
            break;
        }
    }
}

// The extraPathString form: space separated "M x y", "L x y",
// "C x1 y1 x2 y2 x y" and "Z"; replaces the path's elements.
- (void)setExtraPathString:(id)aString
{
    if (aString == nil)
        return;
    [self removeAllPoints];
    NSEnumerator *tokens = [[aString componentsSeparatedByString:@" "] objectEnumerator];
    NSString *token;
    while ((token = [tokens nextObject]) != nil) {
        if ([token length] == 0)
            continue;
        switch ([token characterAtIndex:0]) {
        case 'M':
            [self moveToPoint:HSSVGNextPoint(tokens)];
            break;
        case 'L':
            [self lineToPoint:HSSVGNextPoint(tokens)];
            break;
        case 'C': {
            NSPoint controlPoint1 = HSSVGNextPoint(tokens);
            NSPoint controlPoint2 = HSSVGNextPoint(tokens);
            NSPoint point = HSSVGNextPoint(tokens);
            [self curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            break;
        }
        case 'Z':
            [self hyperClosePath];
            break;
        default:
            break;
        }
    }
}

- (id)extraPathString
{
    NSMutableString *string = [NSMutableString string];
    for (NSInteger i = 0; i < [self elementCount]; i++) {
        NSPoint points[3];
        switch ([self elementAtIndex:i associatedPoints:points]) {
        case NSMoveToBezierPathElement:
            [string appendFormat:@" M %f %f", (double)(float)points[0].x, (double)(float)points[0].y];
            break;
        case NSLineToBezierPathElement:
            [string appendFormat:@" L %f %f", (double)(float)points[0].x, (double)(float)points[0].y];
            break;
        case NSCurveToBezierPathElement:
            [string appendFormat:@" C %f %f %f %f %f %f", (double)(float)points[0].x, (double)(float)points[0].y,
                (double)(float)points[1].x, (double)(float)points[1].y, (double)(float)points[2].x, (double)(float)points[2].y];
            break;
        case NSClosePathBezierPathElement:
            [string appendString:@" Z"];
            break;
        default:
            break;
        }
    }
    if ([string length] != 0)
        [string deleteCharactersInRange:NSMakeRange(0, 1)];
    return string;
}

// Moves the path's bounds to the origin, and with scaling also to 100 x 100;
// the transform used is appended to aTransform.
- (id)extraCanonizeWithScaling:(BOOL)aScaling appliedTransform:(id)aTransform
{
    if ([self elementCount] == 0)
        return self;
    NSRect bounds = [self bounds];
    if (fabs(NSMinX(bounds)) <= 0.001 && fabs(NSMinY(bounds)) <= 0.001 && fabs(NSWidth(bounds) - 100.0) <= 0.001
        && fabs(NSHeight(bounds) - 100.0) <= 0.001)
        return self;
    if ([self elementCount] < 2)
        return self;
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:-NSMinX(bounds) yBy:-NSMinY(bounds)];
    if (!aScaling) {
        [self transformUsingAffineTransform:transform];
        [aTransform appendTransform:transform];
        return self;
    }
    [transform scaleXBy:100.0 / NSWidth(bounds) yBy:100.0 / NSHeight(bounds)];
    [self transformUsingAffineTransform:transform];
    [aTransform appendTransform:transform];
    return [self extraCanonizeWithScaling:aScaling appliedTransform:aTransform];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:@"extraSVGRep"];
}

// A style copy leaves out the path itself.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        return [NSArray arrayWithObjects:@"extraLineDashString", @"lineWidth", @"lineCapStyle", @"lineJoinStyle", @"miterLimit",
                                         @"flatness", nil];
    return [NSArray arrayWithObjects:@"extraPathString", @"extraLineDashString", @"lineWidth", @"lineCapStyle", @"lineJoinStyle",
                                     @"miterLimit", @"flatness", nil];
}

@end

@implementation NSBezierPath (HSExtensions)

// Corner arcs centred inside the rect by the radius.
+ (id)hyperRoundedBorderPathWithRect:(NSRect)aRect cornerRadius:(CGFloat)aRadius
{
    NSRect inner = NSInsetRect(aRect, aRadius, aRadius);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(inner), NSMinY(inner)) radius:aRadius startAngle:180.0 endAngle:270.0 clockwise:NO];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(inner) + NSWidth(inner), NSMinY(inner)) radius:aRadius startAngle:270.0 endAngle:360.0 clockwise:NO];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(inner) + NSWidth(inner), NSMinY(inner) + NSHeight(inner)) radius:aRadius startAngle:0.0 endAngle:90.0 clockwise:NO];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(inner), NSMinY(inner) + NSHeight(inner)) radius:aRadius startAngle:90.0 endAngle:180.0 clockwise:NO];
    [path closePath];
    return path;
}

+ (id)hyperBezierPathWithString:(id)aString
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setExtraPathString:aString];
    return path;
}

// Starts with a move to the base point of the range's first element.
- (id)hyperSubpathForElementRange:(NSRange)aRange
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:[self hyperBasePointOfElementAtIndex:aRange.location]];
    for (NSUInteger i = aRange.location + 1; i < NSMaxRange(aRange); i++) {
        NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
        NSBezierPathElement element = [self hyperElementAtIndex:i associatedPoints:points];
        [path hyperAppendElement:element associatedPoints:points];
    }
    return path;
}

// The direction (radians) from the element's base point toward the next
// element's (or, for the last one, the previous one's), or toward the
// control point between them when a curve's is distinct.
- (CGFloat)hyperInclineAngleOfElementAtIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    NSPoint other[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    NSUInteger otherIndex = aIndex + 1;
    if (otherIndex >= (NSUInteger)[self elementCount]) {
        if (aIndex == 0)
            return 0.0;
        otherIndex = aIndex - 1;
    }
    NSBezierPathElement element = [self hyperElementAtIndex:aIndex associatedPoints:points];
    NSBezierPathElement otherElement = [self hyperElementAtIndex:otherIndex associatedPoints:other];
    NSPoint target;
    if (aIndex < otherIndex && otherElement == NSCurveToBezierPathElement && !NSEqualPoints(points[0], other[1]))
        target = other[1];
    else
        target = other[0];
    if (element == NSCurveToBezierPathElement && otherIndex < aIndex && !NSEqualPoints(points[0], points[2]))
        target = points[2];
    return (float)atan2((float)(target.y - points[0].y), (float)(target.x - points[0].x));
}

// Points in hyper order.
- (void)setHyperAssociatedPoints:(NSPoint *)aPoints atIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = { aPoints[0], aPoints[1], aPoints[2] };
    if ([self elementAtIndex:aIndex] == NSCurveToBezierPathElement) {
        points[0] = aPoints[1];
        points[1] = aPoints[2];
        points[2] = aPoints[0];
    }
    [self setAssociatedPoints:points atIndex:aIndex];
}

// The element's end point.
- (NSPoint)hyperBasePointOfElementAtIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [self hyperElementAtIndex:aIndex associatedPoints:points];
    return points[0];
}

// elementAtIndex:associatedPoints: with the points in hyper order.
- (NSUInteger)hyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints
{
    NSBezierPathElement element = [self elementAtIndex:aIndex associatedPoints:aPoints];
    if (aPoints != NULL && element == NSCurveToBezierPathElement) {
        NSPoint controlPoint1 = aPoints[0];
        aPoints[0] = aPoints[2];
        aPoints[2] = aPoints[1];
        aPoints[1] = controlPoint1;
    }
    return element;
}

- (void)hyperAppendElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints
{
    switch (aElement) {
    case NSMoveToBezierPathElement:
        [self moveToPoint:aPoints[0]];
        break;
    case NSLineToBezierPathElement:
        [self lineToPoint:aPoints[0]];
        break;
    case NSCurveToBezierPathElement:
        [self curveToPoint:aPoints[0] controlPoint1:aPoints[1] controlPoint2:aPoints[2]];
        break;
    case NSClosePathBezierPathElement:
        [self hyperClosePath];
        break;
    default:
        break;
    }
}

// No line to where the path already is.
- (void)hyperLineToPoint:(NSPoint)aPoint
{
    NSPoint current = [self hyperBasePointOfElementAtIndex:[self elementCount] - 1];
    if (!NSEqualPoints(current, aPoint))
        [self lineToPoint:aPoint];
}

// Draws the closing line explicitly (to the start of the last subpath) before
// closing.
- (void)hyperClosePath
{
    NSInteger count = [self elementCount];
    if (count <= 0)
        return;
    NSPoint start = [self hyperBasePointOfElementAtIndex:0];
    for (NSInteger i = count - 1; i >= 1; i--) {
        if ([self elementAtIndex:i] == NSClosePathBezierPathElement) {
            start = [self hyperBasePointOfElementAtIndex:i + 1];
            break;
        }
    }
    if (!NSEqualPoints(start, [self hyperBasePointOfElementAtIndex:count - 1]))
        [self lineToPoint:start];
    [self closePath];
}

- (void)hyperCopyVisualAttributesFrom:(id)aFrom
{
    if (aFrom == nil)
        return;
    [self setLineWidth:[aFrom lineWidth]];
    [self setLineCapStyle:[aFrom lineCapStyle]];
    [self setLineJoinStyle:[aFrom lineJoinStyle]];
    [self setMiterLimit:[aFrom miterLimit]];
    [self setFlatness:[aFrom flatness]];
    NSInteger count = 0;
    CGFloat phase = 0.0;
    [aFrom getLineDash:NULL count:&count phase:&phase];
    CGFloat *pattern = malloc(MAX(count, 1) * sizeof(CGFloat));
    if (pattern != NULL) {
        [aFrom getLineDash:pattern count:&count phase:&phase];
        [self setLineDash:pattern count:count phase:phase];
        free(pattern);
    }
}

- (NSRect)hyperVisualBounds
{
    return [self hyperVisualBoundsForElementRange:NSMakeRange(0, [self elementCount])];
}

// The stroked bounds of a range of elements. With miter joins the straight
// segments are measured one by one: each as the rect of the line widened
// across its direction, plus the miter at the join to the next element.
// Curves (and every element with other joins) go into a path whose bounds
// are outset by half the line width. Line caps are added at the path's ends.
// Not finite or negative: NSZeroRect.
- (NSRect)hyperVisualBoundsForElementRange:(NSRange)aRange
{
    NSRect bounds = NSZeroRect;
    BOOL whole = aRange.location == 0 && (NSUInteger)[self elementCount] == aRange.length;
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    float lineWidth = [self lineWidth];
    NSBezierPath *curves = nil;
    if ([self lineJoinStyle] == NSMiterLineJoinStyle) {
        NSPoint lastCurveEnd = NSZeroPoint;
        for (NSUInteger k = 0; k < aRange.length; k++) {
            NSUInteger i = aRange.location + k;
            // the previous point, this element's point, the next point
            NSPoint corner[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSBezierPathElement element = [self hyperElementAtIndex:i associatedPoints:points];
            corner[1] = points[0];
            if (i == 0) {
                // a closed path's start joins its last segment
                NSInteger count = [self elementCount];
                if (count <= 3 || [self elementAtIndex:count - 2] != NSClosePathBezierPathElement)
                    continue;
                corner[0] = [self hyperBasePointOfElementAtIndex:count - 4];
            } else if (element == NSCurveToBezierPathElement && !NSEqualPoints(corner[1], points[2])) {
                corner[0] = points[2];
            } else {
                NSUInteger previous = i - 1;
                if (i != 1 && [self hyperElementAtIndex:i - 1 associatedPoints:NULL] == NSClosePathBezierPathElement)
                    previous = i - 2;
                corner[0] = [self hyperBasePointOfElementAtIndex:previous];
            }
            if (element != NSCurveToBezierPathElement) {
                float minX = MIN(corner[0].x, corner[1].x), maxX = MAX(corner[0].x, corner[1].x);
                float minY = MIN(corner[0].y, corner[1].y), maxY = MAX(corner[0].y, corner[1].y);
                float width = maxX - minX;
                float angle = atan2(maxY - minY, width);
                float c = cosf(angle);
                float s = sinf(angle);
                float length = width / c;
                NSRect segment = NSMakeRect(lineWidth * s * -0.5f + minX, lineWidth * c * -0.5f + minY,
                                            c * length + lineWidth * s, length * s + lineWidth * c);
                bounds = NSIsEmptyRect(bounds) ? segment : NSUnionRect(bounds, segment);
            }
            if (i + 1 < (NSUInteger)[self elementCount]) {
                NSBezierPathElement nextElement = [self hyperElementAtIndex:i + 1 associatedPoints:points];
                if (nextElement == NSCurveToBezierPathElement && !NSEqualPoints(corner[1], points[1])) {
                    // the miter toward the next curve's first control point
                    corner[2] = points[1];
                    NSSize offset = [self hyperMiterOffsetForPoints:corner];
                    float x = offset.width + corner[1].x, y = offset.height + corner[1].y;
                    float minX = MIN(NSMinX(bounds), x), maxX = MAX(x, NSMinX(bounds) + NSWidth(bounds));
                    float minY = MIN(NSMinY(bounds), y), maxY = MAX(y, NSMinY(bounds) + NSHeight(bounds));
                    bounds = NSMakeRect(minX, minY, maxX - minX, maxY - minY);
                } else {
                    corner[2] = points[0];
                    NSSize offset = [self hyperMiterOffsetForPoints:corner];
                    float x = offset.width + corner[1].x, y = offset.height + corner[1].y;
                    float minX = MIN(MIN(corner[0].x, corner[2].x), x), maxX = MAX(MAX(corner[2].x, corner[0].x), x);
                    float minY = MIN(MIN(corner[0].y, corner[2].y), y), maxY = MAX(MAX(corner[2].y, corner[0].y), y);
                    bounds = NSUnionRect(bounds, NSMakeRect(minX, minY, maxX - minX, maxY - minY));
                }
            }
            if (curves != nil && whole)
                continue;
            NSBezierPathElement kind = [self elementAtIndex:i];
            if (curves == nil) {
                if (whole) {
                    curves = self;
                    continue;
                }
                if (kind != NSCurveToBezierPathElement)
                    continue;
                curves = [NSBezierPath bezierPath];
            }
            if (kind == NSCurveToBezierPathElement) {
                NSPoint base = [self hyperBasePointOfElementAtIndex:i - 1];
                if (!NSEqualPoints(base, lastCurveEnd) || [curves elementCount] == 0)
                    [curves moveToPoint:base];
                [self hyperElementAtIndex:i associatedPoints:points];
                [curves hyperAppendElement:NSCurveToBezierPathElement associatedPoints:points];
                lastCurveEnd = points[0];
            }
        }
    } else if (aRange.length != 0) {
        if (whole) {
            curves = self;
        } else {
            curves = [NSBezierPath bezierPath];
            for (NSUInteger i = aRange.location; i < NSMaxRange(aRange); i++) {
                NSBezierPathElement element = [self hyperElementAtIndex:i associatedPoints:points];
                [curves hyperAppendElement:element associatedPoints:points];
            }
        }
    }
    if (curves != nil) {
        float outset = ceilf(lineWidth * 0.5f);
        NSRect curveBounds = NSInsetRect([curves bounds], -outset, -outset);
        bounds = NSIsEmptyRect(bounds) ? curveBounds : NSUnionRect(bounds, curveBounds);
    }
    if ([self lineCapStyle] != NSButtLineCapStyle && [self elementCount] >= 2
        && [self elementAtIndex:[self elementCount] - 2] != NSClosePathBezierPathElement) {
        if (aRange.location == 0)
            bounds = NSUnionRect(bounds, [self hyperLineCapRectForPointAtIndex:0]);
        if (NSMaxRange(aRange) == (NSUInteger)[self elementCount])
            bounds = NSUnionRect(bounds, [self hyperLineCapRectForPointAtIndex:[self elementCount] - 1]);
    }
    if (isfinite(NSMinX(bounds)) && isfinite(NSMinY(bounds)) && isfinite(NSWidth(bounds)) && isfinite(NSHeight(bounds))
        && NSWidth(bounds) >= 0.0 && NSHeight(bounds) >= 0.0)
        return bounds;
    return NSZeroRect;
}

// How far the outer corner of a miter join sticks out from the joint
// (points: previous, joint, next). Past the miter limit, or for a
// straight-through join, half the line width each way.
- (NSSize)hyperMiterOffsetForPoints:(NSPoint *)aPoints
{
    float lineWidth = [self lineWidth];
    float angleIn = atan2((float)(aPoints[1].y - aPoints[0].y), (float)(aPoints[1].x - aPoints[0].x));
    float angleOut = atan2((float)(aPoints[1].y - aPoints[2].y), (float)(aPoints[1].x - aPoints[2].x));
    float angleAcross = atan2((float)(aPoints[2].y - aPoints[0].y), (float)(aPoints[2].x - aPoints[0].x));
    float difference = angleOut - angleIn;
    float bisector = (angleOut + angleIn) * 0.5f;
    float turn = (float)(M_PI - (angleOut - angleAcross));
    float sign;
    if ((angleIn - angleAcross < 0.0f && (turn < 0.0f || difference < 0.0f)) || (difference < 0.0f && turn < 0.0f))
        sign = -1.0f;
    else
        sign = 1.0f;
    double angle = fabsf(difference);
    if (M_PI <= angle)
        angle = (M_PI + M_PI) - angle;
    float x, y;
    if ((double)((float)[self miterLimit] / 180.0f) * M_PI < angle) {
        float length = (lineWidth * 0.5f) / sinf(difference * 0.5f);
        x = cosf(bisector) * length;
        y = length * sinf(bisector);
    } else {
        x = y = lineWidth * 0.5f;
    }
    return NSMakeSize(x * sign, y * sign);
}

// The cap's rect at an end point: square caps reach half the line width past
// the end along the line, round ones are the half-width square around it,
// butt ones are the point itself.
- (NSRect)hyperLineCapRectForPointAtIndex:(NSUInteger)aIndex
{
    NSPoint point = [self hyperBasePointOfElementAtIndex:aIndex];
    float lineWidth = [self lineWidth];
    NSRect rect = { point, NSZeroSize };
    if ([self lineCapStyle] == NSSquareLineCapStyle) {
        NSUInteger otherIndex = [self elementAtIndex:aIndex] == NSMoveToBezierPathElement ? aIndex + 1 : aIndex - 1;
        NSPoint other = [self hyperBasePointOfElementAtIndex:otherIndex];
        float angle = atan2((float)(point.y - other.y), (float)(point.x - other.x));
        float c = cosf(angle);
        float s = sinf(angle);
        float sign = c * s < 0.0f ? -1.0f : 1.0f;
        NSRect cap;
        cap.origin.x = lineWidth * s * -0.5f * sign + point.x;
        cap.origin.y = lineWidth * c * -0.5f * sign + point.y;
        float width = (s * sign + c * 0.5f) * lineWidth;
        float height = (c * sign + s * 0.5f) * lineWidth;
        float dx = 0.0f, dy = 0.0f;
        if (width < 0.0f) {
            dx = width;
            width = -width;
        }
        if (height < 0.0f) {
            dy = height;
            height = -height;
        }
        cap.size = NSMakeSize(width, height);
        rect = NSOffsetRect(cap, dx, dy);
    } else if ([self lineCapStyle] == NSRoundLineCapStyle) {
        float outset = ceilf(lineWidth * 0.5f);
        rect = NSInsetRect(rect, -outset, -outset);
    }
    return rect;
}

// From the previous element's end point (skipping closes); 0 for the first
// element and for closes.
- (CGFloat)hyperLengthOfElementAtIndex:(NSInteger)aIndex
{
    if (aIndex == 0)
        return 0.0;
    NSPoint start = NSZeroPoint;
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    NSInteger i = aIndex;
    NSBezierPathElement element;
    do {
        i--;
        element = [self elementAtIndex:i associatedPoints:points];
        if (element == NSMoveToBezierPathElement || element == NSLineToBezierPathElement)
            start = points[0];
        else if (element == NSCurveToBezierPathElement)
            start = points[2];
    } while (element == NSClosePathBezierPathElement);
    element = [self elementAtIndex:aIndex associatedPoints:points];
    if (element == NSCurveToBezierPathElement)
        return (float)[self hyperCurveLength:start :points[0] :points[1] :points[2]];
    if (element == NSMoveToBezierPathElement || element == NSLineToBezierPathElement)
        return (float)[self hyperLineLength:start :points[0]];
    return 0.0;
}

// Along the flattened path; a close continues from the next subpath's start.
- (NSPoint)hyperPointAtLength:(CGFloat)aLength
{
    NSBezierPath *flattened = [self bezierPathByFlatteningPath];
    NSPoint result = NSZeroPoint;
    NSPoint point = NSZeroPoint;
    float length = aLength;
    float walked = 0.0f;
    for (NSInteger i = 0; i < [flattened elementCount]; i++) {
        float walkedMagnitude = walked != 0.0f ? fabsf(walked) : 1.0f;
        float lengthMagnitude = length != 0.0f ? fabsf(length) : 1.0f;
        if (!(MAX(lengthMagnitude, walkedMagnitude) * 0.0005f + length >= walked))
            break;
        NSBezierPathElement element = [flattened elementAtIndex:i associatedPoints:&point];
        if (element == NSMoveToBezierPathElement) {
            result = point;
            continue;
        }
        if (element != NSLineToBezierPathElement)
            [flattened elementAtIndex:++i associatedPoints:&point];
        float segment = [self hyperLineLength:result :point];
        if (walked + segment > length) {
            float ratio = (length - walked) / (segment - (length - walked));
            result.y = (result.y + point.y * ratio) / (ratio + 1.0f);
            result.x = (result.x + ratio * point.x) / (ratio + 1.0f);
            break;
        }
        result = point;
        walked += segment;
    }
    return result;
}

// Of the flattened path.
- (CGFloat)hyperLength
{
    NSBezierPath *flattened = [self bezierPathByFlatteningPath];
    NSPoint previous = NSZeroPoint;
    NSPoint point = NSZeroPoint;
    float length = 0.0f;
    for (NSInteger i = 0; i < [flattened elementCount]; i++) {
        NSBezierPathElement element = [flattened elementAtIndex:i associatedPoints:&point];
        if (element != NSMoveToBezierPathElement) {
            if (element != NSLineToBezierPathElement)
                [flattened elementAtIndex:++i associatedPoints:&point];
            length += [self hyperLineLength:previous :point];
        }
        previous = point;
    }
    return length;
}

// start, control point 1, control point 2, end
- (CGFloat)hyperCurveLength:(NSPoint)aLength :(NSPoint)aArg :(NSPoint)aArg2 :(NSPoint)aArg3
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:aLength];
    [path curveToPoint:aArg3 controlPoint1:aArg controlPoint2:aArg2];
    return (float)[path hyperLength];
}

- (CGFloat)hyperLineLength:(NSPoint)aLength :(NSPoint)aArg
{
    return hypotf((float)(aArg.x - aLength.x), (float)(aArg.y - aLength.y));
}

// A move and a line, or a move and a curve whose control points are at its
// end point.
- (BOOL)isHyperStraightLine
{
    if ([self elementCount] != 2)
        return NO;
    if ([self elementAtIndex:1] == NSLineToBezierPathElement)
        return YES;
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    if ([self hyperElementAtIndex:1 associatedPoints:points] != NSCurveToBezierPathElement)
        return NO;
    return HSBezierFloatsAreEqual(points[0].x, points[1].x) && HSBezierFloatsAreEqual(points[0].y, points[1].y)
        && HSBezierFloatsAreEqual(points[0].x, points[2].x) && HSBezierFloatsAreEqual(points[0].y, points[2].y);
}

// Closed paths end with a close and the move NSBezierPath adds after it.
- (BOOL)isHyperLastContourClosed
{
    NSInteger count = [self elementCount];
    if (count < 4)
        return NO;
    return [self elementAtIndex:count - 2] == NSClosePathBezierPathElement;
}

- (BOOL)isHyperEmpty
{
    if ([self elementCount] < ([self isHyperLastContourClosed] ? 6 : 2))
        return YES;
    return NSIsEmptyRect([self hyperVisualBounds]);
}

@end
