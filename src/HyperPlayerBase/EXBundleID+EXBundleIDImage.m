#import "EXBundleID+EXBundleIDImage.h"
@implementation EXBundleID (EXBundleIDImage)
+ (id)imageNamed:(id)aNamed
{
    NSImage *image = nil;
    @try {
        NSString *path = [[self bundle] pathForImageResource:aNamed];
        if (path != nil) {
            image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
            [image setName:aNamed];
        }
    }
    @catch (NSException *exception) {
        image = nil;
    }
    return image;
}
@end
