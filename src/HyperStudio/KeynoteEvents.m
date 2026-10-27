#import "KeynoteEvents.h"

@implementation KeynoteEvents

// Media started by a movie-start build plays on click; others on arrival.
- (id)eventTypeForMediaId:(id)aId
{
    NSEnumerator *enumerator = [[self mediaStartBuilds] objectEnumerator];
    id build;
    while ((build = [enumerator nextObject]) != nil) {
        if ([[build referencedMediaId] isEqualToString:aId])
            return kHSClickActionEventType;
    }
    return kHSArriveActionEventType;
}

- (id)mediaStartBuilds
{
    if (_mediaStartBuilds == nil) {
        _mediaStartBuilds = [[NSMutableArray array] retain];
        NSEnumerator *enumerator = [[self builds] objectEnumerator];
        id build;
        while ((build = [enumerator nextObject]) != nil) {
            if ([build buildType] == 1)
                [_mediaStartBuilds addObject:build];
        }
    }
    return _mediaStartBuilds;
}

- (id)builds
{
    id builds = [self keynoteObjectForXMLPath:@"./build"];
    if (builds != nil && ![builds isKindOfClass:[NSArray class]])
        builds = [NSArray arrayWithObject:builds];
    return builds;
}

- (void)dealloc
{
    [_mediaStartBuilds release];
    [super dealloc];
}

@end
