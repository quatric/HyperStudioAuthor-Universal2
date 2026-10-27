#import "NSImageRep_BTImage_BTCocoaImageRep.h"

// Image reps that draw a BTImage, so it can go in an NSImage.

@implementation NSImageRep_BTImage_BTCocoaImageRep

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithBTCocoaImage:(id)aImage
{
    self = [super init];
    if (!self)
        return nil;
    _cocoaImage = [aImage retain];
    [super setSize:NSSizeFromCGSize([_cocoaImage imageSize])];
    return self;
}

- (void)dealloc
{
    [_cocoaImage release];
    [super dealloc];
}

- (BOOL)draw
{
    [_cocoaImage drawInCurrentNSGraphicsContextAtPoint:NSZeroPoint];
    return YES;
}

@end

@implementation NSImageRep_BTImage_BTCGImageRep

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithBTCGImage:(id)aImage
{
    self = [super init];
    if (!self)
        return nil;
    _coreGraphicsImage = [aImage retain];
    [super setSize:NSSizeFromCGSize([_coreGraphicsImage imageSize])];
    return self;
}

- (void)dealloc
{
    [_coreGraphicsImage release];
    [super dealloc];
}

- (BOOL)draw
{
    [_coreGraphicsImage drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:CGPointZero];
    return YES;
}

@end

@implementation NSImageRep (BTImage)

+ (id)BT_imageRepWithBTCocoaImage:(id)aImage
{
    return [[[NSImageRep_BTImage_BTCocoaImageRep alloc] initWithBTCocoaImage:aImage] autorelease];
}

+ (id)BT_imageRepWithBTCGImage:(id)aImage
{
    return [[[NSImageRep_BTImage_BTCGImageRep alloc] initWithBTCGImage:aImage] autorelease];
}

@end
