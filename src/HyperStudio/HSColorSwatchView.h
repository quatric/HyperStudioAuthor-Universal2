#import "HyperStudioPrefix.h"


@interface HSColorSwatchView : NSView
{
    NSColor *_color;
}
- (void)setColor:(id)aColor;
- (id)color;
- (void)drawRect:(NSRect)aRect;
- (BOOL)isOpaque;
@end

