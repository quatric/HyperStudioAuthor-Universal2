#import "HSGridSetupDialogGridPreview.h"

@implementation HSGridSetupDialogGridPreview

- (id)objectColor
{
    return [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
}

// A 60-point square in the middle of the preview.
- (void)drawObject:(NSRect)aObject
{
    [(NSColor *)[self objectColor] set];
    NSRectFill(NSMakeRect(aObject.size.width * 0.5f - 30.0f, aObject.size.height * 0.5f - 30.0f, 60, 60));
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
}

@end
