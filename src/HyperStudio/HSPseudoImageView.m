#import "HSPseudoImageView.h"

@implementation HSPseudoImageView

+ (id)bottomTextureImage
{
    static NSImage *sImage = nil;

    if (sImage == nil) {
        id path = [self pathForResource:@"PseudoWhellBottom" ofType:@"tiff"];
        if (path != nil)
            sImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return sImage;
}

+ (id)middleTextureImage
{
    static NSImage *sImage = nil;

    if (sImage == nil) {
        id path = [self pathForResource:@"PseudoWhellMiddle" ofType:@"tiff"];
        if (path != nil)
            sImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return sImage;
}

+ (id)topTextureImage
{
    static NSImage *sImage = nil;

    if (sImage == nil) {
        id path = [self pathForResource:@"PseudoWhellTop" ofType:@"tiff"];
        if (path != nil)
            sImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return sImage;
}

+ (id)pathForResource:(id)aResource ofType:(id)aType
{
    static NSBundle *sBundle = nil;

    if (sBundle == nil)
        sBundle = [NSBundle bundleForClass:self];
    return [sBundle pathForResource:aResource ofType:aType];
}

// Fails unless all three texture images exist.
- (id)initWithFrame:(NSRect)aFrame
{
    static const NSInteger kTypes[3] = { 1, 4, 7 };

    self = [super initWithFrame:aFrame];
    if (self != nil) {
        id images[3] = { [[self class] topTextureImage], [[self class] middleTextureImage], [[self class] bottomTextureImage] };
        NSUInteger i;

        for (i = 0; i < 3 && images[i] != nil; i++)
            [self setImage:images[i] forType:kTypes[i]];
        if (i == 3)
            return self;
    }
    [self release];
    return nil;
}

@end
