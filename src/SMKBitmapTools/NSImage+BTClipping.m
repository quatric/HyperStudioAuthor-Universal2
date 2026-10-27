#import "NSImage+BTClipping.h"

@implementation NSImage (BTClipping)

// The part inside aPath, the size of its integral bounds.
- (id)BT_imageByCroppingWithBezierPath:(id)aPath antialiased:(BOOL)aAntialiased
{
    NSImage *cropped = nil;
    [self NSImage_BTClipping_cutOutBezierPath:aPath antialiased:aAntialiased intoImage:&cropped resultImage:NULL];
    return [cropped autorelease];
}

// The image with aPath's inside cleared; the inside goes in *aImage.
- (id)BT_imageByCuttingOutBezierPath:(id)aPath antialiased:(BOOL)aAntialiased intoImage:(id *)aImage
{
    NSImage *result = nil;
    [self NSImage_BTClipping_cutOutBezierPath:aPath antialiased:aAntialiased intoImage:aImage resultImage:&result];
    if (aImage)
        [*aImage autorelease];
    return [result autorelease];
}

// Both images are returned retained.
- (void)NSImage_BTClipping_cutOutBezierPath:(id)aPath antialiased:(BOOL)aAntialiased intoImage:(id *)aImage resultImage:(id *)aImage2
{
    NSRect bounds = NSIntegralRect([aPath bounds]);
    NSImage *inside = [[NSImage alloc] initWithSize:bounds.size];
    if (inside) {
        [inside lockFocus];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:-bounds.origin.x yBy:-bounds.origin.y];
        [transform concat];
        [[NSGraphicsContext currentContext] setShouldAntialias:aAntialiased];
        [aPath addClip];
        [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1];
        [inside unlockFocus];
        if (aImage)
            *aImage = inside;
        else
            [inside release];
    }
    NSSize size = [self size];
    NSBezierPath *outside = [aPath bezierPathByReversingPath];
    [outside appendBezierPathWithRect:NSMakeRect(0, 0, size.width, size.height)];
    NSImage *rest = [[NSImage alloc] initWithSize:size];
    if (rest) {
        [rest lockFocus];
        [[NSGraphicsContext currentContext] setShouldAntialias:aAntialiased];
        [outside addClip];
        [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1];
        [rest unlockFocus];
        if (aImage2)
            *aImage2 = rest;
        else
            [rest release];
    }
}

@end
