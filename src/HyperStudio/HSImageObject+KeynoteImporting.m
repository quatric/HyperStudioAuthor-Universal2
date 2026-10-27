#import "HSImageObject+KeynoteImporting.h"

@implementation HSImageObject (KeynoteImporting)

- (void)applyKeynoteGeometry:(id)aGeometry
{
    [super applyKeynoteGeometry:aGeometry];
    NSSize size = [(KeynoteGeometry *)aGeometry size];
    if (!NSEqualSizes([(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size], size)) {
        id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        [applier resizeFrameTo:size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
        [applier moveFrameBoundingRectOriginTo:[(KeynoteGeometry *)aGeometry origin] withLayoutGuidingContext:nil];
    }
}

// Images with a mask or alpha path are flattened through those clips into new media.
- (void)importFromKeynoteObject:(id)aObject
{
    id container = aObject;
    if ([aObject isKindOfClass:[KeynoteMedia class]])
        container = [aObject filteredImage];
    if ([container conformsToProtocol:@protocol(KeynoteImageContainer)]) {
        id media = [container media];
        NSBezierPath *alphaPath = [aObject alphaPath];
        NSBezierPath *maskPath = [aObject maskPath];
        BOOL noMask = maskPath == nil || [maskPath isEmpty];
        BOOL noAlpha = alphaPath == nil || [alphaPath isEmpty];
        if (!noAlpha || !noMask) {
            NSImage *source = [container image];
            NSSize size = [source size];
            NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];
            [image lockFocus];
            if (!noMask)
                [maskPath addClip];
            if (!noAlpha)
                [alphaPath addClip];
            [source drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [image unlockFocus];
            media = [HSNewMedia mediaWithImage:image name:[[container path] lastPathComponent]];
        }
        if (media != nil)
            [self setMedia:media];
    }
    [super importFromKeynoteObject:aObject];
}

@end
