#import "HSCICustomFilter.h"
// Core Image filter backed by a Quartz Composer composition. Subclasses
// return the composition from +customFilterPath. The composition's number
// and index inputs become scalar filter attributes, and its "outputImage"
// output is the filter's output image. The composition renders into a
// small offscreen window's OpenGL context.

@implementation HSCICustomFilter

+ (id)customFilterCategories
{
    return [NSArray array];
}

+ (id)customFilterDisplayName
{
    return [[NSBundle mainBundle] localizedStringForKey:[self customFilterName] value:@"" table:nil];
}

+ (id)customFilterName
{
    return [[[self customFilterPath] lastPathComponent] stringByDeletingPathExtension];
}

+ (id)customFilterPath
{
    return nil;
}

+ (id)filterWithName:(id)aName
{
    return [[self new] autorelease];
}

+ (void)initialize
{
    NSString *name = [self customFilterName];
    if ([name length])
        [CIFilter registerFilterName:name constructor:(id<CIFilterConstructor>)self classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[self customFilterDisplayName], kCIAttributeFilterDisplayName, [self customFilterCategories], kCIAttributeFilterCategories, nil]];
}

- (void)setValue:(id)aValue forKey:(id)aKey
{
    if ([[self customAttributes] objectForKey:aKey])
        [_renderer setValue:aValue forInputKey:aKey];
    else
        [super setValue:aValue forKey:aKey];
}

- (id)valueForKey:(id)aKey
{
    if ([[self customAttributes] objectForKey:aKey])
        return [_renderer valueForInputKey:aKey];
    return [super valueForKey:aKey];
}

// Filter attributes for the composition's number and index inputs, with
// the port's minimum and maximum as both the value and slider range.
- (id)customAttributes
{
    if (_customAttributes)
        return _customAttributes;
    NSDictionary *attributes = [_renderer attributes];
    if (![attributes count]) {
        // (The original doesn't keep this, so it's recreated on every call.)
        return [NSDictionary dictionary];
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[attributes count]];
    NSEnumerator *enumerator = [attributes keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        NSDictionary *port = [attributes objectForKey:key];
        if (![port isKindOfClass:[NSDictionary class]])
            continue;
        NSString *type = [port objectForKey:QCPortAttributeTypeKey];
        if (![type isEqualToString:QCPortTypeIndex] && ![type isEqualToString:QCPortTypeNumber])
            continue;
        NSMutableDictionary *attribute = [NSMutableDictionary new];
        id minimum = [port objectForKey:QCPortAttributeMinimumValueKey];
        if (minimum) {
            [attribute setObject:minimum forKey:kCIAttributeMin];
            [attribute setObject:minimum forKey:kCIAttributeSliderMin];
        }
        id maximum = [port objectForKey:QCPortAttributeMaximumValueKey];
        if (maximum) {
            [attribute setObject:maximum forKey:kCIAttributeMax];
            [attribute setObject:maximum forKey:kCIAttributeSliderMax];
        }
        [attribute setObject:kCIAttributeTypeScalar forKey:kCIAttributeType];
        [result setObject:attribute forKey:key];
        [attribute release];
    }
    _customAttributes = result;
    return _customAttributes;
}

// Renders the composition once. An NSCIImageRep output is used directly;
// anything else is drawn into a bitmap first.
- (id)outputImage
{
    if (!_window) {
        // (The original asks for a nonretained backing store, which is
        // always buffered on current systems.)
        _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 32, 32) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
        [_window setReleasedWhenClosed:NO];
        [_context setView:[_window contentView]];
    }
    [_context makeCurrentContext];
    [_renderer renderAtTime:0 arguments:nil];
    NSImage *image = [_renderer valueForOutputKey:@"outputImage"];
    if (!image)
        return nil;
    NSEnumerator *enumerator = [[image representations] objectEnumerator];
    id rep;
    while ((rep = [enumerator nextObject])) {
        if ([rep isKindOfClass:[NSCIImageRep class]])
            return [rep CIImage];
    }
    NSSize size = [image size];
    if (NSIsEmptyRect(NSMakeRect(0, 0, size.width, size.height)))
        return nil;
    long width = size.width > 0 ? lroundf(ceilf(size.width)) : 0;
    long height = size.height > 0 ? lroundf(ceilf(size.height)) : 0;
    size_t rowBytes = (width * 4 + 15) & ~15;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    if (!data)
        return nil;
    CFDataSetLength(data, rowBytes * height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, 8, rowBytes, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        CFRelease(data);
        return nil;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    [[[image representations] objectAtIndex:0] drawInRect:NSMakeRect(0, 0, width, height)];
    [NSGraphicsContext restoreGraphicsState];
    [pool release];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    if (!provider) {
        CGContextRelease(context);
        CFRelease(data);
        return nil;
    }
    CGImageRef cgImage = CGEImageCreateAsBitmapContext(context, provider, NULL, true, kCGRenderingIntentDefault);
    CGContextRelease(context);
    CGDataProviderRelease(provider);
    CFRelease(data);
    if (!cgImage)
        return nil;
    CIImage *result = [CIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return result;
}

- (void)setInputImage:(id)aImage
{
    if (_inputImage != aImage) {
        [_inputImage release];
        _inputImage = [aImage retain];
        [_renderer setValue:_inputImage forInputKey:@"inputImage"];
    }
}

- (id)inputImage
{
    return _inputImage;
}

- (void)dealloc
{
    [_inputImage release];
    [_renderer release];
    [_context clearDrawable];
    [_context release];
    [_window release];
    [_customAttributes release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAAccelerated, NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        0
    };
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    _context = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
    if (_context) {
        _renderer = [[QCRenderer alloc] initWithOpenGLContext:_context pixelFormat:format file:[[self class] customFilterPath]];
        if (_renderer) {
            [format release];
            return self;
        }
    }
    // (The original releases nil here and leaks the pixel format.)
    [format release];
    [self release];
    return nil;
}

@end
