#import "HSStack+KeynoteImporting.h"

@implementation HSStack (KeynoteImporting)

// One card per slide, then each card imports its slide.
- (void)importFromKeynoteObject:(id)aObject
{
    [self setHyperCardSize:[(KeynotePresentation *)aObject size]];
    NSArray *slides = [[aObject slides] retain];
    NSInteger count = [slides count];
    for (NSInteger i = 0; i < count; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [self addHyperChild:[HSCard defaultObject]];
        [pool release];
    }
    for (NSInteger i = 0; i < count; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [[self hyperChildAtIndex:i] importFromKeynoteObject:[slides objectAtIndex:i]];
        [pool release];
    }
    [slides release];
    id soundtrack = [aObject soundtrack];
    if (soundtrack != nil)
        [self addSoundFromKeynoteMedia:soundtrack loopMode:[aObject soundtrackLoopMode]];
    [self cleanupUserInfo];
}

@end
