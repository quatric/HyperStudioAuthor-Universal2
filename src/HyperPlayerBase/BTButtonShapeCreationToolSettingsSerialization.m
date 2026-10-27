#import "BTButtonShapeCreationToolSettingsSerialization.h"
// Paint tool settings read from a settings file: keys renamed to the tools'
// input keys, values converted to what the tools take (media by UID, CG
// colors, paths and images, packed float arrays).
@implementation BTToolSettingsSerialization
// The original wrapped the data in a CGDataProvider retaining it; an image
// source on the data itself is the same.
+ (struct CGImage *)imageWithData:(id)aData
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)aData, NULL);
    if (source == NULL)
        return NULL;
    CFAutorelease(source);
    NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldCache];
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, (CFDictionaryRef)options);
    if (image == NULL)
        return NULL;
    return (CGImageRef)CFAutorelease(image);
}
+ (struct CGImage *)loadImageAtPath:(id)aPath
{
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:aPath], NULL);
    if (source == NULL)
        return NULL;
    CFAutorelease(source);
    NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldCache];
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, (CFDictionaryRef)options);
    if (image == NULL)
        return NULL;
    return (CGImageRef)CFAutorelease(image);
}
// Media suffixes are dropped first, then the stored names map to the tools'.
- (id)inputKeyForKey:(id)aKey
{
    NSArray *suffixes = [NSArray arrayWithObjects:@"-imageUID", @"-dataUID", @"-hspathUID", @"FileName", nil];
    for (NSString *suffix in suffixes) {
        if ([aKey hasSuffix:suffix]) {
            aKey = [aKey substringToIndex:[aKey length] - [suffix length]];
            break;
        }
    }
    if ([aKey isEqualTo:@"path"])
        return @"shapePrototypePath";
    if ([aKey isEqualTo:@"colorizationMask"])
        return @"colorizationImage";
    if ([aKey isEqualTo:@"strokeWidth"])
        return @"lineWidth";
    if ([aKey isEqualTo:@"drawColor"])
        return @"strokeColor";
    if ([aKey isEqualTo:@"eraserSize"])
        return @"size";
    if ([aKey isEqualTo:@"eraserColor"])
        return @"alternateStrokeColor";
    if ([aKey isEqualTo:@"dynamicStrokeWidthAdjustmentFactor"])
        return @"shapeLineCount";
    return [super inputKeyForKey:aKey];
}
- (id)convertValue:(id)aValue forKey:(id)aKey
{
    BOOL isImage = [aKey hasSuffix:@"-imageUID"];
    BOOL isData = !isImage && [aKey hasSuffix:@"-dataUID"];
    BOOL isPath = !isImage && !isData && [aKey hasSuffix:@"-hspathUID"];
    if (isImage || isData || isPath) {
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:aValue]];
        if (media == nil)
            return nil;
        // keeps the media alive as long as the converted values
        if (_medias == nil)
            _medias = [NSMutableArray new];
        [_medias addObject:media];
        if (isImage) {
            CGImageRef image = [[self class] imageWithData:[media mediaData]];
            return [self convertValue:(id)image forKey:[aKey substringToIndex:[aKey length] - [@"-imageUID" length]]];
        }
        // (the original also created a static dictionary here that nothing used)
        if (isPath)
            return [(id)CGHyperPathCreateFromBinaryStoredData((CFDataRef)[media mediaData]) autorelease];
        return [media mediaData];
    }
    if ([aKey isEqual:@"size"] || [aKey isEqual:@"sizeOscillation"] || [aKey isEqual:@"positionOscillation"]
        || [aKey isEqual:@"shadowOffset"] || [aKey isEqual:@"eraserSize"])
        return [NSValue valueWithSize:[aValue extraSizeValue]];
    if ([aKey isEqual:@"drawColor"] || [aKey isEqual:@"fillColor"]) {
        CGEColorRef color = [aValue BT_coreGraphicsExtendedColor];
        if (color == NULL)
            return aValue;
        id wrapper = [BTPointer wrapperForPointer:color withDisposer:(void *)CGEColorRelease];
        if (wrapper != nil)
            CGEColorRetain(color);
        return wrapper;
    }
    if ([aValue respondsToSelector:@selector(BT_coreGraphicsColor)])
        return (id)[aValue BT_coreGraphicsColor];
    if ([aValue respondsToSelector:@selector(hyperCGPath)])
        return [(id)[aValue hyperCGPath] autorelease];
    if ([aKey isEqualTo:@"colorizationMask"] || [aKey isEqualTo:@"image"])
        return [[[BTCGImage alloc] initWithCGImage:(CGImageRef)aValue] autorelease];
    if ([aKey isEqualTo:@"colorHSVAOscillation"] || [aKey isEqualTo:@"colorNativeOscillation"]
        || [aKey isEqualTo:@"shadowColorHSVAOscillation"] || [aKey isEqualTo:@"shadowColorNativeOscillation"]) {
        // packed floats
        NSMutableData *data = [NSMutableData dataWithLength:[aValue count] * sizeof(float)];
        float *values = [data mutableBytes];
        for (id number in aValue)
            *values++ = [number floatValue];
        return data;
    }
    if ([aKey isEqualTo:@"overlays"]) {
        NSMutableArray *overlays = [NSMutableArray arrayWithCapacity:[aValue count]];
        for (NSDictionary *overlay in aValue) {
            NSMutableDictionary *converted = [NSMutableDictionary dictionaryWithCapacity:[overlay count]];
            for (NSString *key in overlay) {
                BOOL isOverlayImage = [key isEqualToString:@"overlayImage"];
                id value = [self convertValue:[overlay objectForKey:key] forKey:key];
                if (value != nil)
                    [converted setObject:value forKey:[self inputKeyForKey:isOverlayImage ? @"overlayImage" : key]];
            }
            [overlays addObject:converted];
        }
        return overlays;
    }
    return aValue;
}
- (void)dealloc
{
    [_medias release];
    [super dealloc];
}
@end
@implementation BTButtonShapeCreationToolSettingsSerialization
// Only the tolerance is read.
- (id)inputKeyForKey:(id)aKey
{
    return [aKey isEqualTo:@"selectionTolerance"] ? @"tolerance" : nil;
}
@end
@implementation BTShapeCreationToolSettingsSerialization
- (id)inputKeyForKey:(id)aKey
{
    if ([aKey isEqualTo:@"path"])
        return @"selectionShapePrototypePath";
    return [aKey isEqualTo:@"centeringOption"] ? @"centeringOption" : nil;
}
@end
@implementation BTFillToolSettingsSerialization
- (id)inputKeyForKey:(id)aKey
{
    if ([aKey isEqualTo:@"drawColor"])
        return @"fillColor";
    if ([aKey isEqualTo:@"eraserColor"])
        return @"alternateFillColor";
    if ([aKey isEqualTo:@"tolerance"])
        return @"selectionTolerance";
    return [super inputKeyForKey:aKey];
}
@end
@implementation BTEraserToolSettingsSerialization
- (id)inputKeyForKey:(id)aKey
{
    if ([aKey isEqualTo:@"eraserColor"])
        return @"color";
    return [super inputKeyForKey:aKey];
}
@end
@implementation BTBrushToolSettingsSerialization
- (id)inputKeyForKey:(id)aKey
{
    if ([aKey isEqualTo:@"drawColor"])
        return @"color";
    if ([aKey isEqualTo:@"eraserColor"])
        return @"alternateColor";
    return [super inputKeyForKey:aKey];
}
@end
