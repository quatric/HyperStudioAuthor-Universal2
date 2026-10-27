#import "BTNSImage.h"
#import "BTMutableCGImageUndoer.h"

// An NSImage as a BTImage; edits go through -lockFocus.

@implementation BTNSImage

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithNSImage:(id)aImage
{
    self = [super init];
    if (!self)
        return nil;
    _image = [aImage retain];
    return self;
}

- (void)dealloc
{
    [_imageContext release];
    [_image release];
    [super dealloc];
}

- (CGSize)imageSize
{
    return NSSizeToCGSize([_image size]);
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [_image drawInRect:aRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [_image drawAtPoint:aPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:aContext flipped:NO];
    if (context) {
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];
        [_image drawInRect:NSRectFromCGRect(aRect) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver
                  fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    }
    [pool release];
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:aContext flipped:NO];
    if (context) {
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];
        [_image drawAtPoint:NSPointFromCGPoint(aPoint) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver
                   fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    }
    [pool release];
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return NULL;
}

- (struct CGImage *)coreGraphicsImage
{
    return NULL;
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (!BTIsImagePoint(self, aPoint))
        return NULL;
    return (CGColorRef)CFAutorelease(BTCopyColorFromCGImage(self, aPoint));
}

- (id)createImageUndoerWithDelegate:(id)aDelegate
{
    return [[BTMutableCGImageUndoer allocWithZone:[self zone]] initWithImage:self delegate:aDelegate];
}

- (void)beginCocoaEditing
{
    [_image lockFocus];
    _imageContext = [[NSGraphicsContext currentContext] retain];
}

- (void)endCocoaEditing
{
    [_imageContext release];
    _imageContext = nil;
    [_image unlockFocus];
}

- (void)beginCGEditing
{
    [self beginCocoaEditing];
}

- (struct CGContext *)imageCGContext
{
    return [_imageContext CGContext];
}

- (void)endCGEditing
{
    [self endCocoaEditing];
}

@end
