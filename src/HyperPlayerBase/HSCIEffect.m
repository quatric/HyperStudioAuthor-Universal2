#import "HSCIEffect.h"
#import "HSCoreGraphicsImageRep.h"
#import <Accelerate/Accelerate.h>

// _outputRepIsNSBitmapImageRep is bit 0 and _imageNormalization bit 1 of the shared flags byte.
@implementation HSCIEffect
+ (id)convertAttribute:(id)aAttribute forKey:(id)aKey
{
    if ([aKey isEqualToString:@"inputCenter"]) {
        NSPoint point = [aAttribute extraPointValue];
        aAttribute = [CIVector vectorWithX:point.x Y:point.y];
    }
    return aAttribute;
}
+ (id)effectsDescription
{
    static NSDictionary *sEffectsDescription;
    if (sEffectsDescription == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"CIEffects" ofType:@"plist"];
        if (path != nil)
            sEffectsDescription = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sEffectsDescription;
}
- (id)compositeOutputCIImage:(id)aImage
{
    return aImage;
}
- (id)cropImage:(id)aImage toRect:(CGRect)aRect
{
    if (aImage == nil || CGRectIsEmpty(aRect))
        return nil;
    CIFilter *filter = [self HSCIEffect_cropFilterForImage:aImage inputRect:aRect];
    return filter != nil ? [filter valueForKey:ciOutputImage] : nil;
}
- (id)effectImageForContextImage:(id)aImage
{
    return aImage != nil ? [self HSCIEffect_processImage:aImage] : nil;
}
- (void)setImageNormalization:(BOOL)aNormalization
{
    if ((aNormalization != NO) == (_imageNormalization != 0))
        return;
    _imageNormalization = aNormalization ? 1 : 0;
    [_outputImageRep release];
    _outputImageRep = nil;
}
- (BOOL)imageNormalization
{
    return _imageNormalization;
}
- (id)category
{
    return HSCIEffectsCategory;
}
- (struct CGImage *)outputCGImage
{
    NSImageRep *rep = [self HSCIEffect_outputImageRep];
    if (rep == nil)
        return NULL;
    if (!_outputRepIsNSBitmapImageRep) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSBitmapImageRep *bitmap = [NSBitmapImageRep hyperRGBA8888BitmapRepresentationFromImageRepresentation:rep];
        if (bitmap != nil) {
            [_outputImageRep release];
            _outputImageRep = [bitmap retain];
            _outputRepIsNSBitmapImageRep = 1;
        }
        [pool release];
        if (!_outputRepIsNSBitmapImageRep)
            return NULL;
        rep = _outputImageRep;
    }
    return [(NSBitmapImageRep *)rep hyperCGImage];
}
- (id)outputImage
{
    NSImageRep *rep = [self HSCIEffect_outputImageRep];
    if (rep == nil)
        return nil;
    NSImage *image = [[[NSImage alloc] initWithSize:[rep size]] autorelease];
    [image addRepresentation:rep];
    return image;
}
// CIColorControls keeps the alpha of the source as a separate mask (re-applied in
// HSCIEffect_outputImageRep); every other filter takes the image as is.
- (void)setInputImage:(id)aImage
{
    @try {
        CIImage *ciImage = nil;
        CGImageRef mask = NULL;
        NSEnumerator *reps = [[aImage representations] objectEnumerator];
        if ([[self name] isEqualToString:@"CIColorControls"]) {
            NSImageRep *rep = [aImage bestRepresentationForDevice:nil];
            if (rep == nil)
                goto apply;
            NSSize size = [rep size];
            NSInteger width = [rep pixelsWide];
            if (width == 0) {
                if (size.width == 0.0)
                    goto apply;
                width = size.width > 0.0 ? lroundf(ceilf(size.width)) : 0;
            }
            NSInteger height = [rep pixelsHigh];
            if (height == 0) {
                if (size.height == 0.0)
                    goto apply;
                height = size.height > 0.0 ? lroundf(ceilf(size.height)) : 0;
            }
            size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
            NSMutableData *data = [NSMutableData dataWithLength:rowBytes * height];
            void *bytes = [data mutableBytes];
            if (data == nil || bytes == NULL)
                goto apply;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            if ([(id)colorSpace autorelease] == nil)
                goto apply;
            CGContextRef context = CGBitmapContextCreate(bytes, width, height, 8, rowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
            if (context == NULL)
                goto apply;
            CGContextClearRect(context, CGRectMake(0, 0, width, height));
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
            if (graphicsContext == nil) {
                [pool release];
                CGContextRelease(context);
                goto apply;
            }
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:graphicsContext];
            BOOL drawn = [rep drawAtPoint:NSZeroPoint];
            [NSGraphicsContext restoreGraphicsState];
            [pool release];
            CGContextRelease(context);
            if (!drawn)
                goto apply;
            vImage_Buffer buffer = { bytes, (vImagePixelCount)height, (vImagePixelCount)width, rowBytes };
            vImageUnpremultiplyData_ARGB8888(&buffer, &buffer, 0);
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
            if (provider == NULL)
                goto apply;
            const CGFloat decode[2] = { 1.0, 0.0 };
            mask = CGImageMaskCreate(width, height, 8, 32, rowBytes, provider, decode, true);
            CGDataProviderRelease(provider);
            if ([(id)mask autorelease] == nil)
                goto apply;
            provider = CGDataProviderCreateWithCFData((CFDataRef)data);
            if (provider == NULL)
                goto apply;
            CGImageRef image = CGImageCreate(width, height, 8, 32, rowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst, provider, NULL, true, kCGRenderingIntentDefault);
            CGDataProviderRelease(provider);
            if (image != NULL) {
                ciImage = [[[CIImage allocWithZone:[self zone]] initWithCGImage:image] autorelease];
                CGImageRelease(image);
            }
        } else {
            NSImageRep *rep;
            NSBitmapImageRep *bitmap = nil;
            while ((rep = [reps nextObject]) != nil) {
                if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
                    bitmap = (NSBitmapImageRep *)rep;
                    break;
                }
                if ([rep isKindOfClass:[NSCIImageRep class]]) {
                    ciImage = [(NSCIImageRep *)rep CIImage];
                    // The original falls back to -initWithBitmapImageRep: with the NSCIImageRep itself.
                    if (ciImage == nil)
                        bitmap = (NSBitmapImageRep *)rep;
                    break;
                }
            }
            if (rep == nil)
                bitmap = [NSBitmapImageRep hyperRGBA8888BitmapRepresentationFromImageRepresentation:[aImage bestRepresentationForDevice:nil]];
            if (ciImage == nil && bitmap != nil)
                ciImage = [[[CIImage allocWithZone:[self zone]] initWithBitmapImageRep:bitmap] autorelease];
        }
    apply:
        if (ciImage != _inputImage) {
            CGImageRelease(_inputImageMask);
            _inputImageMask = CGImageRetain(mask);
            [_inputImage release];
            _inputImage = [ciImage retain];
            [_outputImageRep release];
            _outputImageRep = nil;
        }
    }
    @catch (NSException *exception) {
    }
}
- (id)name
{
    id name = nil;
    @try {
        name = [[_filter attributes] objectForKey:kCIAttributeFilterName];
    }
    @catch (NSException *exception) {
    }
    return name;
}
- (void)setDefaults
{
    @try {
        [_filter setDefaults];
        NSDictionary *defaults = [[[self class] effectsDescription] objectForKey:[self name]];
        NSEnumerator *keys = [defaults keyEnumerator];
        id key;
        while ((key = [keys nextObject]) != nil)
            [self setValue:[defaults objectForKey:key] forKey:key];
    }
    @catch (NSException *exception) {
    }
}
// Keys naming one of our own getters (outputImage, imageNormalization...) go to self, the rest to the filter.
- (id)valueForKey:(id)aKey
{
    id value = nil;
    @try {
        SEL selector = NSSelectorFromString(aKey);
        if (selector != NULL && [self respondsToSelector:selector])
            value = [self performSelector:selector];
        else
            value = [_filter valueForKey:aKey];
    }
    @catch (NSException *exception) {
    }
    return value;
}
- (void)setValue:(id)aValue forKey:(id)aKey
{
    @try {
        SEL selector = NSSelectorFromString(aKey);
        if (selector != NULL && [self respondsToSelector:selector]) {
            [super setValue:aValue forKey:aKey];
        } else {
            [_filter setValue:aValue forKey:aKey];
            [_outputImageRep release];
            _outputImageRep = nil;
        }
    }
    @catch (NSException *exception) {
    }
}
- (id)attributes
{
    id attributes = nil;
    @try {
        attributes = [_filter attributes];
    }
    @catch (NSException *exception) {
    }
    return attributes;
}
- (id)outputKeys
{
    NSArray *keys = [NSArray arrayWithObjects:@"outputImage", @"outputCGImage", nil];
    @try {
        NSArray *filterKeys = [_filter outputKeys];
        if ([filterKeys count])
            keys = [keys arrayByAddingObjectsFromArray:filterKeys];
    }
    @catch (NSException *exception) {
    }
    return keys;
}
- (id)inputKeys
{
    NSArray *keys = [NSArray arrayWithObject:@"imageNormalization"];
    @try {
        NSArray *filterKeys = [_filter inputKeys];
        if ([filterKeys count])
            keys = [keys arrayByAddingObjectsFromArray:filterKeys];
    }
    @catch (NSException *exception) {
    }
    return keys;
}
- (id)HSCIEffect_outputImageRep
{
    if (_inputImage == nil)
        return nil;
    if (_outputImageRep == nil) {
        CIImage *output = [self HSCIEffect_processImage:_inputImage];
        if (output != nil) {
            @try {
                _outputImageRep = [[NSCIImageRep alloc] initWithCIImage:output];
                if (_outputImageRep != nil) {
                    [_outputImageRep setSize:NSSizeFromCGSize([output extent].size)];
                    _outputRepIsNSBitmapImageRep = 0;
                }
            }
            @catch (NSException *exception) {
            }
        }
    }
    // Re-apply the source alpha kept by -setInputImage:.
    if (_outputImageRep != nil && _inputImageMask != NULL) {
        NSSize size = [_outputImageRep size];
        NSInteger width = [_outputImageRep pixelsWide];
        if (width == 0) {
            if (size.width == 0.0)
                return _outputImageRep;
            width = size.width > 0.0 ? lroundf(ceilf(size.width)) : 0;
        }
        NSInteger height = [_outputImageRep pixelsHigh];
        if (height == 0) {
            if (size.height == 0.0)
                return _outputImageRep;
            height = size.height > 0.0 ? lroundf(ceilf(size.height)) : 0;
        }
        size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
        NSMutableData *data = [NSMutableData dataWithLength:rowBytes * height];
        void *bytes = [data mutableBytes];
        if (data == nil || bytes == NULL)
            return _outputImageRep;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        if ([(id)colorSpace autorelease] == nil)
            return _outputImageRep;
        CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
        CGContextRef context = CGBitmapContextCreate(bytes, width, height, 8, rowBytes, colorSpace, bitmapInfo);
        if (context == NULL)
            return _outputImageRep;
        CGRect bounds = CGRectMake(0, 0, width, height);
        CGContextClearRect(context, bounds);
        CGContextClipToMask(context, bounds, _inputImageMask);
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
        if (graphicsContext == nil) {
            [pool release];
            CGContextRelease(context);
            return _outputImageRep;
        }
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphicsContext];
        BOOL drawn = [_outputImageRep drawAtPoint:NSZeroPoint];
        [NSGraphicsContext restoreGraphicsState];
        [pool release];
        CGContextRelease(context);
        if (drawn) {
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
            if (provider != NULL) {
                CGImageRef image = CGImageCreate(width, height, 8, 32, rowBytes, colorSpace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
                CGDataProviderRelease(provider);
                if (image != NULL) {
                    [_outputImageRep release];
                    _outputImageRep = [[HSCoreGraphicsImageRep alloc] initWithCoreGraphicsImage:image];
                    CGImageRelease(image);
                }
            }
        }
    }
    return _outputImageRep;
}
// With normalization the image is clamped to infinity first and the result cropped back to the input extent.
- (id)HSCIEffect_processImage:(id)aImage
{
    CIImage *output = nil;
    @try {
        if (_imageNormalization) {
            CIFilter *clamp = [self HSCIEffect_affineClampFilterForImage:aImage];
            if (clamp != nil) {
                [_filter setValue:[clamp valueForKey:ciOutputImage] forKey:ciInputImage];
                output = [_filter valueForKey:ciOutputImage];
            }
        }
        if (output == nil) {
            [_filter setValue:aImage forKey:ciInputImage];
            output = [_filter valueForKey:ciOutputImage];
        } else {
            CIFilter *crop = [self HSCIEffect_cropFilterForImage:output inputRect:[(CIImage *)aImage extent]];
            output = [crop valueForKey:ciOutputImage];
        }
    }
    @catch (NSException *exception) {
    }
    return [self compositeOutputCIImage:output];
}
- (id)HSCIEffect_affineClampFilterForImage:(id)aImage
{
    @try {
        if (_affineClampFilter == nil) {
            _affineClampFilter = [[CIFilter filterWithName:@"CIAffineClamp"] retain];
            [_affineClampFilter setValue:[NSAffineTransform transform] forKey:ciInputTransform];
        }
        [_affineClampFilter setValue:aImage forKey:ciInputImage];
    }
    @catch (NSException *exception) {
    }
    return _affineClampFilter;
}
- (id)HSCIEffect_cropFilterForImage:(id)aImage inputRect:(CGRect)aRect
{
    @try {
        if (_cropFilter == nil)
            _cropFilter = [[CIFilter filterWithName:@"CICrop"] retain];
        [_cropFilter setValue:aImage forKey:ciInputImage];
        [_cropFilter setValue:[CIVector vectorWithX:CGRectGetMinX(aRect) Y:CGRectGetMinY(aRect) Z:CGRectGetWidth(aRect) W:CGRectGetHeight(aRect)]
                       forKey:ciInputRectangle];
    }
    @catch (NSException *exception) {
    }
    return _cropFilter;
}
- (void)dealloc
{
    [_filter release];
    CGImageRelease(_inputImageMask);
    [_inputImage release];
    [_cropFilter release];
    [_affineClampFilter release];
    [_previewImage release];
    [_outputImageRep release];
    [super dealloc];
}
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self != nil) {
        _filter = [[CIFilter filterWithName:aName] retain];
        if (_filter != nil)
            return self;
    }
    [super release];
    return nil;
}
@end
