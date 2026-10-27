#import "NSObject+HSBackgroundAttributesContainer.h"
// The background (color, desktop cover or image) of objects keeping one
// (HSBackgroundAttributesContainerPrimitives); others don't respond.
@implementation NSObject (HSBackgroundAttributesContainer)
- (void)setCurrentBackground:(id)aBackground
{
    if ([self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)])
        [self setBackgroundGraphics:aBackground];
    else
        [self doesNotRecognizeSelector:_cmd];
}
- (id)currentBackground
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    return [(id)self backgroundGraphics];
}
// Cached until the background changes.
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    NSImage *thumbnail = [(id)self backgroundThumbnail];
    if (thumbnail != nil && NSEqualSizes(aSize, [thumbnail size]))
        return thumbnail;
    thumbnail = [[[NSImage alloc] initWithSize:aSize] autorelease];
    [thumbnail lockFocus];
    NSRect rect = { NSZeroPoint, aSize };
    [self hyperDrawBackgroundInROI:rect ofBounds:rect];
    [thumbnail unlockFocus];
    [(id)self setBackgroundThumbnail:thumbnail];
    return thumbnail;
}
- (void)hyperDrawBackgroundInROI:(NSRect)aROI ofBounds:(NSRect)aBounds
{
    if ([self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)])
        [[(id)self backgroundGraphics] hyperDrawInRect:aROI ofBounds:aBounds];
    else
        [self doesNotRecognizeSelector:_cmd];
}
// A background of the kind asked for (made if it isn't the current one).
- (id)queryBackgroundGraphicsInterface:(id)aInterface
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    id current = [[(id)self backgroundGraphics] queryHyperInterface:aInterface];
    if (current != nil)
        return current;
    Class class = Nil;
    if (protocol_conformsToProtocol(aInterface, @protocol(HSColor)))
        class = [HSColor class];
    else if (protocol_conformsToProtocol(aInterface, @protocol(HSDesktopCoverImage)))
        class = [HSDesktopCoverImage class];
    else if (protocol_conformsToProtocol(aInterface, @protocol(HSImage)))
        class = [HSImage class];
    if (class == Nil)
        return nil;
    id background = [[[class alloc] initWithOwner:self] autorelease];
    if (background != nil)
        [self setBackgroundGraphics:background copyObject:NO];
    return background;
}
- (void)setBackgroundGraphics:(id)aGraphics
{
    if ([self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)])
        [self setBackgroundGraphics:aGraphics copyObject:YES];
    else
        [self doesNotRecognizeSelector:_cmd];
}
// Undoable; a copy is owned by the object (its graphics delegate).
- (void)setBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    id container = self;
    if ([[container backgroundGraphics] isEqual:aGraphics])
        return;
    NSUndoManager *undoManager = [self undoManagerForGraphics:[container backgroundGraphics]];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Filling" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setHyperBackgroundGraphics:[container backgroundGraphics] copyObject:NO];
    [container notifyChange:1 ofAttribute:@protocol(HSBackgroundGraphicsAttribute) withUserInfo:nil];
    id graphics = aGraphics;
    if (aObject) {
        graphics = [[aGraphics hyperMutableCopyWithZone:[self zone]] autorelease];
        [graphics setHyperOwner:[container queryHyperInterface:@protocol(HSGraphicsDelegate)]];
    }
    [container _setBackgroundGraphics:graphics];
    [container notifyChange:2 ofAttribute:@protocol(HSBackgroundGraphicsAttribute) withUserInfo:nil];
}
- (id)undoManagerForGraphics:(id)aGraphics
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    return [(id)self undoManager];
}
- (void)hyperVisualAttributesChanged:(id)aChanged
{
    if (![self conformsToProtocol:@protocol(HSBackgroundAttributesContainerPrimitives)]) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    [(id)self notifyChange:2 ofAttribute:@protocol(HSBackgroundGraphicsAttribute) withUserInfo:nil];
    [(id)self setBackgroundThumbnail:nil];
}
@end
