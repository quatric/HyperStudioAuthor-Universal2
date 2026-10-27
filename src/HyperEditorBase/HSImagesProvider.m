#import "HSImagesProvider.h"

@implementation HSImagesProvider

+ (id)sharedImagesProvider
{
    static id provider;
    if (provider == nil)
        provider = [[HSImagesProvider alloc] init];
    return provider;
}

// Looked up in the given bundle, then the main bundle, then this
// framework.
- (id)imageForName:(id)aName ofType:(id)aType inDirectory:(id)aDirectory inBundle:(id)aBundle
{
    NSString *path = nil;
    if ([aDirectory length] != 0) {
        if (aBundle != nil)
            path = [aBundle pathForResource:aName ofType:aType inDirectory:aDirectory];
        if (path == nil)
            path = [[NSBundle mainBundle] pathForResource:aName ofType:aType inDirectory:aDirectory];
        if (path == nil)
            path = [[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:aType inDirectory:aDirectory];
    } else {
        if (aBundle != nil)
            path = [aBundle pathForResource:aName ofType:aType];
        if (path == nil)
            path = [[NSBundle mainBundle] pathForResource:aName ofType:aType];
        if (path == nil)
            path = [[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:aType];
    }
    if (path == nil)
        return nil;
    return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

- (id)imageForName:(id)aName ofType:(id)aType inDirectory:(id)aDirectory
{
    return [self imageForName:aName ofType:aType inDirectory:aDirectory inBundle:nil];
}

- (id)imageForName:(id)aName ofType:(id)aType
{
    return [self imageForName:aName ofType:aType inDirectory:nil];
}

- (id)imageForName:(id)aName
{
    return [self imageForName:[aName stringByDeletingPathExtension] ofType:[aName pathExtension]];
}

@end
