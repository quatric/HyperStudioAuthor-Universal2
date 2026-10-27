#import "HSImagePopUpButtonCell.h"

@implementation HSImagePopUpButtonCell

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    [self drawInteriorWithFrame:aFrame inView:aView];
}

// The selected item's image is scaled to fit the image rect (minus 2 points)
// for the super call and restored afterwards.
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self showsFirstResponder]) {
        [NSGraphicsContext saveGraphicsState];
        [self setFocusRingType:NSFocusRingTypeDefault];
        NSSetFocusRingStyle(NSFocusRingAbove);
        [[self backgroundImage] drawInRect:aFrame fromRect:aFrame operation:NSCompositingOperationSourceOver fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        [[self backgroundImage] drawInRect:aFrame fromRect:aFrame operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    NSImage *image = [[self selectedItem] image];
    NSSize size = NSZeroSize;
    if (image != nil) {
        size = [image size];
        NSRect imageRect = [self imageRectForBounds:aFrame];
        float scale = MIN((imageRect.size.height - 2.0f) / size.height, (imageRect.size.width - 2.0f) / size.width);
        [image setSize:NSMakeSize(size.width * scale, size.height * scale)];
    }
    [super drawInteriorWithFrame:aFrame inView:aView];
    if (image != nil)
        [image setSize:size];
}

@end
