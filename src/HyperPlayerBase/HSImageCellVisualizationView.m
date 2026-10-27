#import "HSImageCellVisualizationView.h"
@implementation HSImageCellVisualizationView
- (void)drawRect:(NSRect)aRect
{
    if (NSIsEmptyRect([self cellFrame]))
        return;
    // with no room to draw it, the image is taken out of the cell while the
    // superclass draws
    NSImage *image = nil;
    if (NSIsEmptyRect([[self cell] drawingRectForBounds:[self cellFrame]])) {
        image = [[[self cell] image] retain];
        [[self cell] setImage:nil];
    }
    [super drawRect:aRect];
    if (image != nil) {
        [[self cell] setImage:image];
        [image release];
    }
}
@end
