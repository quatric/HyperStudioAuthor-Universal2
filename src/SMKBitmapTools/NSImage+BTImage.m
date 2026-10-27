#import "NSImage+BTImage.h"
#import "NSImageRep_BTImage_BTCocoaImageRep.h"

@implementation NSImage (BTImage)

+ (id)BT_imageWithBTCocoaImage:(id)aImage
{
    NSImageRep *rep = [NSImageRep BT_imageRepWithBTCocoaImage:aImage];
    if (!rep)
        return nil;
    NSImage *image = [[[NSImage alloc] initWithSize:[aImage imageSize]] autorelease];
    [image addRepresentation:rep];
    return image;
}

+ (id)BT_imageWithBTCGImage:(id)aImage
{
    NSImageRep *rep = [NSImageRep BT_imageRepWithBTCGImage:aImage];
    if (!rep)
        return nil;
    NSImage *image = [[[NSImage alloc] initWithSize:[aImage imageSize]] autorelease];
    [image addRepresentation:rep];
    return image;
}

@end
