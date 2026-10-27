#import "HSImportDialogGraphicsBTCGImage.h"

@implementation HSImportDialogGraphicsBTCGImage

// The image at its pixel size, never cached.
- (id)initWithNSImage:(id)aImage
{
    if ((self = [super initWithNSImage:aImage])) {
        [aImage setCacheMode:NSImageCacheNever];
        [(NSImage *)aImage setSize:[aImage hyperPixelsSize]];
    }
    return self;
}

- (id)init
{
    return [self initWithNSImage:nil];
}

@end
