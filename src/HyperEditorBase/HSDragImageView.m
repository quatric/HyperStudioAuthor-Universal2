#import "HSDragImageView.h"

// An image view whose image can be dragged out, with the pasteboard types
// and data from the delegate.

@implementation HSDragImageView

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    if ([_delegate respondsToSelector:@selector(provideDataForType:forPasteboard:forDragImageView:)])
        [_delegate provideDataForType:aType forPasteboard:aPasteboard forDragImageView:self];
}

- (void)mouseDragged:(id)aDragged
{
    NSImage *image = [self dragImage];
    NSArray *types;
    if (image != nil && [_delegate respondsToSelector:@selector(pasteboardTypesForDragImageView:)]
        && (types = [_delegate pasteboardTypesForDragImageView:self]) != nil) {
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pasteboard declareTypes:types owner:self];
        NSSize size = [image size];
        NSRect bounds = [self bounds];
        [self dragImage:image at:NSMakePoint((bounds.size.width - size.width) * 0.5, (bounds.size.height - size.height) * 0.5) offset:NSZeroSize
                  event:aDragged pasteboard:pasteboard source:self slideBack:YES];
        return;
    }
    // Original quirk kept: a drag that can't start is passed on as a mouse
    // down.
    [super mouseDown:aDragged];
}

// The drag starts on mouse dragged.
- (void)mouseDown:(id)aDown
{
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end

@implementation HSDragImageView (HSDragImageViewPrivate)

// A copy of the image scaled down to fit the view.
- (id)dragImage
{
    NSImage *image = [[self image] copy];
    NSSize size = [image size];
    NSRect bounds = [self bounds];
    float scale = bounds.size.width < size.width ? bounds.size.width / size.width : 1;
    if (bounds.size.height < size.height * scale)
        scale = bounds.size.height / size.height;
    if (scale != 1)
        [image setSize:NSMakeSize(size.width * scale, size.height * scale)];
    return [image autorelease];
}

@end
